import React from "react";
import EditProfileForm from "./forms/EditProfileForm";

interface EditProfilePageProps {
  user: {
    id: number;
    name: string;
    email: string;
    bio: string;
    interests?: string[] | null;
  };
  errors?: Record<string, string>;
}

export default function EditProfile({ user, errors }: EditProfilePageProps) {
  return <EditProfileForm user={user} errors={errors} />;
}