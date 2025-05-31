import EditProfileForm from "./forms/EditProfileForm";
import type { EditProfileFormPageData } from "./types/gleam-projections";

export default function EditProfile(props: EditProfileFormPageData) {
  return <EditProfileForm user={props.user as any} errors={props.errors as any} />;
}