interface PaginationControlsProps {
  page: number;
  total_pages: number;
  onPrevious: () => void;
  onNext: () => void;
}

export function PaginationControls({
  page,
  total_pages,
  onPrevious,
  onNext,
}: PaginationControlsProps) {
  return (
    <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
      <div className="flex items-center justify-between">
        <button
          onClick={onPrevious}
          disabled={page === 1}
          className="px-6 py-3 bg-purple-600 text-white font-semibold rounded-lg
                     hover:bg-purple-700 transition-colors disabled:opacity-50
                     disabled:cursor-not-allowed disabled:hover:bg-purple-600"
        >
          ← Previous
        </button>

        <div className="text-gray-700 font-medium">
          Page {page} of {total_pages}
        </div>

        <button
          onClick={onNext}
          disabled={page === total_pages}
          className="px-6 py-3 bg-purple-600 text-white font-semibold rounded-lg
                     hover:bg-purple-700 transition-colors disabled:opacity-50
                     disabled:cursor-not-allowed disabled:hover:bg-purple-600"
        >
          Next →
        </button>
      </div>
    </div>
  );
}
