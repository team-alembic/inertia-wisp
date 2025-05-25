import React from "react";
import { Link } from "@inertiajs/react";
import { 
  AboutPageProps, 
  AboutPagePropsSchema, 
  withValidatedProps, 
  validateProps,
  ValidationErrorFallbackProps 
} from "../schemas";

// Example 1: Basic usage with validateProps (simplified API)
function BasicAbout({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif" }}>
      <h1>{page_title}</h1>
      <p>This component uses the basic validateProps HOC.</p>
      {auth?.authenticated && <p>Welcome, {auth.user}!</p>}
    </div>
  );
}

const BasicAboutValidated = validateProps(AboutPagePropsSchema, BasicAbout);

// Example 2: Advanced usage with custom error boundary
function CustomErrorFallback({ error, reset }: ValidationErrorFallbackProps) {
  return (
    <div style={{
      padding: "20px",
      backgroundColor: "#fef2f2",
      border: "1px solid #fca5a5",
      borderRadius: "8px",
      color: "#991b1b"
    }}>
      <h2>🚨 Oops! Something went wrong</h2>
      <p>The page data doesn't match what we expected:</p>
      <pre style={{ 
        backgroundColor: "#fee2e2", 
        padding: "10px", 
        borderRadius: "4px",
        fontSize: "12px",
        overflow: "auto"
      }}>
        {error.message}
      </pre>
      <button 
        onClick={reset}
        style={{
          marginTop: "10px",
          padding: "8px 16px",
          backgroundColor: "#dc2626",
          color: "white",
          border: "none",
          borderRadius: "4px",
          cursor: "pointer"
        }}
      >
        Try Again
      </button>
    </div>
  );
}

function AdvancedAbout({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif" }}>
      <h1>{page_title} (Advanced)</h1>
      <p>This component uses the advanced withValidatedProps HOC with custom error handling.</p>
      {auth?.authenticated && <p>Welcome, {auth.user}!</p>}
    </div>
  );
}

const AdvancedAboutValidated = withValidatedProps(
  AboutPagePropsSchema, 
  AdvancedAbout,
  {
    ErrorFallback: CustomErrorFallback,
    logErrors: true,
    onError: (error, props) => {
      // Could send to error reporting service
      console.warn("Validation error reported:", error.message);
    }
  }
);

// Example 3: No validation (for comparison)
function UnvalidatedAbout(props: any) {
  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif" }}>
      <h1>{props.page_title || "Unknown Title"}</h1>
      <p>This component accepts any props without validation.</p>
      <p style={{ color: "#dc2626", fontSize: "14px" }}>
        ⚠️ No type safety or runtime validation!
      </p>
    </div>
  );
}

// Main demo component
export default function ValidationExamples() {
  const demoProps = {
    page_title: "Validation Demo",
    csrf_token: "demo-token-123",
    auth: { authenticated: true, user: "demo@example.com" }
  };

  const [showInvalidProps, setShowInvalidProps] = React.useState(false);

  const invalidProps = {
    page_title: 123, // Should be string
    csrf_token: null, // Should be string
    auth: "invalid" // Should be object or undefined
  };

  const currentProps = showInvalidProps ? invalidProps : demoProps;

  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif", maxWidth: "800px" }}>
      <h1>Page Props Validation Examples</h1>
      
      <nav style={{ marginBottom: "30px" }}>
        <Link href="/" style={{ color: "blue", textDecoration: "underline" }}>
          ← Back to Home
        </Link>
      </nav>

      <div style={{ 
        backgroundColor: "#f3f4f6", 
        padding: "20px", 
        borderRadius: "8px", 
        marginBottom: "30px" 
      }}>
        <h2>Demo Controls</h2>
        <label style={{ display: "flex", alignItems: "center", gap: "10px" }}>
          <input
            type="checkbox"
            checked={showInvalidProps}
            onChange={(e) => setShowInvalidProps(e.target.checked)}
          />
          Send invalid props to demonstrate error handling
        </label>
        
        <div style={{ marginTop: "15px" }}>
          <h3>Current Props:</h3>
          <pre style={{ 
            backgroundColor: "#e5e7eb", 
            padding: "10px", 
            borderRadius: "4px",
            fontSize: "12px",
            overflow: "auto"
          }}>
            {JSON.stringify(currentProps, null, 2)}
          </pre>
        </div>
      </div>

      <div style={{ display: "grid", gap: "30px" }}>
        <section>
          <h2>1. Basic Validation (validateProps)</h2>
          <p>Simple HOC that validates props and throws on error:</p>
          <div style={{ border: "1px solid #d1d5db", borderRadius: "8px", padding: "15px" }}>
            <BasicAboutValidated {...(currentProps as any)} />
          </div>
        </section>

        <section>
          <h2>2. Advanced Validation (withValidatedProps)</h2>
          <p>Full-featured HOC with custom error boundary and logging:</p>
          <div style={{ border: "1px solid #d1d5db", borderRadius: "8px", padding: "15px" }}>
            <AdvancedAboutValidated {...(currentProps as any)} />
          </div>
        </section>

        <section>
          <h2>3. No Validation (for comparison)</h2>
          <p>Component without any validation (not recommended):</p>
          <div style={{ border: "1px solid #d1d5db", borderRadius: "8px", padding: "15px" }}>
            <UnvalidatedAbout {...(currentProps as any)} />
          </div>
        </section>
      </div>

      <div style={{ 
        marginTop: "40px", 
        backgroundColor: "#eff6ff", 
        padding: "20px", 
        borderRadius: "8px",
        border: "1px solid #bfdbfe"
      }}>
        <h2>Benefits of HOC Pattern</h2>
        <ul style={{ marginLeft: "20px" }}>
          <li><strong>Clean Component Signatures:</strong> Components accept properly typed props</li>
          <li><strong>Automatic Validation:</strong> Props validated at component boundary</li>
          <li><strong>Better Developer Experience:</strong> Type errors at definition, not usage</li>
          <li><strong>Reusable:</strong> Same HOC pattern for all page components</li>
          <li><strong>Error Boundaries:</strong> Graceful handling of validation failures</li>
          <li><strong>Customizable:</strong> Custom error UI and logging</li>
        </ul>
      </div>
    </div>
  );
}