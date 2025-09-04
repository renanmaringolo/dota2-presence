interface DotaCheckboxProps {
  checked?: boolean;
  onChange?: () => void;
  label: string;
  className?: string;
}

export function DotaCheckbox({ 
  checked, 
  onChange, 
  label, 
  className = "" 
}: DotaCheckboxProps) {
  return (
    <label className={`flex items-center space-x-3 cursor-pointer ${className}`}>
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}
        className="dota-checkbox"
      />
      <span className="text-sm" style={{color: 'var(--dota-text-light)'}}>
        {label}
      </span>
    </label>
  );
}
