interface StatusIndicatorProps {
  label: string;
  status: string;
  variant: 'green' | 'blue' | 'purple' | 'red';
}

export default function StatusIndicator({ label, status, variant }: StatusIndicatorProps) {
  const variantClasses = {
    'green': {
      bg: 'bg-green-50',
      dot: 'bg-green-500',
      text: 'text-green-700'
    },
    'blue': {
      bg: 'bg-blue-50',
      dot: 'bg-blue-500',
      text: 'text-blue-700'
    },
    'purple': {
      bg: 'bg-purple-50',
      dot: 'bg-purple-500',
      text: 'text-purple-700'
    },
    'red': {
      bg: 'bg-red-50',
      dot: 'bg-red-500',
      text: 'text-red-700'
    }
  };

  const classes = variantClasses[variant];

  return (
    <div className={`flex items-center justify-between p-4 ${classes.bg} rounded-lg`}>
      <div className="flex items-center space-x-3">
        <div className={`w-3 h-3 ${classes.dot} rounded-full`}></div>
        <span className="font-medium text-gray-900">{label}</span>
      </div>
      <span className={`${classes.text} font-semibold`}>{status}</span>
    </div>
  );
}