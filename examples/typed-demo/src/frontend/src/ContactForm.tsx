import ContactFormComponent from "./forms/ContactFormComponent";
import type { ContactFormPageData } from "./types/gleam-projections";

export default function ContactForm(props: ContactFormPageData) {
  return <ContactFormComponent title={props.title} message={props.message} errors={props.errors} />;
}