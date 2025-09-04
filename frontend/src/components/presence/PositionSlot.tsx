interface ConfirmedPlayer {
  position: string;
  user: {
    nickname: string;
    rank: string;
    confirmed_at: string;
  };
}

interface PositionSlotProps {
  position: string;
  confirmedPlayer?: ConfirmedPlayer;
  isAvailable: boolean;
  isUserConfirmed: boolean;
  canConfirm: boolean;
  onConfirm: () => void;
  loading: boolean;
  theme: 'bronze' | 'gold';
}

export function PositionSlot({
  position,
  confirmedPlayer,
  isAvailable,
  isUserConfirmed,
  canConfirm,
  onConfirm,
  loading,
  theme
}: PositionSlotProps) {
  const getSlotContent = () => {
    if (confirmedPlayer) {
      return (
        <div className="text-center">
          <div className="text-sm font-medium" style={{color: 'var(--dota-text-light)'}}>
            {confirmedPlayer.user.nickname}
          </div>
          <div className="text-xs" style={{color: 'var(--dota-text-muted)'}}>
            {confirmedPlayer.user.rank}
          </div>
          {isUserConfirmed && (
            <div className="text-xs mt-1 text-green-400">
              ✓ Você
            </div>
          )}
        </div>
      );
    }
    
    if (canConfirm) {
      return (
        <button
          onClick={onConfirm}
          disabled={loading}
          className="w-full h-full flex items-center justify-center text-sm font-medium transition-all hover:scale-105 disabled:opacity-50"
          style={{color: theme === 'bronze' ? 'var(--dota-bronze)' : 'var(--dota-gold)'}}
        >
          {loading ? '...' : 'Confirmar'}
        </button>
      );
    }
    
    return (
      <div className="text-center">
        <div className="text-sm" style={{color: 'var(--dota-text-muted)'}}>
          Indisponível
        </div>
      </div>
    );
  };

  const getSlotStyles = () => {
    const baseStyles = "relative h-20 rounded-lg border-2 flex items-center justify-center transition-all";
    
    if (confirmedPlayer) {
      if (isUserConfirmed) {
        return `${baseStyles} bg-green-500/20 border-green-500/50`;
      }
      return `${baseStyles} bg-blue-500/20 border-blue-500/50`;
    }
    
    if (canConfirm) {
      return `${baseStyles} border-dashed cursor-pointer hover:bg-orange-500/10 hover:border-orange-500/70`;
    }
    
    return `${baseStyles} opacity-50 bg-gray-500/10 border-gray-500/30`;
  };

  return (
    <div className={getSlotStyles()}>
      {/* Position Label */}
      <div className="absolute top-2 left-2 text-xs font-bold" style={{
        color: theme === 'bronze' ? 'var(--dota-bronze)' : 'var(--dota-gold)'
      }}>
        {position}
      </div>
      
      {getSlotContent()}
    </div>
  );
}
