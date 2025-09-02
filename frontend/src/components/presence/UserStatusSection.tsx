import { DotaButton } from '@/components/ui';

interface UserStatus {
  can_join: boolean;
  reason?: string;
  confirmed_list?: string;
  position?: string;
  available_positions?: string[];
}

interface UserStatusSectionProps {
  userStatus: UserStatus;
  onCancel: () => void;
  loading: boolean;
}

export function UserStatusSection({ userStatus, onCancel, loading }: UserStatusSectionProps) {
  const getStatusMessage = () => {
    if (!userStatus.can_join) {
      switch (userStatus.reason) {
        case 'not_authenticated':
          return 'Faça login para participar';
        case 'not_eligible':
          return 'Seu rank não permite participar desta lista';
        case 'already_confirmed_today':
          return `Você já confirmou presença na ${userStatus.confirmed_list} na posição ${userStatus.position}`;
        case 'list_full':
          return 'Lista está cheia';
        default:
          return 'Não é possível participar desta lista';
      }
    }
    return null;
  };

  const statusMessage = getStatusMessage();
  const isUserConfirmed = userStatus.reason === 'already_confirmed_today';

  return (
    <div className="border-t pt-4" style={{borderColor: 'var(--dota-border)'}}>
      {isUserConfirmed ? (
        <div className="flex justify-between items-center">
          <span style={{color: 'var(--dota-text-light)'}}>
            ✅ Você confirmou presença na posição {userStatus.position}
          </span>
          <DotaButton
            onClick={onCancel}
            className="!w-auto px-4 py-2 text-sm !bg-red-600"
            loading={loading}
          >
            Cancelar
          </DotaButton>
        </div>
      ) : statusMessage ? (
        <div>
          <p style={{color: 'var(--dota-text-muted)'}}>
            {statusMessage}
          </p>
        </div>
      ) : (
        <div>
          <p style={{color: 'var(--dota-text-light)'}}>
            Selecione uma posição acima para confirmar sua presença
          </p>
        </div>
      )}
    </div>
  );
}