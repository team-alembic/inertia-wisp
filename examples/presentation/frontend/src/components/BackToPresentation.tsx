import { Link } from "@inertiajs/react";

export function BackToPresentation({ slideNumber }: { slideNumber: number }) {
  return (
    <div className="flex justify-center">
      <Link
        href={`/slides/${slideNumber}`}
        className="px-8 py-3 bg-white text-purple-700 font-semibold rounded-lg
                   hover:bg-purple-50 transition-colors shadow-lg"
      >
        ← Back to Presentation
      </Link>
    </div>
  );
}
