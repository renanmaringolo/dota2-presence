'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { RegisterData } from '@/lib/auth';
import { DotaCard, DotaInput, DotaButton, DotaLabel, DotaSelect, DotaCheckbox } from '@/components/ui';

interface RegisterFormProps {
  onSwitchToLogin?: () => void;
}

const POSITIONS = [
  { value: 'P1', label: 'P1 - Hard Carry' },
  { value: 'P2', label: 'P2 - Mid' },
  { value: 'P3', label: 'P3 - Offlaner' },
  { value: 'P4', label: 'P4 - Support' },
  { value: 'P5', label: 'P5 - Hard Support' },
];

const RANK_MEDALS = [
  'Herald', 'Guardian', 'Crusader', 'Archon', 'Legend', 
  'Ancient', 'Divine', 'Immortal'
];

export function RegisterForm({ onSwitchToLogin }: RegisterFormProps) {
  const { register } = useAuth();
  const [formData, setFormData] = useState<RegisterData>({
    email: '',
    password: '',
    password_confirmation: '',
    name: '',
    nickname: '',
    phone: '',
    rank_medal: '',
    rank_stars: 0,
    preferred_position: '',
    positions: [],
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    if (formData.password !== formData.password_confirmation) {
      setError('As senhas não coincidem');
      setLoading(false);
      return;
    }

    try {
      await register(formData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao cadastrar');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    
    if (type === 'number') {
      setFormData(prev => ({ ...prev, [name]: parseInt(value) || 0 }));
    } else {
      setFormData(prev => ({ ...prev, [name]: value }));
    }
  };

  const handlePositionsChange = (position: string) => {
    setFormData(prev => ({
      ...prev,
      positions: prev.positions.includes(position)
        ? prev.positions.filter(p => p !== position)
        : [...prev.positions, position]
    }));
  };

  return (
    <div className="w-full max-w-2xl mx-auto fade-in-up">
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
            Crie sua conta
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <DotaLabel htmlFor="name">
                Nome Completo
              </DotaLabel>
              <DotaInput
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                placeholder="Seu nome completo"
              />
            </div>

            <div>
              <DotaLabel htmlFor="nickname">
                Nickname no Dota
              </DotaLabel>
              <DotaInput
                type="text"
                id="nickname"
                name="nickname"
                value={formData.nickname}
                onChange={handleChange}
                required
                placeholder="Seu nick no Dota 2"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <DotaLabel htmlFor="email">
                Email
              </DotaLabel>
              <DotaInput
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                placeholder="seu@email.com"
              />
            </div>

            <div>
              <DotaLabel htmlFor="phone">
                WhatsApp
              </DotaLabel>
              <DotaInput
                type="text"
                id="phone"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                required
                placeholder="(11) 99999-9999"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <DotaLabel htmlFor="password">
                Senha
              </DotaLabel>
              <DotaInput
                type="password"
                id="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                required
                placeholder="Sua senha"
              />
            </div>

            <div>
              <DotaLabel htmlFor="password_confirmation">
                Confirmar Senha
              </DotaLabel>
              <DotaInput
                type="password"
                id="password_confirmation"
                name="password_confirmation"
                value={formData.password_confirmation}
                onChange={handleChange}
                required
                placeholder="Confirme sua senha"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <DotaLabel htmlFor="rank_medal">
                Medal
              </DotaLabel>
              <DotaSelect
                id="rank_medal"
                name="rank_medal"
                value={formData.rank_medal}
                onChange={handleChange}
                required
              >
                <option value="">Selecione</option>
                {RANK_MEDALS.map(medal => (
                  <option key={medal} value={medal}>{medal}</option>
                ))}
              </DotaSelect>
            </div>

            <div>
              <DotaLabel htmlFor="rank_stars">
                Estrelas (0-5)
              </DotaLabel>
              <DotaInput
                type="number"
                id="rank_stars"
                name="rank_stars"
                min="0"
                max="5"
                value={formData.rank_stars}
                onChange={handleChange}
                placeholder="0"
              />
            </div>

            <div>
              <DotaLabel htmlFor="preferred_position">
                Posição Preferida
              </DotaLabel>
              <DotaSelect
                id="preferred_position"
                name="preferred_position"
                value={formData.preferred_position}
                onChange={handleChange}
                required
              >
                <option value="">Selecione</option>
                {POSITIONS.map(pos => (
                  <option key={pos.value} value={pos.value}>{pos.label}</option>
                ))}
              </DotaSelect>
            </div>
          </div>

          <div>
            <DotaLabel className="mb-3">
              Posições que joga (selecione múltiplas)
            </DotaLabel>
            <div className="flex flex-wrap gap-4">
              {POSITIONS.map(position => (
                <DotaCheckbox
                  key={position.value}
                  checked={formData.positions.includes(position.value)}
                  onChange={() => handlePositionsChange(position.value)}
                  label={position.label}
                />
              ))}
            </div>
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
            {loading ? 'Cadastrando' : 'Cadastrar'}
          </DotaButton>
        </form>

        {onSwitchToLogin && (
          <div className="mt-8 text-center">
            <p style={{color: 'var(--dota-text-muted)'}}>
              Já tem conta?{' '}
              <button
                type="button"
                onClick={onSwitchToLogin}
                className="font-medium transition-colors hover:underline"
                style={{color: 'var(--dota-bronze)'}}
              >
                Faça login aqui
              </button>
            </p>
          </div>
        )}
      </DotaCard>
    </div>
  );
}
