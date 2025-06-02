import contact/validators
import gleam/dict
import inertia_wisp/inertia
import shared_types/contact
import wisp

// ===== PAGE HANDLERS =====

// Contact form page
pub fn contact_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  ctx
  |> contact.with_contact_page_props()
  |> inertia.prop(contact.title("Contact Us"))
  |> inertia.prop(contact.message(
    "We'd love to hear from you. Send us a message!",
  ))
  |> inertia.render("contact/ContactForm")
}

// ===== FORM HANDLERS =====

// Contact form handler
pub fn contact_form_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  use request <- inertia.require_json(
    ctx,
    contact.contact_form_request_decoder(),
  )

  // Validate the request
  let validation_errors =
    validators.validate_contact_form_request(
      request.name,
      request.email,
      request.subject,
      request.message,
    )

  case dict.is_empty(validation_errors) {
    True -> {
      // Success - redirect to home
      inertia.redirect(ctx.request, "/")
    }
    False -> {
      // Validation errors - re-render contact form with errors
      ctx
      |> inertia.errors(validation_errors)
      |> inertia.render("contact/ContactForm")
    }
  }
}
