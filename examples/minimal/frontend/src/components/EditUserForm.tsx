import { useState, ChangeEvent, FormEvent } from "react";
import { router } from "@inertiajs/react";
import { FormField } from "./FormField";
import { LoadingButton } from "./LoadingButton";
import { LinkButton } from "./LinkButton";
import { UserIcon, EmailIcon, CheckIcon, XIcon } from "./icons";

interface EditUserFormData {
  name: string;
  email: string;
}

interface EditUserFormProps {
  user: {
    id: number;
    name: string;
    email: string;
  };
  errors?: Record<string, string> | undefined;
  csrf_token: string;
}

export function EditUserForm({ user, errors, csrf_token }: EditUserFormProps) {
  const [formData, setFormData] = useState<EditUserFormData>({
    name: user?.name || "",
    email: user?.email || "",
  });
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    router.post(`/users/${user.id}`, {
      ...formData,
      _token: csrf_token,
    }, {
      onFinish: () => setIsSubmitting(false),
    });
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <FormField
        id="name"
        name="name"
        type="text"
        label="Full Name"
        value={formData.name}
        onChange={handleChange}
        disabled={isSubmitting}
        error={errors?.name}
        icon={<UserIcon />}
        placeholder="Enter your full name"
      />

      <FormField
        id="email"
        name="email"
        type="email"
        label="Email Address"
        value={formData.email}
        onChange={handleChange}
        disabled={isSubmitting}
        error={errors?.email}
        icon={<EmailIcon />}
        placeholder="Enter your email address"
      />

      <div className="flex flex-col sm:flex-row gap-3">
        <LoadingButton
          type="submit"
          variant="primary"
          loading={isSubmitting}
          loadingText="Updating..."
          icon={<CheckIcon />}
          fullWidth
          className="bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700"
        >
          Update User
        </LoadingButton>

        <LinkButton
          href={`/users/${user.id}`}
          variant="indigo"
          size="lg"
          icon={<XIcon />}
          className="flex-1 border border-gray-300 text-gray-700 bg-white hover:bg-gray-50"
        >
          Cancel
        </LinkButton>
      </div>
    </form>
  );
}