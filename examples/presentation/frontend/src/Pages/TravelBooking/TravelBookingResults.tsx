import { Deferred } from "@inertiajs/react";
import * as Travel from "../../lib/travel";
import { BackToPresentation } from "../../components";
import { PageHeader } from "./PageHeader";
import { DealCard } from "./DealCard";

export function TravelBookingResults({
  booking,
  deals,
  infoMessage,
  onChangeDetails,
  onStartNewBooking,
}: {
  booking: Travel.BookingRequest;
  deals: Travel.Deal[] | null;
  infoMessage: string;
  onChangeDetails: () => void;
  onStartNewBooking: () => void;
}) {
  const travelClass = Travel.getTravelClass(booking);
  const travelClassName = Travel.travelClassToString(travelClass);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-800 to-pink-900 p-8">
      <div className="max-w-4xl mx-auto">
        <PageHeader title="Travel Booking Results" infoMessage={infoMessage} />

        {/* Booking Summary */}
        <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
          <h3 className="text-xl font-semibold text-white mb-4">
            Your Trip Details
          </h3>
          <div className="grid grid-cols-2 gap-4 text-white">
            <div>
              <p className="text-white/60 text-sm mb-1">From</p>
              <p className="text-lg font-semibold">
                {Travel.getOrigin(booking)}
              </p>
            </div>
            <div>
              <p className="text-white/60 text-sm mb-1">To</p>
              <p className="text-lg font-semibold">
                {Travel.getDestination(booking)}
              </p>
            </div>
            <div>
              <p className="text-white/60 text-sm mb-1">Departure Date</p>
              <p className="text-lg font-semibold">
                {new Date(Travel.getDepartureDate(booking)).toLocaleDateString(
                  "en-US",
                  {
                    weekday: "short",
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                  },
                )}
              </p>
            </div>
            <div>
              <p className="text-white/60 text-sm mb-1">Passengers & Class</p>
              <p className="text-lg font-semibold">
                {Travel.getPassengers(booking)} × {travelClassName}
              </p>
            </div>
          </div>
        </div>

        <Deferred
          data="deals"
          fallback={
            <div className="bg-white/10 backdrop-blur-md rounded-lg p-8 mb-6 text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
              <p className="text-white text-lg">
                Searching for the best deals...
              </p>
            </div>
          }
        >
          {deals && (
            <div className="space-y-4 mb-6">
              {deals.map((deal, index) => (
                <DealCard key={index} deal={deal} />
              ))}
            </div>
          )}
        </Deferred>

        <div className="flex gap-4 justify-center">
          <button
            onClick={onChangeDetails}
            className="bg-white/20 text-white px-6 py-3 rounded-lg font-semibold hover:bg-white/30 transition"
          >
            ← Change Travel Details
          </button>
          <button
            onClick={onStartNewBooking}
            className="bg-white text-purple-900 px-6 py-3 rounded-lg font-semibold hover:bg-purple-100 transition"
          >
            Start New Booking
          </button>
        </div>

        <div className="mt-8">
          <BackToPresentation slideNumber={14} />
        </div>
      </div>
    </div>
  );
}
