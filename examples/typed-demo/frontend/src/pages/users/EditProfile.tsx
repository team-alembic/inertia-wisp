import EditProfileForm from "../../components/forms/EditProfileForm";
import type { UserProfilePageProps$ } from "@shared_types/shared_types/users.d.mts";
import type { WithErrors } from "../../types/gleam-projections";

export default function EditProfile(props: WithErrors<UserProfilePageProps$>) {
  const user = {
    id: props.id,
    name: props.name,
    email: props.email,
    bio: props.bio,
    interests: props.interests,
  };
  
  return <EditProfileForm user={user} errors={props.errors} />;
}