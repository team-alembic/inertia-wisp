interface ValidationRule {
  field: string;
  rule: string;
}

interface ValidationRulesTipProps {
  rules: ValidationRule[];
}

export function ValidationRulesTip({ rules }: ValidationRulesTipProps) {
  return (
    <div className="mt-8 p-4 bg-purple-50 rounded-lg border-2 border-purple-200">
      <h3 className="text-sm font-bold text-purple-900 mb-2">
        💡 Validation Rules
      </h3>
      <ul className="text-sm text-purple-800 space-y-1">
        {rules.map((rule, index) => (
          <li key={index}>
            • <strong>{rule.field}:</strong> {rule.rule}
          </li>
        ))}
      </ul>
    </div>
  );
}
