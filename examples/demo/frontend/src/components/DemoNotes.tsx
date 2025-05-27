interface DemoNotesProps {
  className?: string;
}

export function DemoNotes({ className = "" }: DemoNotesProps) {
  const notes = [
    "This demonstrates Inertia.js form handling with Gleam backend",
    "All navigation uses Inertia XHR requests (no full page reloads)",
    "Forms include validation and error handling",
    "Data persists only during the demo session (in-memory storage)"
  ];

  return (
    <div className={`bg-gray-50 px-6 py-4 border-t border-gray-200 ${className}`}>
      <h3 className="text-sm font-medium text-gray-900 mb-3">Demo Notes</h3>
      <div className="space-y-2 text-sm text-gray-600">
        {notes.map((note, index) => (
          <div key={index} className="flex items-start space-x-2">
            <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-2 flex-shrink-0"></div>
            <span>{note}</span>
          </div>
        ))}
      </div>
    </div>
  );
}