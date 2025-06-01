interface TagListProps {
  tags: string[];
  variant?: 'blue' | 'gray' | 'colored';
  prefix?: string;
  emptyMessage?: string;
}

export default function TagList({ 
  tags, 
  variant = 'blue', 
  prefix = '',
  emptyMessage = 'No tags specified.'
}: TagListProps) {
  const variantClasses = {
    'blue': 'bg-blue-100 text-blue-800',
    'gray': 'bg-gray-100 text-gray-800',
    'colored': 'bg-blue-100 text-blue-800' // Can be extended for multi-color logic
  };

  if (tags.length === 0) {
    return (
      <p className="text-gray-500 italic">
        {emptyMessage}
      </p>
    );
  }

  return (
    <div className="flex flex-wrap gap-2">
      {tags.map((tag: string, index: number) => (
        <span
          key={index}
          className={`px-3 py-1 ${variantClasses[variant]} text-sm rounded-full font-medium`}
        >
          {prefix}{tag}
        </span>
      ))}
    </div>
  );
}