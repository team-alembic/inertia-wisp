import ContactFormComponent from "../../components/forms/ContactFormComponent";
import type { ContactPageProps$ } from "@shared_types/shared_types/contact.d.mts";
import type { WithErrors } from "../../types/gleam-projections";

export default function ContactForm(props: WithErrors<ContactPageProps$>) {
  return <ContactFormComponent title={props.title} message={props.message} errors={props.errors} />;
}