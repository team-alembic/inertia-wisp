import CreateUserForm from "./forms/CreateUserForm";
import type { CreateUserFormPageData } from "./types/gleam-projections";

export default function CreateUser(props: CreateUserFormPageData) {
  return <CreateUserForm title={props.title} message={props.message} errors={props.errors} />;
}