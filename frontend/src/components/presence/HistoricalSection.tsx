import { useState } from 'react';
import { DotaCard } from '@/components/ui';

interface HistoricalList {
  id: string;
  display_name: string;
  date: string;
  completed_at: string;
  players: string[];
}

interface HistoricalSectionProps {
  historicalLists: HistoricalList[];
}

export function HistoricalSection({ historicalLists }: HistoricalSectionProps) {
  const [expanded, setExpanded] = useState(false);

  if (!historicalLists.length) return null;

  return (
    <DotaCard className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold" style={{color: 'var(--dota-bronze)'}}>
          📋 Histórico de Listas
        </h2>
        <button 
          onClick={() => setExpanded(!expanded)}
          className="text-sm px-3 py-1 rounded transition-colors"
          style={{
            color: 'var(--dota-bronze)',
            border: '1px solid var(--dota-border)'
          }}
        >
          {expanded ? 'Ocultar' : 'Ver Histórico'}
        </button>
      </div>
      
      {expanded && (
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {historicalLists.map((list) => (
            <div 
              key={list.id}
              className="flex justify-between items-center p-3 rounded"
              style={{
                background: 'rgba(212, 132, 42, 0.05)',
                border: '1px solid rgba(212, 132, 42, 0.1)'
              }}
            >
              <div>
                <div className="font-medium" style={{color: 'var(--dota-text-light)'}}>
                  {list.display_name} - {new Date(list.date).toLocaleDateString('pt-BR')}
                </div>
                <div className="text-sm" style={{color: 'var(--dota-text-muted)'}}>
                  {list.players.length > 0 ? list.players.join(', ') : 'Nenhum jogador'}
                </div>
              </div>
              <div className="text-right">
                <div className="px-2 py-1 rounded text-xs bg-blue-500 text-white">
                  Concluída
                </div>
                <div className="text-xs mt-1" style={{color: 'var(--dota-text-muted)'}}>
                  {list.players.length}/5 jogadores
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </DotaCard>
  );
}