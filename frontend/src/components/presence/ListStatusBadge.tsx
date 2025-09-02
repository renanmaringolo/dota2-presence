interface ListStatusBadgeProps {
  status: 'open' | 'full';
}

export function ListStatusBadge({ status }: ListStatusBadgeProps) {
  const getStatusConfig = () => {
    switch (status) {
      case 'open':
        return {
          label: 'Aberta',
          className: 'bg-green-500 text-white'
        };
      case 'full':
        return {
          label: 'Cheia',
          className: 'bg-yellow-500 text-white'
        };
      default:
        return {
          label: 'Fechada',
          className: 'bg-red-500 text-white'
        };
    }
  };

  const config = getStatusConfig();

  return (
    <span className={`px-3 py-1 rounded-full text-sm font-medium ${config.className}`}>
      {config.label}
    </span>
  );
}