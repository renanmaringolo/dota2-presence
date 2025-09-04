import { DotaCard, DotaButton } from '@/components/ui';
import { PositionSlot } from './PositionSlot';
import { UserStatusSection } from './UserStatusSection';
import { ListStatusBadge } from './ListStatusBadge';

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

interface CurrentListCardProps {
  title: string;
  subtitle: string;
  listData: CurrentListData;
  onConfirmPosition: (position: string) => void;
  onCancelPresence: () => void;
  loading: boolean;
  theme: 'bronze' | 'gold';
}

export function CurrentListCard({
  title,
  subtitle,
  listData,
  onConfirmPosition,
  onCancelPresence,
  loading,
  theme
}: CurrentListCardProps) {
  const themeColors = {
    bronze: {
      primary: 'var(--dota-bronze)',
      secondary: 'var(--dota-copper)',
      bg: 'rgba(212, 132, 42, 0.1)',
      border: 'rgba(212, 132, 42, 0.3)'
    },
    gold: {
      primary: 'var(--dota-gold)',
      secondary: 'var(--dota-dark-gold)', 
      bg: 'rgba(255, 215, 0, 0.1)',
      border: 'rgba(255, 215, 0, 0.3)'
    }
  };

  const colors = themeColors[theme];

  return (
    <DotaCard className="p-6 fade-in-up">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-2xl font-bold" style={{color: colors.primary}}>
            {title}
          </h2>
          <p className="text-sm mb-2" style={{color: 'var(--dota-text-muted)'}}>
            {subtitle}
          </p>
          
          {/* Lista atual info */}
          <div className="flex items-center space-x-3">
            <span className="text-lg font-medium" style={{color: colors.primary}}>
              {listData.display_name}
            </span>
            
            {listData.sequence_number > 1 && (
              <span 
                className="text-xs px-2 py-1 rounded font-medium"
                style={{
                  background: colors.bg,
                  color: colors.primary,
                  border: `1px solid ${colors.border}`
                }}
              >
                🔥 Alta demanda!
              </span>
            )}
          </div>
        </div>
        
        <ListStatusBadge status={listData.status} />
      </div>

      {/* Grid de Posições */}
      <div className="grid grid-cols-5 gap-4 mb-6">
        {['P1', 'P2', 'P3', 'P4', 'P5'].map(position => {
          const confirmedPlayer = listData.confirmed_players.find(p => p.position === position);
          const isAvailable = listData.available_positions.includes(position);
          const isUserConfirmed = listData.user_status.reason === 'already_confirmed_today' && 
                                  listData.user_status.position === position;

          return (
            <PositionSlot
              key={position}
              position={position}
              confirmedPlayer={confirmedPlayer}
              isAvailable={isAvailable}
              isUserConfirmed={isUserConfirmed}
              canConfirm={listData.user_status.can_join && isAvailable}
              onConfirm={() => onConfirmPosition(position)}
              loading={loading}
              theme={theme}
            />
          );
        })}
      </div>

      {/* User Status Section */}
      <UserStatusSection
        userStatus={listData.user_status}
        onCancel={onCancelPresence}
        loading={loading}
      />
    </DotaCard>
  );
}
