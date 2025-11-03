import * as Travel from "../../lib/travel";

export function DestinationStep({
  data,
  setData,
  onNext,
  onBack,
}: {
  data: Travel.BookingRequest;
  setData: (data: Travel.BookingRequest) => void;
  onNext: () => void;
  onBack: () => void;
}) {
  return (
    <div className="space-y-6">
      <h3 className="text-2xl font-bold text-white mb-4">
        Step 2: Destination
      </h3>

      <div>
        <label className="block text-white font-semibold mb-2">
          Destination
        </label>
        <input
          type="text"
          value={Travel.getDestination(data)}
          onChange={(e) => setData(Travel.setDestination(data, e.target.value))}
          placeholder="e.g., London (LHR)"
          className="w-full px-4 py-3 rounded-lg bg-white/20 text-white placeholder-white/50 border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
        />
      </div>

      <div className="flex gap-4">
        <button
          onClick={onBack}
          className="flex-1 bg-white/20 text-white py-3 rounded-lg font-semibold hover:bg-white/30 transition"
        >
          ← Back
        </button>
        <button
          onClick={onNext}
          disabled={!Travel.getDestination(data)}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next →
        </button>
      </div>
    </div>
  );
}
