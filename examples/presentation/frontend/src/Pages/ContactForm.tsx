import { Head, Link, useForm } from "@inertiajs/react";
import { FormEvent } from "react";
import {
  ContactFormPagePropsSchema,
  type ContactFormPageProps,
} from "../schemas";
import { type ContactFormData } from "../generated/schemas";
import { validateProps } from "../lib/validateProps";
import { FormCard } from "../components/FormCard";
import { FormField } from "../components/FormField";
import { SubmitButton } from "../components/SubmitButton";
import { ValidationRulesTip } from "../components/ValidationRulesTip";
import { validate_name } from "../../../shared/build/dev/javascript/shared/shared/forms.mjs";
import {
  Result$Error$0,
  Result$isOk,
} from "../../../shared/build/dev/javascript/prelude.mjs";

function ContactForm({ name, email, message }: ContactFormPageProps) {
  const { data, setData, post, processing, setError, clearErrors, errors } =
    useForm<ContactFormData>({
      name,
      email,
      message,
    });

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    post("/forms/contact");
  };

  const handleNameChange = (value: string) => {
    setData("name", value);
    // Validate on change for instant feedback
    const validation = validate_name(value);
    if (Result$isOk(validation)) {
      clearErrors("name");
    } else {
      setError("name", Result$Error$0(validation)!);
    }
  };

  const validationRules = [
    { field: "Name", rule: "Required, at least 2 characters" },
    { field: "Email", rule: "Required, valid email format" },
    { field: "Message", rule: "Required, at least 10 characters" },
  ];

  return (
    <>
      <Head title="Contact Form Demo" />

      <div className="min-h-screen flex flex-col bg-gradient-to-br from-purple-200 via-pink-200 to-purple-300">
        <main className="flex-1 flex items-center justify-center p-8">
          <div className="max-w-2xl w-full">
            <FormCard
              title="Contact Form Demo"
              subtitle="Try submitting with invalid data to see validation in action"
            >
              <form onSubmit={handleSubmit} className="space-y-6">
                <FormField
                  id="name"
                  label="Name"
                  type="text"
                  value={data.name}
                  onChange={handleNameChange}
                  error={errors?.name}
                  disabled={processing}
                  placeholder="Enter your name"
                />

                <FormField
                  id="email"
                  label="Email"
                  type="email"
                  value={data.email}
                  onChange={(value) => setData("email", value)}
                  error={errors?.email}
                  disabled={processing}
                  placeholder="Enter your email"
                />

                <FormField
                  id="message"
                  label="Message"
                  type="textarea"
                  value={data.message}
                  onChange={(value) => setData("message", value)}
                  error={errors?.message}
                  disabled={processing}
                  placeholder="Enter your message (at least 10 characters)"
                  rows={5}
                  showCharCount={true}
                  minChars={10}
                />

                <SubmitButton processing={processing}>Submit Form</SubmitButton>
              </form>

              <ValidationRulesTip rules={validationRules} />
            </FormCard>

            {/* Navigation Footer */}
            <div className="mt-6 text-center">
              <Link
                href="/slides/19"
                className="inline-flex items-center gap-2 text-white font-semibold hover:underline text-lg"
              >
                <span>← Back to Presentation</span>
              </Link>
            </div>
          </div>
        </main>
      </div>
    </>
  );
}

export default validateProps(ContactForm, ContactFormPagePropsSchema);
