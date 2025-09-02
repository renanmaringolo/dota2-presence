interface DotaCardProps {
  children: React.ReactNode;
  className?: string;
}

export function DotaCard({ children, className = "" }: DotaCardProps) {
  return (
    <div className={`dota-card rounded-xl ${className}`}>
      {children}
    </div>
  );
}