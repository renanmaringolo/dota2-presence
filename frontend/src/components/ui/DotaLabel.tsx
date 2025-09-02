interface DotaLabelProps {
  htmlFor?: string;
  children: React.ReactNode;
  className?: string;
}

export function DotaLabel({ 
  htmlFor, 
  children, 
  className = "" 
}: DotaLabelProps) {
  return (
    <label 
      htmlFor={htmlFor}
      className={`block text-sm font-medium mb-2 ${className}`}
      style={{color: 'var(--dota-text-light)'}}
    >
      {children}
    </label>
  );
}