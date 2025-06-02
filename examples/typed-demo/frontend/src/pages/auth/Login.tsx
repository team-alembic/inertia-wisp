import LoginForm from "../../components/forms/LoginForm";
import type { LoginPageProps$ } from "@shared_types/shared_types/auth.d.mts";
import type { WithErrors } from "../../types/gleam-projections";

export default function Login(props: WithErrors<LoginPageProps$>) {
  return <LoginForm title={props.title} message={props.message} demo_info={props.demo_info} errors={props.errors} />;
}