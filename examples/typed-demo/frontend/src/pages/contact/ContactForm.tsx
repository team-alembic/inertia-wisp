import { WithErrors } from "src/types/gleam-projections";
import ContactFormComponent from "../../components/forms/ContactFormComponent";
import type { ContactPageProp$ } from "@shared_types/shared_types/contact.d.mts";

export default function ContactForm(props: WithErrors<ContactPageProp$>) {
  return (
    <ContactFormComponent
      title={props.title}
      message={props.message}
      errors={props.errors}
    />
  );
}
