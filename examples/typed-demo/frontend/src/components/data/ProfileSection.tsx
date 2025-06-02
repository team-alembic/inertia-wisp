interface ProfileField {
  label: string;
  value: string;
}

interface ProfileSectionProps {
  title: string;
  fields: ProfileField[];
}

export default function ProfileSection({ title, fields }: ProfileSectionProps) {
  return (
    <div>
      <h2 className="text-xl font-semibold text-gray-800 mb-4">
        {title}
      </h2>
      <div className="space-y-3">
        {fields.map((field, index) => (
          <div key={index}>
            <span className="text-sm font-medium text-gray-500">
              {field.label}
            </span>
            <p className="text-gray-900">{field.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}