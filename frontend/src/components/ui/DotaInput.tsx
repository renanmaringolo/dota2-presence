interface DotaInputProps {
  type?: string;
  id?: string;
  name?: string;
  value?: string | number;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
  required?: boolean;
  placeholder?: string;
  min?: string;
  max?: string;
  className?: string;
}

export function DotaInput({ 
  type = "text", 
  className = "",
  ...props 
}: DotaInputProps) {
  return (
    <input
      type={type}
      className={`w-full px-4 py-3 rounded-lg dota-input ${className}`}
      {...props}
    />
  );
}
