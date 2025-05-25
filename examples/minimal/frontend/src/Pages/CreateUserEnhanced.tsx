import { useState, ChangeEvent, FormEvent } from "react";
import { Link, router } from "@inertiajs/react";
import { CreateUserFormSchema, validateFormData, validatePageProps, CreateUserPagePropsSchema } from "../schemas";

interface CreateUserFormData {
  name: string;
  email: string;
}

export default function CreateUserEnhanced(props: unknown) {
  // Validate props at runtime to ensure they match expected schema
  const { errors, old, csrf_token, auth } = validatePageProps(CreateUserPagePropsSchema, props);
  
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
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
        maxWidth: "600px",
        margin: "0 auto",
      }}
    >
      <h1>Create New User (Enhanced with Zod)</h1>

      <nav style={{ marginBottom: "20px" }}>
        <Link
          href="/users"
          style={{
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          ← Back to Users
        </Link>
      </nav>

      {auth?.authenticated && (
        <div
          style={{
            backgroundColor: "#e8f5e8",
            padding: "10px",
            marginBottom: "20px",
            borderRadius: "4px",
            fontSize: "14px",
          }}
        >
          Logged in as: {auth.user}
        </div>
      )}

      <div
        style={{
          backgroundColor: "#fff3cd",
          padding: "10px",
          marginBottom: "20px",
          borderRadius: "4px",
          fontSize: "14px",
          border: "1px solid #ffeaa7",
        }}
      >
        <strong>Enhanced Version:</strong> This form includes client-side Zod validation 
        that matches the backend schema validation.
      </div>

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: "20px" }}>
          <label
            htmlFor="name"
            style={{
              display: "block",
              marginBottom: "5px",
              fontWeight: "bold",
            }}
          >
            Name
          </label>
          <input
            type="text"
            id="name"
            name="name"
            value={formData.name}
            onChange={handleChange}
            style={{
              width: "100%",
              padding: "10px",
              border: allErrors?.name ? "2px solid red" : "1px solid #ddd",
              borderRadius: "4px",
              fontSize: "16px",
              boxSizing: "border-box",
            }}
            disabled={isSubmitting}
          />
          {allErrors?.name && (
            <div
              style={{
                color: "red",
                fontSize: "14px",
                marginTop: "5px",
              }}
            >
              {allErrors.name}
            </div>
          )}
        </div>

        <div style={{ marginBottom: "20px" }}>
          <label
            htmlFor="email"
            style={{
              display: "block",
              marginBottom: "5px",
              fontWeight: "bold",
            }}
          >
            Email
          </label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            style={{
              width: "100%",
              padding: "10px",
              border: allErrors?.email ? "2px solid red" : "1px solid #ddd",
              borderRadius: "4px",
              fontSize: "16px",
              boxSizing: "border-box",
            }}
            disabled={isSubmitting}
          />
          {allErrors?.email && (
            <div
              style={{
                color: "red",
                fontSize: "14px",
                marginTop: "5px",
              }}
            >
              {allErrors.email}
            </div>
          )}
        </div>

        <div style={{ marginBottom: "20px" }}>
          <button
            type="submit"
            disabled={isSubmitting}
            style={{
              backgroundColor: isSubmitting ? "#ccc" : "#007bff",
              color: "white",
              padding: "12px 20px",
              border: "none",
              borderRadius: "4px",
              fontSize: "16px",
              cursor: isSubmitting ? "not-allowed" : "pointer",
              marginRight: "10px",
            }}
          >
            {isSubmitting ? "Creating..." : "Create User"}
          </button>

          <Link
            href="/users"
            style={{
              backgroundColor: "#6c757d",
              color: "white",
              padding: "12px 20px",
              textDecoration: "none",
              borderRadius: "4px",
              fontSize: "16px",
            }}
          >
            Cancel
          </Link>
        </div>
      </form>

      <div
        style={{
          marginTop: "30px",
          padding: "15px",
          backgroundColor: "#f8f9fa",
          borderRadius: "4px",
        }}
      >
        <h3>Enhanced Form Validation</h3>
        <ul style={{ marginLeft: "20px" }}>
          <li><strong>Runtime Schema Validation:</strong> Props are validated against Zod schema</li>
          <li><strong>Client-side Validation:</strong> Form data validated before submission</li>
          <li><strong>Type Safety:</strong> Both compile-time and runtime type checking</li>
          <li><strong>Error Merging:</strong> Client errors shown immediately, server errors on submission</li>
          <li><strong>Schema Consistency:</strong> Same validation rules as backend</li>
        </ul>
      </div>
    </div>
  );
}