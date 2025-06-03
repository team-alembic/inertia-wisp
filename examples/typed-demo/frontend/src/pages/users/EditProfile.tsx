import EditProfileForm from "../../components/forms/EditProfileForm";
import type { UserProfilePageProp$ } from "@shared_types/shared_types/users.d.mts";
import type { WithErrors } from "../../types/gleam-projections";

export default function EditProfile(props: WithErrors<UserProfilePageProp$>) {
  const userProfile = props.user_profile;
  const user = {
    id: userProfile.id,
    name: userProfile.name,
    email: userProfile.email,
    bio: userProfile.bio,
    interests: userProfile.interests,
  };

  return <EditProfileForm user={user} errors={props.errors} />;
}