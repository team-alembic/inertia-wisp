import React from "react";
import ContactFormComponent from "./forms/ContactFormComponent";

interface ContactFormPageProps {
  title: string;
  message: string;
  features: string[];
  errors?: Record<string, string>;
}

export default function ContactForm({ title, message, features, errors }: ContactFormPageProps) {
  return <ContactFormComponent title={title} message={message} errors={errors} />;
}