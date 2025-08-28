'use client'

import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { presenceApi } from '@/lib/api'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { getPositionColor, getPositionName } from '@/lib/utils'
import { ArrowLeft, CheckCircle, XCircle, Target, Users, AlertCircle } from 'lucide-react'
import Link from 'next/link'
import { Position } from '@/types'

export default function ConfirmPage() {
  const [nickname, setNickname] = useState('')
  const [selectedPosition, setSelectedPosition] = useState<Position | ''>('')
  const [notes, setNotes] = useState('')
  const [successMessage, setSuccessMessage] = useState('')
  const [errorMessage, setErrorMessage] = useState('')

  const queryClient = useQueryClient()

  const { data: presenceData, isLoading } = useQuery({
    queryKey: ['presences'],
    queryFn: presenceApi.getToday,
  })

  const confirmMutation = useMutation({
    mutationFn: ({ nickname, position, notes }: { nickname: string; position: Position; notes?: string }) =>
      presenceApi.confirm(nickname, position, notes),
    onSuccess: (data) => {
      setSuccessMessage(data.message)
      setErrorMessage('')
      setNickname('')
      setSelectedPosition('')
      setNotes('')
      queryClient.invalidateQueries({ queryKey: ['presences'] })
    },
    onError: (error) => {
      setErrorMessage(error instanceof Error ? error.message : 'Erro ao confirmar presença')
      setSuccessMessage('')
    },
  })

  const cancelMutation = useMutation({
    mutationFn: (nickname: string) => presenceApi.cancel(nickname),
    onSuccess: () => {
      setSuccessMessage('Presença cancelada com sucesso!')
      setErrorMessage('')
      setNickname('')
      queryClient.invalidateQueries({ queryKey: ['presences'] })
    },
    onError: (error) => {
      setErrorMessage(error instanceof Error ? error.message : 'Erro ao cancelar presença')
      setSuccessMessage('')
    },
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!nickname.trim()) {
      setErrorMessage('Por favor, insira seu nickname')
      return
    }
    
    if (!selectedPosition) {
      setErrorMessage('Por favor, selecione uma posição')
      return
    }

    confirmMutation.mutate({
      nickname: nickname.trim(),
      position: selectedPosition,
      notes: notes.trim() || undefined
    })
  }

  const handleCancel = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!nickname.trim()) {
      setErrorMessage('Por favor, insira seu nickname para cancelar')
      return
    }

    cancelMutation.mutate(nickname.trim())
  }

  const availablePositions = presenceData?.available_positions || []
  const isFormValid = nickname.trim() && selectedPosition

  if (isLoading) {
    return (
      <div className="container mx-auto p-4">
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
            <p className="text-white">Carregando...</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto p-4 max-w-2xl">
      {/* Header */}
      <div className="mb-6">
        <Link href="/">
          <Button variant="ghost" className="text-white hover:bg-white/10 mb-4">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Voltar
          </Button>
        </Link>
        
        <div className="text-center">
          <h1 className="text-2xl font-bold text-white mb-2">
            Confirmar Presença
          </h1>
          <p className="text-gray-300">
            Confirme sua participação na partida de hoje
          </p>
        </div>
      </div>

      {/* Success/Error Messages */}
      {successMessage && (
        <div className="mb-6">
          <Card className="bg-green-500/20 border-green-500/50">
            <CardContent className="p-4">
              <div className="flex items-center space-x-2 text-green-400">
                <CheckCircle className="h-5 w-5" />
                <span>{successMessage}</span>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {errorMessage && (
        <div className="mb-6">
          <Card className="bg-red-500/20 border-red-500/50">
            <CardContent className="p-4">
              <div className="flex items-center space-x-2 text-red-400">
                <XCircle className="h-5 w-5" />
                <span>{errorMessage}</span>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Main Form */}
      <Card className="bg-white/10 backdrop-blur border-white/20">
        <CardHeader>
          <CardTitle className="text-white flex items-center space-x-2">
            <Users className="h-5 w-5" />
            <span>Informações do Jogador</span>
          </CardTitle>
          <CardDescription className="text-gray-300">
            Preencha seus dados para confirmar presença
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Nickname Input */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-white">
                Nickname *
              </label>
              <Input
                type="text"
                placeholder="Seu nickname no jogo (ex: Metallica)"
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                className="bg-white/10 border-white/20 text-white placeholder:text-gray-400"
                disabled={confirmMutation.isPending || cancelMutation.isPending}
              />
              <p className="text-xs text-gray-400">
                Use o mesmo nickname cadastrado no sistema
              </p>
            </div>

            {/* Position Selection */}
            <div className="space-y-4">
              <label className="text-sm font-medium text-white">
                Posição Desejada *
              </label>
              
              {availablePositions.length === 0 ? (
                <Card className="bg-yellow-500/20 border-yellow-500/50">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-2 text-yellow-400">
                      <AlertCircle className="h-5 w-5" />
                      <span>Todas as posições estão ocupadas no momento</span>
                    </div>
                  </CardContent>
                </Card>
              ) : (
                <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                  {['P1', 'P2', 'P3', 'P4', 'P5'].map((position) => {
                    const isAvailable = availablePositions.includes(position as Position)
                    const isSelected = selectedPosition === position
                    
                    return (
                      <button
                        key={position}
                        type="button"
                        onClick={() => isAvailable ? setSelectedPosition(position as Position) : null}
                        disabled={!isAvailable || confirmMutation.isPending || cancelMutation.isPending}
                        className={`p-4 rounded-lg border transition-all duration-200 ${
                          isSelected ? 'ring-2 ring-blue-500' : ''
                        } ${
                          isAvailable 
                            ? 'bg-white/10 border-white/20 hover:bg-white/20 cursor-pointer' 
                            : 'bg-gray-500/10 border-gray-500/20 cursor-not-allowed opacity-50'
                        }`}
                      >
                        <div className="space-y-2">
                          <div className={`w-8 h-8 mx-auto rounded-full flex items-center justify-center text-xs font-bold ${
                            isAvailable ? getPositionColor(position) : 'bg-gray-500 text-white'
                          }`}>
                            {position}
                          </div>
                          <div className="text-center">
                            <p className="text-xs text-white font-medium">
                              {getPositionName(position)}
                            </p>
                            {!isAvailable && (
                              <Badge variant="destructive" className="text-xs mt-1">
                                Ocupada
                              </Badge>
                            )}
                          </div>
                        </div>
                      </button>
                    )
                  })}
                </div>
              )}
            </div>

            {/* Notes */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-white">
                Observações (opcional)
              </label>
              <Input
                type="text"
                placeholder="Alguma observação sobre sua participação..."
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="bg-white/10 border-white/20 text-white placeholder:text-gray-400"
                disabled={confirmMutation.isPending || cancelMutation.isPending}
              />
            </div>

            {/* Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Button
                type="submit"
                disabled={!isFormValid || confirmMutation.isPending || cancelMutation.isPending || availablePositions.length === 0}
                className="flex-1 bg-green-600 hover:bg-green-700"
              >
                {confirmMutation.isPending ? (
                  <div className="flex items-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Confirmando...</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    <CheckCircle className="h-4 w-4" />
                    <span>Confirmar Presença</span>
                  </div>
                )}
              </Button>

              <Button
                type="button"
                onClick={handleCancel}
                disabled={!nickname.trim() || confirmMutation.isPending || cancelMutation.isPending}
                variant="destructive"
                className="flex-1"
              >
                {cancelMutation.isPending ? (
                  <div className="flex items-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Cancelando...</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    <XCircle className="h-4 w-4" />
                    <span>Cancelar Presença</span>
                  </div>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Instructions */}
      <Card className="mt-6 bg-blue-500/10 border-blue-500/30">
        <CardContent className="p-4">
          <div className="flex items-start space-x-3">
            <Target className="h-5 w-5 text-blue-400 mt-0.5" />
            <div className="text-sm text-blue-200">
              <p className="font-medium mb-1">Como funciona:</p>
              <ul className="space-y-1 text-xs">
                <li>• Confirme sua presença escolhendo uma posição disponível</li>
                <li>• Você pode alterar sua posição refazendo o processo</li>
                <li>• Para cancelar, digite apenas seu nickname e clique em "Cancelar"</li>
                <li>• Você também pode confirmar via WhatsApp: "SeuNickname/P1"</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}