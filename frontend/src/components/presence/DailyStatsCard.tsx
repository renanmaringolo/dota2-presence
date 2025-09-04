import { DotaCard } from '@/components/ui';

interface DailyStats {
  ancient_count: number;
  immortal_count: number;
  total_players_today: number;
  current_sequence: {
    ancient: number;
    immortal: number;
  };
}

interface DailyStatsCardProps {
  stats: DailyStats;
}

export function DailyStatsCard({ stats }: DailyStatsCardProps) {
  return (
    <DotaCard className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold" style={{color: 'var(--dota-bronze)'}}>
          📊 Estatísticas de Hoje
        </h2>
        <div className="text-sm" style={{color: 'var(--dota-text-muted)'}}>
          {new Date().toLocaleDateString('pt-BR')}
        </div>
      </div>
      
      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        <StatItem
          label="Listas Ancient"
          value={stats.ancient_count}
          sequence={stats.current_sequence.ancient}
          color="var(--dota-bronze)"
        />
        
        <StatItem
          label="Listas Immortal"
          value={stats.immortal_count}
          sequence={stats.current_sequence.immortal}
          color="var(--dota-gold)"
        />
        
        <StatItem
          label="Total de Jogadores"
          value={stats.total_players_today}
          color="var(--dota-text-light)"
        />
        
        <StatItem
          label="Listas Totais"
          value={stats.ancient_count + stats.immortal_count}
          color="var(--dota-text-light)"
        />
      </div>
    </DotaCard>
  );
}

interface StatItemProps {
  label: string;
  value: number;
  sequence?: number;
  color: string;
}

function StatItem({ label, value, sequence, color }: StatItemProps) {
  return (
    <div className="text-center">
      <div className="text-2xl font-bold mb-1" style={{color}}>
        {value}
      </div>
      <div className="text-sm" style={{color: 'var(--dota-text-muted)'}}>
        {label}
      </div>
      {sequence && sequence > 1 && (
        <div className="text-xs mt-1" style={{color}}>
          Lista atual #{sequence}
        </div>
      )}
    </div>
  );
}
