interface DotaSelectProps {
  id?: string;
  name?: string;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  required?: boolean;
  children: React.ReactNode;
  className?: string;
}

export function DotaSelect({ 
  className = "",
  children,
  ...props 
}: DotaSelectProps) {
  return (
    <select
      className={`w-full px-4 py-3 rounded-lg dota-select ${className}`}
      {...props}
    >
      {children}
    </select>
  );
}