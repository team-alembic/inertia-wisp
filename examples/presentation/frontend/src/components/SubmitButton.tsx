interface SubmitButtonProps {
  processing: boolean;
  children: string;
  processingText?: string;
}

export function SubmitButton({
  processing,
  children,
  processingText = "Submitting...",
}: SubmitButtonProps) {
  return (
    <button
      type="submit"
      disabled={processing}
      className="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-4 px-6 rounded-lg shadow-lg hover:from-purple-700 hover:to-pink-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all transform hover:scale-[1.02] active:scale-[0.98]"
    >
      {processing ? processingText : children}
    </button>
  );
}
