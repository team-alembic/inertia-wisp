export enum Step {
  DepartureDetails = 1,
  Destination = 2,
  Passengers = 3,
  TravelClass = 4,
}

export function StepProgressIndicator({
  currentStep,
  canProceed,
  onStepClick,
}: {
  currentStep: Step | null;
  canProceed: (step: Step) => boolean;
  onStepClick: (step: Step) => void;
}) {
  const steps = [
    Step.DepartureDetails,
    Step.Destination,
    Step.Passengers,
    Step.TravelClass,
  ];

  // If currentStep is null, we're showing results, not in the form
  if (currentStep === null) {
    return null;
  }

  return (
    <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
      <div className="flex justify-between items-center">
        {steps.map((step) => (
          <div key={step} className="flex items-center flex-1">
            <button
              onClick={() => onStepClick(step)}
              disabled={step > Step.DepartureDetails && !canProceed(step - 1)}
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
            {step < Step.TravelClass && (
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
  );
}
