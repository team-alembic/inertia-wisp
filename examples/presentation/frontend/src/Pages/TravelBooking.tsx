import { useState } from "react";
import { router, Deferred } from "@inertiajs/react";
import {
  type TravelBookingProps,
  type BookingRequest,
  type Deal,
  decodeTravelBookingProps,
  getBooking,
  getDeals,
  getInfoMessage,
  createBookingRequest,
  getDepartureDate,
  getOrigin,
  getDestination,
  getPassengers,
  getTravelClass,
  Economy,
  Business,
  FirstClass,
  getAirline,
  getFlightNumber,
  getPrice,
  getDurationHours,
  getStops,
} from "../lib/travel";
import {
  Option$isSome as isSome,
  Option$Some$0 as unwrapSome,
} from "@gleam/gleam_stdlib/gleam/option.mjs";
import { BackToPresentation } from "../components";
import { decodeProps } from "../lib/decodeProps";

function TravelBooking(props: TravelBookingProps) {
  const booking = getBooking(props);
  const deals = getDeals(props);
  const info_message = getInfoMessage(props);

  const [currentStep, setCurrentStep] = useState(1);
  const [isEditingBooking, setIsEditingBooking] = useState(false);
  const [formData, setFormData] = useState<BookingRequest>(
    createBookingRequest("", "", "", 1, new Economy()),
  );

  const handleChangeDetails = () => {
    if (isSome(booking)) {
      setFormData(unwrapSome(booking));
      setCurrentStep(1);
      setIsEditingBooking(true);
    }
  };

  const handleSubmit = () => {
    // Convert Gleam TravelClass to string for JSON
    const travelClass = getTravelClass(formData);
    const travelClassString =
      travelClass instanceof Business
        ? "business"
        : travelClass instanceof FirstClass
          ? "first_class"
          : "economy";

    // Reset editing state so we show results after redirect
    setIsEditingBooking(false);

    router.post("/travel/booking", {
      departure_date: getDepartureDate(formData),
      origin: getOrigin(formData),
      destination: getDestination(formData),
      passengers: getPassengers(formData),
      travel_class: travelClassString,
    });
  };

  const canProceed = (step: number): boolean => {
    switch (step) {
      case 1:
        return getDepartureDate(formData) !== "" && getOrigin(formData) !== "";
      case 2:
        return getDestination(formData) !== "";
      case 3:
        return getPassengers(formData) > 0;
      case 4:
        return true;
      default:
        return false;
    }
  };

  // Show results if we have a booking and are NOT editing
  if (isSome(booking) && !isEditingBooking) {
    const bookingData = unwrapSome(booking);
    const travelClass = getTravelClass(bookingData);
    const travelClassName =
      travelClass instanceof Business
        ? "Business"
        : travelClass instanceof FirstClass
          ? "First Class"
          : "Economy";

    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-800 to-pink-900 p-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
            <h2 className="text-3xl font-bold text-white mb-2">
              Travel Booking Results
            </h2>
            <p className="text-white/80">{info_message}</p>
          </div>

          {/* Booking Summary */}
          <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
            <h3 className="text-xl font-semibold text-white mb-4">
              Your Trip Details
            </h3>
            <div className="grid grid-cols-2 gap-4 text-white">
              <div>
                <p className="text-white/60 text-sm mb-1">From</p>
                <p className="text-lg font-semibold">
                  {getOrigin(bookingData)}
                </p>
              </div>
              <div>
                <p className="text-white/60 text-sm mb-1">To</p>
                <p className="text-lg font-semibold">
                  {getDestination(bookingData)}
                </p>
              </div>
              <div>
                <p className="text-white/60 text-sm mb-1">Departure Date</p>
                <p className="text-lg font-semibold">
                  {new Date(getDepartureDate(bookingData)).toLocaleDateString(
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
                  {getPassengers(bookingData)} × {travelClassName}
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
            {deals && isSome(deals) && (
              <div className="space-y-4 mb-6">
                {[...unwrapSome(deals)].map((deal, index) => (
                  <DealCard key={index} deal={deal} />
                ))}
              </div>
            )}
          </Deferred>

          <div className="flex gap-4 justify-center">
            <button
              onClick={handleChangeDetails}
              className="bg-white/20 text-white px-6 py-3 rounded-lg font-semibold hover:bg-white/30 transition"
            >
              ← Change Travel Details
            </button>
            <button
              onClick={() => window.location.reload()}
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

  // Show multi-step form
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-800 to-pink-900 p-8">
      <div className="max-w-2xl mx-auto">
        <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
          <h2 className="text-3xl font-bold text-white mb-2">
            Book Your Flight
          </h2>
          <p className="text-white/80">{info_message}</p>
        </div>

        {/* Step Progress Indicator */}
        <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
          <div className="flex justify-between items-center">
            {[1, 2, 3, 4].map((step) => (
              <div key={step} className="flex items-center flex-1">
                <button
                  onClick={() => setCurrentStep(step)}
                  disabled={step > 1 && !canProceed(step - 1)}
                  className={`w-10 h-10 rounded-full flex items-center justify-center font-bold transition ${
                    step === currentStep
                      ? "bg-white text-purple-900"
                      : step < currentStep
                        ? "bg-purple-400 text-white hover:bg-purple-300 cursor-pointer"
                        : "bg-white/20 text-white/50 cursor-not-allowed"
                  }`}
                >
                  {step}
                </button>
                {step < 4 && (
                  <div
                    className={`flex-1 h-1 mx-2 ${
                      step < currentStep ? "bg-purple-400" : "bg-white/20"
                    }`}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Form Steps */}
        <div className="bg-white/10 backdrop-blur-md rounded-lg p-8">
          {currentStep === 1 && (
            <Step1
              formData={formData}
              onChange={setFormData}
              onNext={() => setCurrentStep(2)}
            />
          )}
          {currentStep === 2 && (
            <Step2
              formData={formData}
              onChange={setFormData}
              onNext={() => setCurrentStep(3)}
              onBack={() => setCurrentStep(1)}
            />
          )}
          {currentStep === 3 && (
            <Step3
              formData={formData}
              onChange={setFormData}
              onNext={() => setCurrentStep(4)}
              onBack={() => setCurrentStep(2)}
            />
          )}
          {currentStep === 4 && (
            <Step4
              formData={formData}
              onChange={setFormData}
              onSubmit={handleSubmit}
              onBack={() => setCurrentStep(3)}
            />
          )}
        </div>

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

        <div className="mt-8">
          <BackToPresentation slideNumber={14} />
        </div>
      </div>
    </div>
  );
}

function Step1({
  formData,
  onChange,
  onNext,
}: {
  formData: BookingRequest;
  onChange: (data: BookingRequest) => void;
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
          value={getDepartureDate(formData)}
          onChange={(e) =>
            onChange(
              createBookingRequest(
                e.target.value,
                getOrigin(formData),
                getDestination(formData),
                getPassengers(formData),
                getTravelClass(formData),
              ),
            )
          }
          className="w-full px-4 py-3 rounded-lg bg-white/20 text-white placeholder-white/50 border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
          min={new Date().toISOString().split("T")[0]}
        />
      </div>

      <div>
        <label className="block text-white font-semibold mb-2">Origin</label>
        <input
          type="text"
          value={getOrigin(formData)}
          onChange={(e) =>
            onChange(
              createBookingRequest(
                getDepartureDate(formData),
                e.target.value,
                getDestination(formData),
                getPassengers(formData),
                getTravelClass(formData),
              ),
            )
          }
          placeholder="e.g., New York (JFK)"
          className="w-full px-4 py-3 rounded-lg bg-white/20 text-white placeholder-white/50 border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
        />
      </div>

      <button
        onClick={onNext}
        disabled={!getDepartureDate(formData) || !getOrigin(formData)}
        className="w-full bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Next →
      </button>
    </div>
  );
}

function Step2({
  formData,
  onChange,
  onNext,
  onBack,
}: {
  formData: BookingRequest;
  onChange: (data: BookingRequest) => void;
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
          value={getDestination(formData)}
          onChange={(e) =>
            onChange(
              createBookingRequest(
                getDepartureDate(formData),
                getOrigin(formData),
                e.target.value,
                getPassengers(formData),
                getTravelClass(formData),
              ),
            )
          }
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
          disabled={!getDestination(formData)}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next →
        </button>
      </div>
    </div>
  );
}

function Step3({
  formData,
  onChange,
  onNext,
  onBack,
}: {
  formData: BookingRequest;
  onChange: (data: BookingRequest) => void;
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
          value={getPassengers(formData)}
          onChange={(e) =>
            onChange(
              createBookingRequest(
                getDepartureDate(formData),
                getOrigin(formData),
                getDestination(formData),
                parseInt(e.target.value) || 1,
                getTravelClass(formData),
              ),
            )
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
          disabled={getPassengers(formData) < 1}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next →
        </button>
      </div>
    </div>
  );
}

function Step4({
  formData,
  onChange,
  onSubmit,
  onBack,
}: {
  formData: BookingRequest;
  onChange: (data: BookingRequest) => void;
  onSubmit: () => void;
  onBack: () => void;
}) {
  const currentTravelClass = getTravelClass(formData);

  return (
    <div className="space-y-6">
      <h3 className="text-2xl font-bold text-white mb-4">
        Step 4: Travel Class
      </h3>

      <div className="space-y-3">
        {[
          { value: new Economy(), label: "Economy", price: "$300" },
          { value: new Business(), label: "Business", price: "$800" },
          { value: new FirstClass(), label: "First Class", price: "$1,500" },
        ].map((option) => {
          const isSelected =
            (option.value instanceof Economy &&
              currentTravelClass instanceof Economy) ||
            (option.value instanceof Business &&
              currentTravelClass instanceof Business) ||
            (option.value instanceof FirstClass &&
              currentTravelClass instanceof FirstClass);

          return (
            <button
              key={option.label}
              onClick={() =>
                onChange(
                  createBookingRequest(
                    getDepartureDate(formData),
                    getOrigin(formData),
                    getDestination(formData),
                    getPassengers(formData),
                    option.value,
                  ),
                )
              }
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
          className="flex-1 bg-white/20 text-white py-3 rounded-lg font-semibold hover:bg-white/30 transition"
        >
          ← Back
        </button>
        <button
          onClick={onSubmit}
          className="flex-1 bg-white text-purple-900 py-3 rounded-lg font-semibold hover:bg-purple-100 transition"
        >
          Find Deals →
        </button>
      </div>
    </div>
  );
}

function DealCard({ deal }: { deal: Deal }) {
  return (
    <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 hover:bg-white/15 transition">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-xl font-bold text-white">{getAirline(deal)}</h3>
          <p className="text-white/60 text-sm">
            Flight {getFlightNumber(deal)}
          </p>
        </div>
        <div className="text-right">
          <p className="text-3xl font-bold text-white">
            ${getPrice(deal).toFixed(2)}
          </p>
          <p className="text-white/60 text-sm">total</p>
        </div>
      </div>

      <div className="flex gap-4 text-white/80 text-sm">
        <div>
          <span className="font-semibold">Duration:</span>{" "}
          {getDurationHours(deal)}h
        </div>
        <div>
          <span className="font-semibold">Stops:</span>{" "}
          {getStops(deal) === 0
            ? "Direct"
            : `${getStops(deal)} stop${getStops(deal) > 1 ? "s" : ""}`}
        </div>
      </div>

      <button className="w-full mt-4 bg-white text-purple-900 py-2 rounded-lg font-semibold hover:bg-purple-100 transition">
        Select Flight
      </button>
    </div>
  );
}

export default decodeProps(TravelBooking, decodeTravelBookingProps());
