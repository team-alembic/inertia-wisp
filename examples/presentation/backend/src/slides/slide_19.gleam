//// Slide 19: Form Submission Success
////
//// Confirmation after successful form submission

import shared/content.{type Slide, Heading, Paragraph, Slide, Spacer, Subheading}

pub fn slide() -> Slide {
  Slide(
    number: 19,
    title: "Form Submitted Successfully!",
    content: [
      Heading("✅ Success!"),
      Subheading("Your form was validated and submitted"),
      Spacer,
      Paragraph(
        "The form data passed all validation rules on the backend and was successfully processed.",
      ),
      Spacer,
      Paragraph(
        "Notice how Inertia handled the redirect seamlessly without a full page reload. This is the power of Inertia.js - server-side rendering with SPA-like navigation.",
      ),
      Spacer,
      Paragraph("Continue exploring the presentation with the arrow keys →"),
    ],
    notes: "This slide confirms successful form submission. It demonstrates how Inertia handles redirects after form submissions. The user was redirected here from the contact form after their data passed validation.",
  )
}
