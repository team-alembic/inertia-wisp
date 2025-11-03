import * as Travel from "../../lib/travel";

export function DepartureDetailsStep({
  data,
  setData,
  onNext,
}: {
  data: Travel.BookingRequest;
  setData: (data: Travel.BookingRequest) => void;
  onNext: () => void;
}) {
  return (
    <div className="space-y-6">
      <h3 className="text-2xl font-bold text-white mb-4">
        Step 1: Departure Details
      </h3>

      <div>
        <label className="block text-white font-semibold mb-2">
          Departure Date
        </label>
        <input
          type="date"
          value={Travel.getDepartureDate(data)}
          onChange={(e) =>
            setData(Travel.setDepartureDate(data, e.target.value))
          }
          className="w-full px-4 py-3 rounded-lg bg-white/20 text-white placeholder-white/50 border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
          min={new Date().toISOString().split("T")[0]}
        />
      </div>

      <div>
        <label className="block text-white font-semibold mb-2">Origin</label>
        <input
          type="text"
          value={Travel.getOrigin(data)}
          onChange={(e) => setData(Travel.setOrigin(data, e.target.value))}
          placeholder="e.g., New York (JFK)"
          className="w-full px-4 py-3 rounded-lg bg-white/20 text-white placeholder-white/50 border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
        />
      </div>

      <button
        onClick={onNext}
        disabled={!Travel.getDepartureDate(data) || !Travel.getOrigin(data)}
        className="w-full bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Next →
      </button>
    </div>
  );
}
