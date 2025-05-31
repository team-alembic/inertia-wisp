import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/string
import inertia_wisp/inertia
import types.{
  HomePageProps, UserProfilePageProps,
  contact_form_request_decoder, create_user_request_decoder,
  login_request_decoder, update_profile_request_decoder,
  encode_home_page_props, encode_user_profile_props,
}
import wisp

// ===== VALIDATION UTILITIES =====

pub type ValidationErrors =
  dict.Dict(String, String)

fn validate_name(name: String) -> Result(Nil, #(String, String)) {
  case string.length(name) >= 2 {
    True -> Ok(Nil)
    False -> Error(#("name", "Name must be at least 2 characters long"))
  }
}

fn validate_email(email: String) -> Result(Nil, #(String, String)) {
  case string.contains(email, "@") && string.length(email) > 3 {
    True -> Ok(Nil)
    False -> Error(#("email", "Please enter a valid email address"))
  }
}

fn validate_password(password: String) -> Result(Nil, #(String, String)) {
  case string.length(password) >= 6 {
    True -> Ok(Nil)
    False -> Error(#("password", "Password must be at least 6 characters long"))
  }
}

fn validate_bio_optional(bio: option.Option(String)) -> Result(Nil, #(String, String)) {
  case bio {
    option.Some(bio_text) -> 
      case string.length(bio_text) <= 500 {
        True -> Ok(Nil)
        False -> Error(#("bio", "Bio must be 500 characters or less"))
      }
    option.None -> Ok(Nil)
  }
}

fn validate_bio_required(bio: String) -> Result(Nil, #(String, String)) {
  case string.length(bio) >= 1 && string.length(bio) <= 500 {
    True -> Ok(Nil)
    False -> Error(#("bio", "Bio is required and must be 500 characters or less"))
  }
}

fn validate_subject(subject: String) -> Result(Nil, #(String, String)) {
  case string.length(subject) >= 3 && string.length(subject) <= 200 {
    True -> Ok(Nil)
    False -> Error(#("subject", "Subject must be between 3 and 200 characters"))
  }
}

fn validate_message(message: String) -> Result(Nil, #(String, String)) {
  case string.length(message) >= 10 && string.length(message) <= 2000 {
    True -> Ok(Nil)
    False -> Error(#("message", "Message must be between 10 and 2000 characters"))
  }
}

fn validate_interests(interests: List(String)) -> Result(Nil, #(String, String)) {
  case list.length(interests) > 0 {
    True -> Ok(Nil)
    False -> Error(#("interests", "At least one interest is required"))
  }
}

fn collect_validation_errors(validations: List(Result(Nil, #(String, String)))) -> ValidationErrors {
  validations
  |> list.filter_map(fn(result) {
    case result {
      Ok(_) -> Error(Nil)
      Error(pair) -> Ok(pair)
    }
  })
  |> dict.from_list
}

// ===== JSON PARSING UTILITIES =====

fn require_json(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  decoder: decode.Decoder(a),
  cont: fn(a) -> wisp.Response,
) -> wisp.Response {
  use json_data <- wisp.require_json(ctx.request)
  let result = decode.run(json_data, decoder)
  case result {
    Ok(value) -> cont(value)
    Error(_) -> wisp.bad_request()
  }
}

// ===== FORM HANDLERS =====

// Create user form handler
pub fn create_user_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _req: wisp.Request,
) -> wisp.Response {
  use request <- require_json(ctx, create_user_request_decoder())
  
  // Validate the request
  let errors = collect_validation_errors([
    validate_name(request.name),
    validate_email(request.email),
    validate_bio_optional(request.bio),
  ])
  
  case dict.size(errors) {
    0 -> {
      // Success - redirect to user profile
      // In a real app, you'd save to database and use the actual user ID
      inertia.redirect(ctx.request, "/user/1")
    }
    _ -> {
      // Validation errors - re-render create user form with errors
      let typed_ctx = ctx
        |> inertia.set_props(
          HomePageProps("", "", []),
          encode_home_page_props,
        )

      typed_ctx
      |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Create New User") })
      |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Fill out the form below to create a new user account.") })
      |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: []) })
      |> inertia.assign_errors(errors)
      |> inertia.render("CreateUser")
    }
  }
}

// Update profile form handler
pub fn update_profile_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _req: wisp.Request,
  user_id: String,
) -> wisp.Response {
  use request <- require_json(ctx, update_profile_request_decoder())
  
  // Validate the request
  let errors = collect_validation_errors([
    validate_name(request.name),
    validate_bio_required(request.bio),
    validate_interests(request.interests),
  ])
  
  case dict.size(errors) {
    0 -> {
      // Success - redirect to user profile
      inertia.redirect(ctx.request, "/user/" <> user_id)
    }
    _ -> {
      // Validation errors - re-render edit profile form with errors
      let typed_ctx = ctx
        |> inertia.set_props(
          UserProfilePageProps("", "", 0, option.None, ""),
          encode_user_profile_props,
        )

      // Get user data (would normally fetch from database)
      typed_ctx
      |> inertia.assign_always_prop("name", fn(props) { UserProfilePageProps(..props, name: "Alice Johnson") })
      |> inertia.assign_always_prop("id", fn(props) { UserProfilePageProps(..props, id: 1) })
      |> inertia.assign_prop("email", fn(props) { UserProfilePageProps(..props, email: "alice@example.com") })
      |> inertia.assign_prop("bio", fn(props) { UserProfilePageProps(..props, bio: "Software engineer passionate about functional programming and web development.") })
      |> inertia.assign_prop("interests", fn(props) { UserProfilePageProps(..props, interests: option.Some(["Programming", "Reading", "Hiking", "Photography"])) })
      |> inertia.assign_errors(errors)
      |> inertia.render("EditProfile")
    }
  }
}

// Login form handler
pub fn login_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _req: wisp.Request,
) -> wisp.Response {
  use request <- require_json(ctx, login_request_decoder())
  
  // Validate the request
  let validation_errors = collect_validation_errors([
    validate_email(request.email),
    validate_password(request.password),
  ])
  
  case dict.size(validation_errors) {
    0 -> {
      // Check credentials (in real app, check against database)
      case request.email == "demo@example.com" && request.password == "password123" {
        True -> {
          // Success - redirect to dashboard
          inertia.redirect(ctx.request, "/dashboard")
        }
        False -> {
          // Invalid credentials
          let auth_errors = dict.from_list([#("email", "Invalid email or password")])
          let typed_ctx = ctx
            |> inertia.set_props(
              HomePageProps("", "", []),
              encode_home_page_props,
            )

          typed_ctx
          |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Login") })
          |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Please sign in to your account.") })
          |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: ["Demo credentials: demo@example.com / password123"]) })
          |> inertia.assign_errors(auth_errors)
          |> inertia.render("Login")
        }
      }
    }
    _ -> {
      // Validation errors - re-render login form with errors
      let typed_ctx = ctx
        |> inertia.set_props(
          HomePageProps("", "", []),
          encode_home_page_props,
        )

      typed_ctx
      |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Login") })
      |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Please sign in to your account.") })
      |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: ["Demo credentials: demo@example.com / password123"]) })
      |> inertia.assign_errors(validation_errors)
      |> inertia.render("Login")
    }
  }
}

// Contact form handler
pub fn contact_form_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _req: wisp.Request,
) -> wisp.Response {
  use request <- require_json(ctx, contact_form_request_decoder())
  
  // Validate the request
  let errors = collect_validation_errors([
    validate_name(request.name),
    validate_email(request.email),
    validate_subject(request.subject),
    validate_message(request.message),
  ])
  
  case dict.size(errors) {
    0 -> {
      // Success - redirect to home with success message
      // In a real app, you'd send the email here
      inertia.redirect(ctx.request, "/")
    }
    _ -> {
      // Validation errors - re-render contact form with errors
      let typed_ctx = ctx
        |> inertia.set_props(
          HomePageProps("", "", []),
          encode_home_page_props,
        )

      typed_ctx
      |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Contact Us") })
      |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "We'd love to hear from you. Send us a message!") })
      |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: []) })
      |> inertia.assign_errors(errors)
      |> inertia.render("ContactForm")
    }
  }
}