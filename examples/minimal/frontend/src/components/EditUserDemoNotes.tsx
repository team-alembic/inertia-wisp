interface EditUserDemoNotesProps {
  className?: string;
}

export function EditUserDemoNotes({ className = "" }: EditUserDemoNotesProps) {
  const notes = [
    "Form is pre-populated with existing user data",
    "Same validation rules apply as create form",
    "Email uniqueness check excludes current user",
    "Successful update redirects to user detail page",
    "Validation errors preserve form state"
  ];

  return (
    <div className={`bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-t border-gray-200 ${className}`}>
      <h4 className="text-sm font-medium text-gray-900 mb-3">Edit Form Demo</h4>
      <div className="space-y-2 text-xs text-gray-600">
        {notes.map((note, index) => (
          <div key={index} className="flex items-start space-x-2">
            <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
            <span>{note}</span>
          </div>
        ))}
      </div>
    </div>
  );
}