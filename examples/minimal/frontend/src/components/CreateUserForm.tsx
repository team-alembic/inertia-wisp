import { useState, ChangeEvent, FormEvent } from "react";
import { router } from "@inertiajs/react";
import { CreateUserFormSchema, validateFormData } from "../schemas";
import { FormField } from "./FormField";
import { LoadingButton } from "./LoadingButton";
import { LinkButton } from "./LinkButton";
import { ValidationErrors } from "./ValidationErrors";
import { UserIcon, EmailIcon, CheckIconSmall, PlusIcon, XIcon } from "./icons";

interface CreateUserFormData {
  name: string;
  email: string;
}

interface CreateUserFormProps {
  errors: Record<string, string>;
  old: { name?: string | undefined; email?: string | undefined };
  csrf_token: string;
  onSubmit?: () => void;
}

export function CreateUserForm({ errors, old, csrf_token, onSubmit }: CreateUserFormProps) {
  const [formData, setFormData] = useState<CreateUserFormData>({
    name: old?.name || "",
    email: old?.email || "",
  });
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [clientErrors, setClientErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    // Client-side validation with Zod
    const validation = validateFormData(CreateUserFormSchema, formData);
    
    if (!validation.success) {
      setClientErrors(validation.errors);
      return;
    }
    
    // Clear client errors if validation passes
    setClientErrors({});
    setIsSubmitting(true);
    
    if (onSubmit) {
      onSubmit();
    }

    router.post("/users", {
      ...validation.data,
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
    
    // Clear error for this field when user starts typing
    if (clientErrors[name]) {
      setClientErrors(prev => ({ ...prev, [name]: "" }));
    }
  };

  // Merge server errors and client errors, preferring server errors
  const allErrors = { ...clientErrors, ...errors };

  return (
    <div className="p-6">
      <ValidationErrors errors={allErrors} />

      <form onSubmit={handleSubmit} className="space-y-6">
        <FormField
          id="name"
          name="name"
          type="text"
          label="Full Name"
          value={formData.name}
          onChange={handleChange}
          placeholder="Enter your full name"
          disabled={isSubmitting}
          error={allErrors?.name}
          icon={<UserIcon />}
          validationIcon={!allErrors?.name && formData.name.length > 0 ? <CheckIconSmall /> : undefined}
        />

        <FormField
          id="email"
          name="email"
          type="email"
          label="Email Address"
          value={formData.email}
          onChange={handleChange}
          placeholder="Enter your email address"
          disabled={isSubmitting}
          error={allErrors?.email}
          icon={<EmailIcon />}
          validationIcon={!allErrors?.email && formData.email.includes('@') ? <CheckIconSmall /> : undefined}
        />

        <div className="flex flex-col sm:flex-row gap-3">
          <LoadingButton
            type="submit"
            variant="primary"
            size="lg"
            loading={isSubmitting}
            loadingText="Creating..."
            icon={<PlusIcon />}
            fullWidth
          >
            Create User
          </LoadingButton>

          <LinkButton
            href="/users"
            variant="indigo"
            size="lg"
            icon={<XIcon />}
            fullWidth
          >
            Cancel
          </LinkButton>
        </div>
      </form>
    </div>
  );
}