export function DemoExplanation() {
  return (
    <div className="mt-6 bg-white/10 backdrop-blur-md rounded-lg p-4">
      <h3 className="text-white font-semibold mb-2">
        💡 What This Demo Shows:
      </h3>
      <ul className="text-white/80 text-sm space-y-1">
        <li>
          • <strong>Client-side state:</strong> All 4 steps managed in React
          with useState
        </li>
        <li>
          • <strong>Server simplicity:</strong> Backend only handles final
          submission
        </li>
        <li>
          • <strong>Step navigation:</strong> Users can go back and modify
          previous steps
        </li>
        <li>
          • <strong>Deferred props:</strong> Deals load after submission to
          simulate external API
        </li>
      </ul>
    </div>
  );
}
