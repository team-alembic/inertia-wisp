import React from "react";
import LoginForm from "./forms/LoginForm";

interface LoginPageProps {
  title: string;
  message: string;
  features: string[];
  errors?: Record<string, string>;
}

export default function Login({ title, message, features, errors }: LoginPageProps) {
  return <LoginForm title={title} message={message} demo_info={features} errors={errors} />;
}