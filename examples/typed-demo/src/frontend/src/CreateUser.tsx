
import CreateUserForm from "./forms/CreateUserForm";

interface CreateUserPageProps {
  title: string;
  message: string;
  errors?: Record<string, string> | undefined;
}

export default function CreateUser({ title, message, errors }: CreateUserPageProps) {
  return <CreateUserForm title={title} message={message} errors={errors} />;
}