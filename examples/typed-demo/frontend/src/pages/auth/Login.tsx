import LoginForm from "../../components/forms/LoginForm";
import type { LoginFormPageData } from "../../types/gleam-projections";

export default function Login(props: LoginFormPageData) {
  return <LoginForm title={props.title} message={props.message} demo_info={props.demo_info} errors={props.errors} />;
}