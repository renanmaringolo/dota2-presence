export interface User {
  id: number
  name: string
  nickname: string
  phone: string
  category: 'immortal' | 'ancient'
  positions: Position[]
  preferred_position: Position
  active: boolean
  full_display_name: string
  recent_presences_count?: number
  created_at: string
  updated_at: string
}

export interface DailyList {
  id: number
  date: string
  status: 'generated' | 'sent' | 'closed'
  summary: DailyListSummary
  presences_count?: number
  available_positions?: Position[]
  created_at: string
  updated_at: string
}

export interface DailyListSummary {
  total_immortals?: number
  total_ancients?: number
  available_positions?: Position[]
  confirmed_presences?: number
  pending_positions?: Position[]
  generated_at?: string
  last_updated?: string
}

export interface Presence {
  id: number
  user: {
    id: number
    nickname: string
    name: string
    category: 'immortal' | 'ancient'
  }
  position: Position
  source: 'web' | 'whatsapp'
  confirmed_at: string
  notes?: string
}

export interface WhatsappMessage {
  id: number
  phone: string
  content: string
  status: 'pending' | 'sent' | 'received' | 'failed'
  user_id?: number
  presence_id?: number
  error_message?: string
  received_at?: string
}

export type Position = 'P1' | 'P2' | 'P3' | 'P4' | 'P5'

export interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
  timestamp: string
}

export interface DashboardData {
  today: {
    date: string
    daily_list_id: number | null
    daily_list_status: string | null
    confirmed_presences: number
    available_positions: Position[]
    confirmed_players: {
      nickname: string
      position: Position
      category: 'immortal' | 'ancient'
      confirmed_at: string
    }[]
  }
  stats: {
    users: {
      total: number
      active: number
      immortals: number
      ancients: number
      inactive: number
    }
    activity: {
      weekly_presences: number
      recent_lists_count: number
      avg_daily_presences: number
    }
  }
  recent_activity: {
    id: number
    date: string
    status: string
    presences_count: number
    created_at: string
  }[]
}