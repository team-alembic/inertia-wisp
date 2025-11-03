import * as Travel from "../../lib/travel";
import { isEqual } from "@gleam/prelude.mjs";

export function TravelClassStep({
  data,
  setData,
  onSubmit,
  onBack,
  processing,
}: {
  data: Travel.BookingRequest;
  setData: (data: Travel.BookingRequest) => void;
  onSubmit: () => void;
  onBack: () => void;
  processing: boolean;
}) {
  const currentTravelClass = Travel.getTravelClass(data);
  return (
    <div className="space-y-6">
      <h3 className="text-2xl font-bold text-white mb-4">
        Step 4: Travel Class
      </h3>

      <div className="space-y-3">
        {[
          { value: new Travel.Economy(), label: "Economy", price: "$300" },
          { value: new Travel.Business(), label: "Business", price: "$800" },
          {
            value: new Travel.FirstClass(),
            label: "First Class",
            price: "$1,500",
          },
        ].map((option) => {
          const isSelected = isEqual(currentTravelClass, option.value);

          return (
            <button
              key={option.label}
              onClick={() => setData(Travel.setTravelClass(data, option.value))}
              className={`w-full p-4 rounded-lg border-2 transition ${
                isSelected
                  ? "border-white bg-white/20 text-white"
                  : "border-white/30 bg-white/10 text-white/80 hover:border-white/50"
              }`}
            >
              <div className="flex justify-between items-center">
                <span className="font-semibold text-lg">{option.label}</span>
                <span className="text-sm">from {option.price}</span>
              </div>
            </button>
          );
        })}
      </div>

      <div className="flex gap-4">
        <button
          onClick={onBack}
          disabled={processing}
          className="flex-1 bg-white/20 text-white py-3 rounded-lg font-semibold hover:bg-white/30 transition disabled:opacity-50"
        >
          ← Back
        </button>
        <button
          onClick={onSubmit}
          disabled={processing}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50"
        >
          {processing ? "Finding Deals..." : "Find Deals →"}
        </button>
      </div>
    </div>
  );
}
