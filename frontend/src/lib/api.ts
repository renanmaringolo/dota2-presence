import axios from 'axios'
import type { 
  ApiResponse, 
  DailyList, 
  Presence, 
  User, 
  DashboardData,
  Position 
} from '@/types'

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Admin token for authenticated requests
let adminToken = ''

export const setAdminToken = (token: string) => {
  adminToken = token
  api.defaults.headers.Authorization = `Bearer ${token}`
}

// Public API endpoints
export const presenceApi = {
  // Get today's presence list
  getToday: async (): Promise<{
    daily_list: { id: number; date: string; status: string }
    presences: Presence[]
    available_positions: Position[]
    summary: any
  }> => {
    const { data } = await api.get<ApiResponse<any>>('/presences')
    if (!data.success) throw new Error(data.message || 'Failed to fetch presences')
    return data.data
  },

  // Confirm presence
  confirm: async (nickname: string, position: Position, notes?: string): Promise<{ id: number; message: string }> => {
    const { data } = await api.post<ApiResponse<any>>('/presences', { 
      nickname, 
      position, 
      notes 
    })
    if (!data.success) throw new Error(data.message || 'Failed to confirm presence')
    return data.data
  },

  // Cancel presence
  cancel: async (nickname: string): Promise<void> => {
    const { data } = await api.delete<ApiResponse<any>>(`/presences/${nickname}`)
    if (!data.success) throw new Error(data.message || 'Failed to cancel presence')
  },
}

// Admin API endpoints
export const adminApi = {
  // Dashboard
  getDashboard: async (): Promise<DashboardData> => {
    const { data } = await api.get<ApiResponse<DashboardData>>('/admin/dashboard')
    if (!data.success) throw new Error(data.message || 'Failed to fetch dashboard')
    return data.data
  },

  // Users
  getUsers: async (params?: { category?: string; active?: boolean }): Promise<{ users: User[]; total: number }> => {
    const { data } = await api.get<ApiResponse<any>>('/admin/users', { params })
    if (!data.success) throw new Error(data.message || 'Failed to fetch users')
    return data.data
  },

  getUser: async (id: number): Promise<User> => {
    const { data } = await api.get<ApiResponse<User>>(`/admin/users/${id}`)
    if (!data.success) throw new Error(data.message || 'Failed to fetch user')
    return data.data
  },

  createUser: async (user: Omit<User, 'id' | 'created_at' | 'updated_at' | 'full_display_name' | 'recent_presences_count'>): Promise<User> => {
    const { data } = await api.post<ApiResponse<User>>('/admin/users', { user })
    if (!data.success) throw new Error(data.message || 'Failed to create user')
    return data.data
  },

  updateUser: async (id: number, user: Partial<User>): Promise<User> => {
    const { data } = await api.put<ApiResponse<User>>(`/admin/users/${id}`, { user })
    if (!data.success) throw new Error(data.message || 'Failed to update user')
    return data.data
  },

  deleteUser: async (id: number): Promise<void> => {
    const { data } = await api.delete<ApiResponse<void>>(`/admin/users/${id}`)
    if (!data.success) throw new Error(data.message || 'Failed to delete user')
  },

  // Daily Lists
  getDailyLists: async (params?: { status?: string }): Promise<{ daily_lists: DailyList[]; total: number }> => {
    const { data } = await api.get<ApiResponse<any>>('/admin/daily_lists', { params })
    if (!data.success) throw new Error(data.message || 'Failed to fetch daily lists')
    return data.data
  },

  getDailyList: async (id: number): Promise<DailyList & { presences: Presence[] }> => {
    const { data } = await api.get<ApiResponse<any>>(`/admin/daily_lists/${id}`)
    if (!data.success) throw new Error(data.message || 'Failed to fetch daily list')
    return data.data
  },

  createDailyList: async (date?: string): Promise<DailyList> => {
    const { data } = await api.post<ApiResponse<DailyList>>('/admin/daily_lists', { date })
    if (!data.success) throw new Error(data.message || 'Failed to create daily list')
    return data.data
  },

  sendToWhatsApp: async (id: number): Promise<{ total: number; successful: number; failed: number }> => {
    const { data } = await api.post<ApiResponse<any>>(`/admin/daily_lists/${id}/send_to_whatsapp`)
    if (!data.success) throw new Error(data.message || 'Failed to send to WhatsApp')
    return data.data
  },

  updateDailyList: async (id: number, updates: Partial<DailyList>): Promise<DailyList> => {
    const { data } = await api.put<ApiResponse<DailyList>>(`/admin/daily_lists/${id}`, updates)
    if (!data.success) throw new Error(data.message || 'Failed to update daily list')
    return data.data
  },

  deleteDailyList: async (id: number): Promise<void> => {
    const { data } = await api.delete<ApiResponse<void>>(`/admin/daily_lists/${id}`)
    if (!data.success) throw new Error(data.message || 'Failed to delete daily list')
  },
}

export default api