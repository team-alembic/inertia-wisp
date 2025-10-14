import { Deferred } from "@inertiajs/react";

interface DeferredInfoBadgeProps {
  demo_info?: string;
}

export function DeferredInfoBadge({ demo_info }: DeferredInfoBadgeProps) {
  return (
    <Deferred
      data="demo_info"
      fallback={
        <div className="mb-6 bg-yellow-500/20 border border-yellow-400 rounded-lg p-4 animate-pulse">
          <p className="text-yellow-100 font-mono text-sm">
            <span className="font-bold">DeferProp:</span> Loading...
          </p>
          <p className="text-yellow-200 text-xs mt-1">
            ⏳ This DeferProp loads in a separate request after the page
            renders!
          </p>
        </div>
      }
    >
      <div className="mb-6 bg-green-500/20 border border-green-400 rounded-lg p-4">
        <p className="text-green-100 font-mono text-sm">
          <span className="font-bold">DeferProp:</span> {demo_info}
        </p>
        <p className="text-green-200 text-xs mt-1">
          ✅ This DeferProp loaded separately after the initial page load!
        </p>
      </div>
    </Deferred>
  );
}
