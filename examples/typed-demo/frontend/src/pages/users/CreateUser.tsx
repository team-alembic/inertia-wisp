import CreateUserForm from "../../components/forms/CreateUserForm";
import type { HomePageProps$ } from "@shared_types/shared_types/home.d.mts";
import type { WithErrors } from "../../types/gleam-projections";

export default function CreateUser(props: WithErrors<HomePageProps$>) {
  return <CreateUserForm title={props.title} message={props.message} errors={props.errors} />;
}