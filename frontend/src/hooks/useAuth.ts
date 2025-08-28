'use client'

import { useState, useEffect } from 'react'
import { setAdminToken } from '@/lib/api'

export function useAuth() {
  const [token, setToken] = useState<string | null>(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Check for stored token
    const storedToken = localStorage.getItem('admin_token')
    if (storedToken) {
      setToken(storedToken)
      setIsAuthenticated(true)
      setAdminToken(storedToken)
    }
    setIsLoading(false)
  }, [])

  const login = (adminToken: string) => {
    localStorage.setItem('admin_token', adminToken)
    setToken(adminToken)
    setIsAuthenticated(true)
    setAdminToken(adminToken)
  }

  const logout = () => {
    localStorage.removeItem('admin_token')
    setToken(null)
    setIsAuthenticated(false)
    setAdminToken('')
  }

  return {
    token,
    isAuthenticated,
    isLoading,
    login,
    logout
  }
}