'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { DotaCard, DotaButton } from '@/components/ui';
import { PresenceDashboard } from '@/components/presence/PresenceDashboard';

export default function DashboardPage() {
  const { user, isAuthenticated, loading, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push('/auth');
    }
  }, [isAuthenticated, loading, router]);

  if (loading) {
    return (
      <div className="min-h-screen dota-gradient-bg flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2" style={{borderColor: 'var(--dota-bronze)'}}></div>
          <p className="mt-4" style={{color: 'var(--dota-text-light)'}}>Carregando...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated || !user) {
    return null;
  }

  return (
    <div className="min-h-screen dota-gradient-bg">
      <header className="border-b border-opacity-30" style={{borderColor: 'var(--dota-border)'}}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center space-x-4">
              <div className="w-12 h-12 dota-gradient-bronze rounded-full flex items-center justify-center">
                <svg className="w-6 h-6 text-gray-900" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2L13.09 8.26L20 9L13.09 9.74L12 16L10.91 9.74L4 9L10.91 8.26L12 2Z"/>
                </svg>
              </div>
              <div>
                <h1 className="text-3xl font-bold" style={{color: 'var(--dota-bronze)'}}>
                  Dota Evolution
                </h1>
                <p style={{color: 'var(--dota-text-light)'}}>
                  Bem-vindo, {user.full_display_name}!
                </p>
              </div>
            </div>
            <DotaButton
              onClick={logout}
              className="!w-auto px-6 py-2 text-base !bg-red-600 hover:!bg-red-700"
            >
              Sair
            </DotaButton>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <PresenceDashboard />
      </main>
    </div>
  );
}
