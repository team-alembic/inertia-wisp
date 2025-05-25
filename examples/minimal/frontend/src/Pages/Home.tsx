import { Link, router } from "@inertiajs/react";
import { HomePageProps, HomePagePropsSchema, withValidatedProps } from "../schemas";

function Home({ message, timestamp, user_count, auth, csrf_token }: HomePageProps) {
  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
      }}
    >
      <h1>Welcome to Inertia Gleam!</h1>
      <p>
        Message from server: <strong>{message}</strong>
      </p>
      <p>Timestamp: {timestamp}</p>
      <p>User count: {user_count}</p>

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

      <nav style={{ marginTop: "20px" }}>
        <Link
          href="/about"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          About
        </Link>
        <Link
          href="/users"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Users (Forms Demo)
        </Link>
        <Link
          href="/upload"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          File Upload Demo
        </Link>
      </nav>

      <div
        style={{
          marginTop: "20px",
          padding: "15px",
          backgroundColor: "#f0f0f0",
          borderRadius: "4px",
        }}
      >
        <h3>Demo Features</h3>
        <div style={{ marginBottom: "15px" }}>
          <strong>✅ Navigation:</strong> All page transitions use Inertia XHR requests
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong>✅ Props System:</strong> Server-side data passed to React components
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong>✅ Forms & Validation:</strong> Check out the <Link href="/users" style={{ color: "blue" }}>Users section</Link>
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong>✅ File Uploads:</strong> Try the <Link href="/upload" style={{ color: "blue" }}>File Upload demo</Link>
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong>✅ Redirects:</strong> Form submissions redirect properly
        </div>
        
        <h4 style={{ marginTop: "20px", marginBottom: "10px" }}>Test Navigation</h4>
        <button
          onClick={() => router.visit("/")}
          style={{ marginRight: "10px", padding: "5px 10px" }}
        >
          Reload Home (XHR)
        </button>
        <button 
          onClick={() => (window.location.href = "/")}
          style={{ padding: "5px 10px" }}
        >
          Reload Home (Full)
        </button>
      </div>
    </div>
  );
}

export default withValidatedProps(HomePagePropsSchema, Home);