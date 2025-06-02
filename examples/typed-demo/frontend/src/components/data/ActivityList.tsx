interface ActivityItem {
  id: string;
  primary: string;
  secondary?: string;
  avatar?: string;
}

interface ActivityListProps {
  items: ActivityItem[];
  emptyMessage: string;
  showBadge?: boolean;
  badgeText?: string;
}

export default function ActivityList({ 
  items, 
  emptyMessage, 
  showBadge = true,
  badgeText = 'New'
}: ActivityListProps) {
  if (items.length === 0) {
    return (
      <p className="text-gray-500 italic text-center py-4">
        {emptyMessage}
      </p>
    );
  }

  return (
    <div className="space-y-3">
      {items.map((item) => (
        <div
          key={item.id}
          className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
        >
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white text-sm font-medium">
              {item.avatar || item.primary.charAt(0).toUpperCase()}
            </div>
            <div>
              <span className="text-gray-900 font-medium">{item.primary}</span>
              {item.secondary && (
                <p className="text-gray-600 text-sm">{item.secondary}</p>
              )}
            </div>
          </div>
          {showBadge && (
            <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">
              {badgeText}
            </span>
          )}
        </div>
      ))}
    </div>
  );
}