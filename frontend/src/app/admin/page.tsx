'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/hooks/useAuth'
import { useQuery } from '@tanstack/react-query'
import { adminApi } from '@/lib/api'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { 
  Trophy, 
  Users, 
  Calendar, 
  Activity, 
  Target, 
  LogOut, 
  Shield,
  TrendingUp,
  Clock,
  CheckCircle
} from 'lucide-react'
import { formatDate, formatDateTime, getPositionColor, getCategoryColor } from '@/lib/utils'
import Link from 'next/link'

function LoginForm({ onLogin }: { onLogin: (token: string) => void }) {
  const [token, setToken] = useState('')
  const [error, setError] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!token.trim()) {
      setError('Token é obrigatório')
      return
    }
    onLogin(token.trim())
  }

  return (
    <div className="container mx-auto p-4 flex items-center justify-center min-h-screen">
      <Card className="w-full max-w-md bg-white/10 backdrop-blur border-white/20">
        <CardHeader>
          <div className="text-center mb-4">
            <Shield className="h-12 w-12 text-blue-400 mx-auto mb-4" />
            <CardTitle className="text-white">Admin Login</CardTitle>
            <CardDescription className="text-gray-300">
              Digite seu token de administrador
            </CardDescription>
          </div>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <Input
                type="password"
                placeholder="Token de administrador"
                value={token}
                onChange={(e) => setToken(e.target.value)}
                className="bg-white/10 border-white/20 text-white placeholder:text-gray-400"
              />
              {error && (
                <p className="text-sm text-red-400 mt-2">{error}</p>
              )}
            </div>
            <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700">
              <Shield className="h-4 w-4 mr-2" />
              Entrar
            </Button>
            <div className="text-center">
              <Link href="/">
                <Button variant="ghost" className="text-gray-300 hover:bg-white/10">
                  Voltar ao início
                </Button>
              </Link>
            </div>
          </form>
          
          <div className="mt-6 p-4 bg-blue-500/10 rounded-lg border border-blue-500/30">
            <p className="text-xs text-blue-200 mb-2">
              <strong>Para desenvolvimento:</strong>
            </p>
            <p className="text-xs text-blue-300">
              Use qualquer token que comece com "admin_" (ex: admin_test)
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function DashboardContent({ onLogout }: { onLogout: () => void }) {
  const { data: dashboardData, isLoading, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: adminApi.getDashboard,
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
          <p className="text-white">Carregando dashboard...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="max-w-md mx-auto">
        <Card className="bg-red-50 border-red-200">
          <CardContent className="p-6 text-center">
            <div className="text-red-600 mb-4">
              <Target className="h-12 w-12 mx-auto" />
            </div>
            <h3 className="text-lg font-semibold text-red-800 mb-2">
              Erro ao carregar dados
            </h3>
            <p className="text-red-600 mb-4">
              {error instanceof Error ? error.message : 'Token inválido ou expirado'}
            </p>
            <Button onClick={onLogout} variant="outline" className="text-red-600 border-red-600">
              Fazer login novamente
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  if (!dashboardData) return null

  const { today, stats, recent_activity } = dashboardData

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-4 sm:space-y-0">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center space-x-2">
            <Trophy className="h-6 w-6 text-yellow-400" />
            <span>Admin Dashboard</span>
          </h1>
          <p className="text-gray-300">
            Dota Evolution Presence - Gerenciamento do Sistema
          </p>
        </div>
        <Button onClick={onLogout} variant="outline" className="border-white/30 text-white hover:bg-white/10">
          <LogOut className="h-4 w-4 mr-2" />
          Logout
        </Button>
      </div>

      {/* Today's Status */}
      <Card className="bg-white/10 backdrop-blur border-white/20">
        <CardHeader>
          <CardTitle className="text-white flex items-center space-x-2">
            <Calendar className="h-5 w-5" />
            <span>Status de Hoje - {formatDate(today.date)}</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="text-center">
              <div className="text-2xl font-bold text-green-400">{today.confirmed_presences}</div>
              <div className="text-sm text-gray-300">Confirmados</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-400">{today.available_positions.length}</div>
              <div className="text-sm text-gray-300">Disponíveis</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-purple-400">
                {today.daily_list_status || 'N/A'}
              </div>
              <div className="text-sm text-gray-300">Status da Lista</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-yellow-400">5</div>
              <div className="text-sm text-gray-300">Total Posições</div>
            </div>
          </div>

          {/* Today's Players */}
          {today.confirmed_players.length > 0 && (
            <div className="space-y-3">
              <h4 className="font-medium text-white">Jogadores Confirmados Hoje:</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {today.confirmed_players.map((player, index) => (
                  <div key={index} className="flex items-center space-x-3 p-3 rounded-lg bg-white/5 border border-white/10">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${getPositionColor(player.position)}`}>
                      {player.position}
                    </div>
                    <div className="flex-1">
                      <p className="font-medium text-white">{player.nickname}</p>
                      <div className="flex items-center space-x-2">
                        <Badge className={`text-xs ${getCategoryColor(player.category)}`}>
                          {player.category}
                        </Badge>
                        <span className="text-xs text-gray-400">
                          {formatDateTime(player.confirmed_at).split(' ')[1]}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Users Stats */}
        <Card className="bg-white/10 backdrop-blur border-white/20">
          <CardHeader>
            <CardTitle className="text-white flex items-center space-x-2">
              <Users className="h-5 w-5" />
              <span>Usuários</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Total</span>
              <span className="text-2xl font-bold text-white">{stats.users.total}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Ativos</span>
              <span className="text-lg font-semibold text-green-400">{stats.users.active}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Immortals</span>
              <span className="text-lg font-semibold text-yellow-400">{stats.users.immortals}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Ancients</span>
              <span className="text-lg font-semibold text-purple-400">{stats.users.ancients}</span>
            </div>
          </CardContent>
        </Card>

        {/* Activity Stats */}
        <Card className="bg-white/10 backdrop-blur border-white/20">
          <CardHeader>
            <CardTitle className="text-white flex items-center space-x-2">
              <Activity className="h-5 w-5" />
              <span>Atividade</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Esta Semana</span>
              <span className="text-2xl font-bold text-white">{stats.activity.weekly_presences}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Listas Recentes</span>
              <span className="text-lg font-semibold text-blue-400">{stats.activity.recent_lists_count}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Média Diária</span>
              <span className="text-lg font-semibold text-green-400">{stats.activity.avg_daily_presences}</span>
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card className="bg-white/10 backdrop-blur border-white/20">
          <CardHeader>
            <CardTitle className="text-white flex items-center space-x-2">
              <Target className="h-5 w-5" />
              <span>Ações Rápidas</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Link href="/admin/users" className="block">
              <Button variant="outline" className="w-full justify-start border-white/30 text-white hover:bg-white/10">
                <Users className="h-4 w-4 mr-2" />
                Gerenciar Usuários
              </Button>
            </Link>
            <Link href="/admin/daily-lists" className="block">
              <Button variant="outline" className="w-full justify-start border-white/30 text-white hover:bg-white/10">
                <Calendar className="h-4 w-4 mr-2" />
                Listas Diárias
              </Button>
            </Link>
            <Link href="/" className="block">
              <Button variant="outline" className="w-full justify-start border-white/30 text-white hover:bg-white/10">
                <Trophy className="h-4 w-4 mr-2" />
                Ver Lista Pública
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      {recent_activity.length > 0 && (
        <Card className="bg-white/10 backdrop-blur border-white/20">
          <CardHeader>
            <CardTitle className="text-white flex items-center space-x-2">
              <Clock className="h-5 w-5" />
              <span>Atividade Recente</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {recent_activity.map((activity) => (
                <div key={activity.id} className="flex items-center justify-between p-3 rounded-lg bg-white/5 border border-white/10">
                  <div className="flex items-center space-x-3">
                    <CheckCircle className="h-5 w-5 text-green-400" />
                    <div>
                      <p className="font-medium text-white">
                        Lista de {formatDate(activity.date)}
                      </p>
                      <p className="text-sm text-gray-400">
                        {activity.presences_count} confirmações
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <Badge variant={activity.status === 'sent' ? 'default' : 'secondary'}>
                      {activity.status}
                    </Badge>
                    <p className="text-xs text-gray-400 mt-1">
                      {formatDateTime(activity.created_at)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

export default function AdminPage() {
  const { isAuthenticated, isLoading, login, logout } = useAuth()

  if (isLoading) {
    return (
      <div className="container mx-auto p-4 flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
          <p className="text-white">Verificando autenticação...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto p-4">
      {isAuthenticated ? (
        <DashboardContent onLogout={logout} />
      ) : (
        <LoginForm onLogin={login} />
      )}
    </div>
  )
}