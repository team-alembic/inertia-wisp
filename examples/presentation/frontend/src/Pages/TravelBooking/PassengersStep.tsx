import * as Travel from "../../lib/travel";

export function PassengersStep({
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
        Step 3: Number of Passengers
      </h3>

      <div>
        <label className="block text-white font-semibold mb-2">
          Passengers
        </label>
        <input
          type="number"
          value={Travel.getPassengers(data)}
          onChange={(e) =>
            setData(Travel.setPassengers(data, parseInt(e.target.value) || 1))
          }
          min="1"
          max="10"
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
          disabled={Travel.getPassengers(data) < 1}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next →
        </button>
      </div>
    </div>
  );
}
