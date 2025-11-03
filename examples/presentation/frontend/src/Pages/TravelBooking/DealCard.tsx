import * as Travel from "../../lib/travel";

export function DealCard({ deal }: { deal: Travel.Deal }) {
  return (
    <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 hover:bg-white/15 transition">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-xl font-bold text-white">
            {Travel.getAirline(deal)}
          </h3>
          <p className="text-white/60 text-sm">
            Flight {Travel.getFlightNumber(deal)}
          </p>
        </div>
        <div className="text-right">
          <p className="text-3xl font-bold text-white">
            ${Travel.getPrice(deal).toFixed(2)}
          </p>
          <p className="text-white/60 text-sm">total</p>
        </div>
      </div>

      <div className="flex gap-4 text-white/80 text-sm">
        <div>
          <span className="font-semibold">Duration:</span>{" "}
          {Travel.getDurationHours(deal)}h
        </div>
        <div>
          <span className="font-semibold">Stops:</span>{" "}
          {Travel.getStops(deal) === 0
            ? "Direct"
            : `${Travel.getStops(deal)} stop${Travel.getStops(deal) > 1 ? "s" : ""}`}
        </div>
      </div>

      <button className="w-full mt-4 bg-white text-purple-900 py-2 rounded-lg font-semibold hover:bg-purple-100 transition">
        Select Flight
      </button>
    </div>
  );
}
