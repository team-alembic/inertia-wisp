import { useState } from "react";
import { router } from "@inertiajs/react";

/**
 * A custom form hook that maintains type safety with Gleam types.
 *
 * This hook provides similar ergonomics to Inertia's useForm, but works with
 * Gleam type class instances and explicit JSON encoders.
 *
 * @param initialData - Initial Gleam type instance
 * @param encoder - Function to encode Gleam type to JSON-serializable object
 * @returns Form state and handlers
 */
export function useGleamForm<T>(
  initialData: T,
  encoder: (data: T) => Record<string, unknown>,
) {
  const [data, setData] = useState<T>(initialData);
  const [processing, setProcessing] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  /**
   * Update the entire form data with a new Gleam type instance
   */
  const updateData = (newData: T) => {
    setData(newData);
    setErrors({});
  };

  /**
   * Submit the form to the specified URL
   * Encodes the Gleam type to JSON before submission
   */
  const post = (url: string) => {
    setProcessing(true);
    setErrors({});

    const encodedData = encoder(data) as Record<string, unknown>;

    router.post(url, encodedData as any, {
      onSuccess: () => {
        setProcessing(false);
      },
      onError: (errors) => {
        setProcessing(false);
        setErrors(errors);
      },
      onFinish: () => {
        setProcessing(false);
      },
    });
  };

  return {
    data,
    setData: updateData,
    post,
    processing,
    errors,
  };
}
