import { useState, ChangeEvent, FormEvent } from "react";
import { Link, router } from "@inertiajs/react";
import { EditUserPageProps, EditUserPagePropsSchema, withValidatedProps } from "../schemas";

interface EditUserFormData {
  name: string;
  email: string;
}

function EditUser({ user, errors, csrf_token, auth }: EditUserPageProps) {
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
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
        maxWidth: "600px",
        margin: "0 auto",
      }}
    >
      <h1>Edit User</h1>

      <nav style={{ marginBottom: "20px" }}>
        <Link
          href={`/users/${user.id}`}
          style={{
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
            marginRight: "15px",
          }}
        >
          ← Back to User Details
        </Link>
        <Link
          href="/users"
          style={{
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Back to Users List
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
              border: errors?.name ? "2px solid red" : "1px solid #ddd",
              borderRadius: "4px",
              fontSize: "16px",
              boxSizing: "border-box",
            }}
            disabled={isSubmitting}
          />
          {errors?.name && (
            <div
              style={{
                color: "red",
                fontSize: "14px",
                marginTop: "5px",
              }}
            >
              {errors.name}
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
              border: errors?.email ? "2px solid red" : "1px solid #ddd",
              borderRadius: "4px",
              fontSize: "16px",
              boxSizing: "border-box",
            }}
            disabled={isSubmitting}
          />
          {errors?.email && (
            <div
              style={{
                color: "red",
                fontSize: "14px",
                marginTop: "5px",
              }}
            >
              {errors.email}
            </div>
          )}
        </div>

        <div style={{ marginBottom: "20px" }}>
          <button
            type="submit"
            disabled={isSubmitting}
            style={{
              backgroundColor: isSubmitting ? "#ccc" : "#28a745",
              color: "white",
              padding: "12px 20px",
              border: "none",
              borderRadius: "4px",
              fontSize: "16px",
              cursor: isSubmitting ? "not-allowed" : "pointer",
              marginRight: "10px",
            }}
          >
            {isSubmitting ? "Updating..." : "Update User"}
          </button>

          <Link
            href={`/users/${user.id}`}
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
        <h3>Edit Form Demo</h3>
        <ul style={{ marginLeft: "20px" }}>
          <li>Form is pre-populated with existing user data</li>
          <li>Same validation rules apply as create form</li>
          <li>Email uniqueness check excludes current user</li>
          <li>Successful update redirects to user detail page</li>
          <li>Validation errors preserve form state</li>
        </ul>
      </div>
    </div>
  );
}

export default withValidatedProps(EditUserPagePropsSchema, EditUser);