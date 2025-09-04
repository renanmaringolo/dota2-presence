interface DotaButtonProps {
  type?: "button" | "submit" | "reset";
  disabled?: boolean;
  loading?: boolean;
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
}

export function DotaButton({ 
  type = "button",
  disabled = false,
  loading = false,
  children,
  onClick,
  className = ""
}: DotaButtonProps) {
  return (
    <button
      type={type}
      disabled={disabled || loading}
      onClick={onClick}
      className={`w-full py-3 px-4 rounded-lg dota-btn-primary text-lg font-semibold ${loading ? 'dota-loading' : ''} ${className}`}
    >
      {loading ? (
        <div className="flex items-center justify-center space-x-2">
          <div className="w-5 h-5 border-2 border-gray-900 border-t-transparent rounded-full animate-spin"></div>
          <span>{typeof children === 'string' ? `${children}...` : children}</span>
        </div>
      ) : children}
    </button>
  );
}
