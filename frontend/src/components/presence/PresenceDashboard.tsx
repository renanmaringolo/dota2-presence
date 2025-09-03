'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { DailyStatsCard } from './DailyStatsCard';
import { CurrentListCard } from './CurrentListCard';
import { HistoricalSection } from './HistoricalSection';

interface DashboardData {
  current_lists: {
    ancient: CurrentListData;
    immortal: CurrentListData;
  };
  daily_stats: DailyStats;
  historical_summary: HistoricalList[];
}

interface CurrentListData {
  id: string;
  display_name: string;
  sequence_number: number;
  status: 'open' | 'full';
  available_positions: string[];
  confirmed_players: ConfirmedPlayer[];
  user_status: UserStatus;
}

interface ConfirmedPlayer {
  position: string;
  user: {
    nickname: string;
    rank: string;
    confirmed_at: string;
  };
}

interface UserStatus {
  can_join: boolean;
  reason?: string;
  confirmed_list?: string;
  position?: string;
  available_positions?: string[];
}

interface DailyStats {
  ancient_count: number;
  immortal_count: number;
  total_players_today: number;
  current_sequence: {
    ancient: number;
    immortal: number;
  };
}

interface HistoricalList {
  id: string;
  display_name: string;
  date: string;
  completed_at: string;
  players: string[];
}

export function PresenceDashboard() {
  const { user, getAuthToken } = useAuth();
  const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>('');

  const fetchDashboardData = async () => {
    try {
      setError('');
      const token = getAuthToken();
      
      if (!token) {
        setError('Token de autenticação não encontrado');
        return;
      }

      const response = await fetch(`${API_BASE}/api/v1/daily-lists/dashboard`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        if (response.status === 401) {
          setError('Sessão expirada. Faça login novamente.');
        } else {
          setError(`Erro ${response.status}: ${response.statusText}`);
        }
        return;
      }
      
      const result = await response.json();
      setDashboardData(result.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro desconhecido');
      console.error('Erro ao buscar dashboard:', err);
    }
  };

  const handleConfirmPosition = async (position: string, listType: 'ancient' | 'immortal') => {
    setLoading(true);
    try {
      const token = getAuthToken();
      
      if (!token) {
        setError('Token de autenticação não encontrado');
        return;
      }

      const response = await fetch(`${API_BASE}/api/v1/presences`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          data: {
            type: 'presence',
            attributes: {
              position,
              list_type: listType
            }
          }
        })
      });

      const result = await response.json();
      
      if (response.ok) {
        alert(result.meta.message);
        await fetchDashboardData();
      } else {
        if (response.status === 401) {
          setError('Sessão expirada. Faça login novamente.');
        } else {
          setError(result.errors?.[0]?.detail || 'Erro ao confirmar presença');
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao confirmar presença');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelPresence = async (listType: 'ancient' | 'immortal') => {
    setLoading(true);
    try {
      const token = getAuthToken();
      
      if (!token) {
        setError('Token de autenticação não encontrado');
        return;
      }

      const response = await fetch(`${API_BASE}/api/v1/presences/${listType}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        alert('Presença cancelada com sucesso!');
        await fetchDashboardData();
      } else {
        if (response.status === 401) {
          setError('Sessão expirada. Faça login novamente.');
        } else {
          const result = await response.json();
          setError(result.errors?.[0]?.detail || 'Erro ao cancelar presença');
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao cancelar presença');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Só busca dados se o usuário estiver autenticado
    if (user && getAuthToken()) {
      fetchDashboardData();
      
      // Auto-refresh a cada 30 segundos para pegar atualizações
      const interval = setInterval(fetchDashboardData, 30000);
      return () => clearInterval(interval);
    }
  }, [user]);

  if (!dashboardData) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          {error ? (
            <>
              <div className="text-red-500 mb-4 text-lg">⚠️</div>
              <p style={{color: 'var(--dota-text-light)'}}>{error}</p>
              <button 
                onClick={fetchDashboardData}
                className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Tentar Novamente
              </button>
            </>
          ) : (
            <>
              <div className="animate-spin rounded-full h-12 w-12 border-b-2" style={{borderColor: 'var(--dota-bronze)'}}></div>
              <p className="mt-4" style={{color: 'var(--dota-text-light)'}}>Carregando dashboard...</p>
            </>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Error Display */}
      {error && (
        <div className="dota-error px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Daily Stats */}
      <DailyStatsCard stats={dashboardData.daily_stats} />

      {/* Current Lists */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <CurrentListCard
          title="Lista Ancient"
          subtitle="Todos podem participar (inclusive smurfs)"
          listData={dashboardData.current_lists.ancient}
          onConfirmPosition={(pos) => handleConfirmPosition(pos, 'ancient')}
          onCancelPresence={() => handleCancelPresence('ancient')}
          loading={loading}
          theme="bronze"
        />
        
        <CurrentListCard
          title="Lista Immortal"
          subtitle="Divine 1+ e Immortal apenas"
          listData={dashboardData.current_lists.immortal}
          onConfirmPosition={(pos) => handleConfirmPosition(pos, 'immortal')}
          onCancelPresence={() => handleCancelPresence('immortal')}
          loading={loading}
          theme="gold"
        />
      </div>

      {/* Historical Summary */}
      <HistoricalSection 
        historicalLists={dashboardData.historical_summary}
      />
    </div>
  );
}