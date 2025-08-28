'use client'

import { useQuery } from '@tanstack/react-query'
import { presenceApi } from '@/lib/api'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { getPositionColor, getCategoryColor, getPositionName, formatDateTime } from '@/lib/utils'
import { Users, Calendar, Trophy, Target } from 'lucide-react'
import Link from 'next/link'

export default function HomePage() {
  const { data: presenceData, isLoading, error, refetch } = useQuery({
    queryKey: ['presences'],
    queryFn: presenceApi.getToday,
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  if (isLoading) {
    return (
      <div className="container mx-auto p-4">
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
            <p className="text-white">Carregando lista de presença...</p>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="container mx-auto p-4">
        <Card className="max-w-md mx-auto bg-red-50 border-red-200">
          <CardContent className="p-6">
            <div className="text-center">
              <div className="text-red-600 mb-4">
                <Target className="h-12 w-12 mx-auto" />
              </div>
              <h3 className="text-lg font-semibold text-red-800 mb-2">
                Erro ao carregar dados
              </h3>
              <p className="text-red-600 mb-4">
                {error instanceof Error ? error.message : 'Erro desconhecido'}
              </p>
              <Button onClick={() => refetch()} variant="outline" className="text-red-600 border-red-600 hover:bg-red-50">
                Tentar novamente
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  if (!presenceData?.daily_list) {
    return (
      <div className="container mx-auto p-4">
        <Card className="max-w-md mx-auto bg-yellow-50 border-yellow-200">
          <CardContent className="p-6">
            <div className="text-center">
              <div className="text-yellow-600 mb-4">
                <Calendar className="h-12 w-12 mx-auto" />
              </div>
              <h3 className="text-lg font-semibold text-yellow-800 mb-2">
                Nenhuma lista disponível
              </h3>
              <p className="text-yellow-600 mb-4">
                Não há lista de presença para hoje ainda.
              </p>
              <Button onClick={() => refetch()} variant="outline" className="text-yellow-600 border-yellow-600 hover:bg-yellow-50">
                Atualizar
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  const { daily_list, presences, available_positions } = presenceData
  const totalPositions = 5
  const occupiedPositions = presences.length

  return (
    <div className="container mx-auto p-4 space-y-6">
      {/* Header */}
      <div className="text-center space-y-4">
        <div className="flex items-center justify-center space-x-2">
          <Trophy className="h-8 w-8 text-yellow-400" />
          <h1 className="text-3xl font-bold text-white">
            Dota Evolution Presence
          </h1>
          <Trophy className="h-8 w-8 text-yellow-400" />
        </div>
        <p className="text-gray-300">
          Sistema de presença para coaching em Dota 2
        </p>
        <Badge variant="secondary" className="text-sm">
          Lista de {new Date(daily_list.date).toLocaleDateString('pt-BR')} - Status: {daily_list.status}
        </Badge>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card className="bg-white/10 backdrop-blur border-white/20 text-white">
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Users className="h-5 w-5 text-green-400" />
              <div>
                <p className="text-sm text-gray-300">Confirmados</p>
                <p className="text-2xl font-bold text-green-400">{occupiedPositions}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white/10 backdrop-blur border-white/20 text-white">
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Target className="h-5 w-5 text-blue-400" />
              <div>
                <p className="text-sm text-gray-300">Disponíveis</p>
                <p className="text-2xl font-bold text-blue-400">{available_positions.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white/10 backdrop-blur border-white/20 text-white">
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Calendar className="h-5 w-5 text-purple-400" />
              <div>
                <p className="text-sm text-gray-300">Total</p>
                <p className="text-2xl font-bold text-purple-400">{totalPositions}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Positions Grid */}
      <Card className="bg-white/10 backdrop-blur border-white/20">
        <CardHeader>
          <CardTitle className="text-white flex items-center space-x-2">
            <Target className="h-5 w-5" />
            <span>Posições do Time</span>
          </CardTitle>
          <CardDescription className="text-gray-300">
            Status atual das 5 posições para a partida de hoje
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            {['P1', 'P2', 'P3', 'P4', 'P5'].map((position) => {
              const presence = presences.find(p => p.position === position)
              const isAvailable = available_positions.includes(position as any)
              
              return (
                <Card key={position} className={`transition-all duration-200 ${
                  presence ? 'bg-green-500/20 border-green-500/50' : 
                  isAvailable ? 'bg-blue-500/20 border-blue-500/50' : 
                  'bg-gray-500/20 border-gray-500/50'
                }`}>
                  <CardContent className="p-4 text-center">
                    <div className="space-y-3">
                      <div className={`w-12 h-12 mx-auto rounded-full flex items-center justify-center text-sm font-bold ${getPositionColor(position)}`}>
                        {position}
                      </div>
                      <div>
                        <p className="text-xs text-gray-400 uppercase tracking-wide">
                          {getPositionName(position)}
                        </p>
                        {presence ? (
                          <div className="space-y-2 mt-2">
                            <p className="text-sm font-semibold text-white">
                              {presence.user.nickname}
                            </p>
                            <Badge 
                              className={`text-xs ${getCategoryColor(presence.user.category)}`}
                            >
                              {presence.user.category}
                            </Badge>
                            <p className="text-xs text-gray-400">
                              {formatDateTime(presence.confirmed_at).split(' ')[1]}
                            </p>
                          </div>
                        ) : (
                          <div className="mt-2">
                            <Badge variant="outline" className="text-xs text-gray-400 border-gray-600">
                              Disponível
                            </Badge>
                          </div>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="flex flex-col sm:flex-row gap-4 justify-center">
        <Link href="/confirm">
          <Button size="lg" className="w-full sm:w-auto bg-green-600 hover:bg-green-700">
            <Users className="h-5 w-5 mr-2" />
            Confirmar Presença
          </Button>
        </Link>
        
        <Link href="/admin">
          <Button variant="outline" size="lg" className="w-full sm:w-auto border-white/30 text-white hover:bg-white/10">
            <Trophy className="h-5 w-5 mr-2" />
            Admin Panel
          </Button>
        </Link>
      </div>

      {/* Confirmed Players List */}
      {presences.length > 0 && (
        <Card className="bg-white/10 backdrop-blur border-white/20">
          <CardHeader>
            <CardTitle className="text-white flex items-center space-x-2">
              <Users className="h-5 w-5" />
              <span>Jogadores Confirmados</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {presences.map((presence) => (
                <div key={presence.id} className="flex items-center justify-between p-3 rounded-lg bg-white/5 border border-white/10">
                  <div className="flex items-center space-x-3">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${getPositionColor(presence.position)}`}>
                      {presence.position}
                    </div>
                    <div>
                      <p className="font-semibold text-white">{presence.user.nickname}</p>
                      <p className="text-sm text-gray-400">{presence.user.name}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <Badge className={`${getCategoryColor(presence.user.category)} mb-1`}>
                      {presence.user.category}
                    </Badge>
                    <p className="text-xs text-gray-400">
                      {formatDateTime(presence.confirmed_at)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Auto-refresh indicator */}
      <div className="text-center">
        <p className="text-xs text-gray-400">
          Atualização automática a cada 30 segundos
        </p>
      </div>
    </div>
  )
}