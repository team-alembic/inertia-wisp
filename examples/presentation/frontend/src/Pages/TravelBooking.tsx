import { useState } from "react";
import { router } from "@inertiajs/react";
import * as Travel from "../lib/travel";
import {
  Option$isSome as isSome,
  Option$Some$0 as unwrapSome,
} from "@gleam/gleam_stdlib/gleam/option.mjs";
import { BackToPresentation } from "../components";
import { decodeProps } from "../lib/decodeProps";
import { useGleamForm } from "../hooks/useGleamForm";
import {
  Step,
  StepProgressIndicator,
} from "./TravelBooking/StepProgressIndicator";
import { DepartureDetailsStep } from "./TravelBooking/DepartureDetailsStep";
import { DestinationStep } from "./TravelBooking/DestinationStep";
import { PassengersStep } from "./TravelBooking/PassengersStep";
import { TravelClassStep } from "./TravelBooking/TravelClassStep";
import { TravelBookingResults } from "./TravelBooking/TravelBookingResults";
import { PageHeader } from "./TravelBooking/PageHeader";
import { DemoExplanation } from "./TravelBooking/DemoExplanation";

function TravelBooking(props: Travel.TravelBookingProps) {
  const booking = Travel.getBooking(props);
  const deals = Travel.getDeals(props);
  const info_message = Travel.getInfoMessage(props);

  // If no booking exists yet, start at step 1. Otherwise, show results (null)
  const [currentStep, setCurrentStep] = useState<Step | null>(
    isSome(booking) ? null : Step.DepartureDetails,
  );

  // Initialize with type-safe Gleam BookingRequest
  const initialBooking = Travel.createBookingRequest(
    "",
    "",
    "",
    1,
    new Travel.Economy(),
  );

  const { data, setData, post, processing } = useGleamForm(
    initialBooking,
    Travel.encodeBookingRequest,
  );

  const handleChangeDetails = () => {
    if (isSome(booking)) {
      const bookingData = unwrapSome(booking);
      // Simply set the Gleam type directly - no conversion needed!
      setData(bookingData);
      setCurrentStep(Step.DepartureDetails);
    }
  };

  const handleSubmit = () => {
    setCurrentStep(null); // Clear step to show results
    post("/travel/booking");
  };

  const handleStartNewBooking = () => {
    // Navigate to clean URL, which will reset server-side state
    router.get("/travel/booking");
  };

  const canProceed = (step: Step): boolean => {
    switch (step) {
      case Step.DepartureDetails:
        return (
          Travel.getDepartureDate(data) !== "" && Travel.getOrigin(data) !== ""
        );
      case Step.Destination:
        return Travel.getDestination(data) !== "";
      case Step.Passengers:
        return Travel.getPassengers(data) > 0;
      case Step.TravelClass:
        return true;
    }
  };

  // Show results if we have a booking and currentStep is null (not editing)
  if (isSome(booking) && currentStep === null) {
    const bookingData = unwrapSome(booking);
    const dealsArray = deals && isSome(deals) ? [...unwrapSome(deals)] : null;

    return (
      <TravelBookingResults
        booking={bookingData}
        deals={dealsArray}
        infoMessage={info_message}
        onChangeDetails={handleChangeDetails}
        onStartNewBooking={handleStartNewBooking}
      />
    );
  }

  // Show multi-step form
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-purple-800 to-pink-900 p-8">
      <div className="max-w-2xl mx-auto">
        <PageHeader title="Book Your Flight" infoMessage={info_message} />

        <StepProgressIndicator
          currentStep={currentStep}
          canProceed={canProceed}
          onStepClick={setCurrentStep}
        />

        {/* Form Steps */}
        <div className="bg-white/10 backdrop-blur-md rounded-lg p-8">
          {currentStep === Step.DepartureDetails && (
            <DepartureDetailsStep
              data={data}
              setData={setData}
              onNext={() => setCurrentStep(Step.Destination)}
            />
          )}
          {currentStep === Step.Destination && (
            <DestinationStep
              data={data}
              setData={setData}
              onNext={() => setCurrentStep(Step.Passengers)}
              onBack={() => setCurrentStep(Step.DepartureDetails)}
            />
          )}
          {currentStep === Step.Passengers && (
            <PassengersStep
              data={data}
              setData={setData}
              onNext={() => setCurrentStep(Step.TravelClass)}
              onBack={() => setCurrentStep(Step.Destination)}
            />
          )}
          {currentStep === Step.TravelClass && (
            <TravelClassStep
              data={data}
              setData={setData}
              onSubmit={handleSubmit}
              onBack={() => setCurrentStep(Step.Passengers)}
              processing={processing}
            />
          )}
        </div>

        <DemoExplanation />

        <div className="mt-8">
          <BackToPresentation slideNumber={14} />
        </div>
      </div>
    </div>
  );
}

export default decodeProps(TravelBooking, Travel.decodeTravelBookingProps());
