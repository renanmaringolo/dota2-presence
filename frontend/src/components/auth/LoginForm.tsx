'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { LoginCredentials } from '@/lib/auth';
import { DotaCard, DotaInput, DotaButton, DotaLabel } from '@/components/ui';

interface LoginFormProps {
  onSwitchToRegister?: () => void;
}

export function LoginForm({ onSwitchToRegister }: LoginFormProps) {
  const { login } = useAuth();
  const [credentials, setCredentials] = useState<LoginCredentials>({
    email: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      await login(credentials);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao fazer login');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setCredentials(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  return (
    <div className="w-full max-w-md mx-auto fade-in-up">
      <DotaCard className="p-8">
        {/* Logo/Header */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 mx-auto mb-4 dota-gradient-bronze rounded-full flex items-center justify-center">
            <svg className="w-8 h-8 text-gray-900" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2L13.09 8.26L20 9L13.09 9.74L12 16L10.91 9.74L4 9L10.91 8.26L12 2Z"/>
            </svg>
          </div>
          <h2 className="text-3xl font-bold text-center mb-2" style={{color: 'var(--dota-bronze)'}}>
            Dota Evolution
          </h2>
          <p className="text-sm" style={{color: 'var(--dota-text-muted)'}}>
            Entre na sua conta
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <DotaLabel htmlFor="email">
              Email
            </DotaLabel>
            <DotaInput
              type="email"
              id="email"
              name="email"
              value={credentials.email}
              onChange={handleChange}
              required
              placeholder="seu@email.com"
            />
          </div>

          <div className="space-y-2">
            <DotaLabel htmlFor="password">
              Senha
            </DotaLabel>
            <DotaInput
              type="password"
              id="password"
              name="password"
              value={credentials.password}
              onChange={handleChange}
              required
              placeholder="Sua senha"
            />
          </div>

          {error && (
            <div className="dota-error px-4 py-3 rounded-lg text-sm fade-in-up">
              {error}
            </div>
          )}

          <DotaButton
            type="submit"
            disabled={loading}
            loading={loading}
          >
            {loading ? 'Entrando' : 'Entrar'}
          </DotaButton>
        </form>

        {onSwitchToRegister && (
          <div className="mt-8 text-center">
            <p style={{color: 'var(--dota-text-muted)'}}>
              Não tem conta?{' '}
              <button
                type="button"
                onClick={onSwitchToRegister}
                className="font-medium transition-colors hover:underline"
                style={{color: 'var(--dota-bronze)'}}
              >
                Cadastre-se aqui
              </button>
            </p>
          </div>
        )}
      </DotaCard>
    </div>
  );
}