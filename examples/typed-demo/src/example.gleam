import gleam/json
import inertia_wisp/inertia
import wisp

// Define a typed props structure
pub type UserPageProps {
  UserPageProps(name: String, email: String, id: Int, interests: List(String))
}

// Encoder function for the props
fn encode_user_props(props: UserPageProps) -> json.Json {
  json.object([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #("id", json.int(props.id)),
    #("interests", json.array(props.interests, json.string)),
  ])
}

// Example handler using the new typed system
pub fn user_profile_handler(
  request: wisp.Request,
  config: inertia.Config,
  user_id: Int,
) -> wisp.Response {
  // Create typed context with zero values and encoder
  let ctx = inertia.new_typed_context(
    config,
    request,
    UserPageProps("", "", 0, []), // zero value
    encode_user_props,
  )

  // Simulate fetching user data
  let user = get_user_by_id(user_id)
  
  ctx
  |> inertia.assign_typed_prop("name", UserPageProps(_, name: user.name))
  |> inertia.assign_typed_prop("email", UserPageProps(_, email: user.email))
  |> inertia.assign_typed_prop("id", UserPageProps(_, id: user.id))
  |> inertia.assign_typed_prop("interests", UserPageProps(_, interests: user.interests))
  |> inertia.render_typed("UserProfile")
}

// Mock user data type and function
type User {
  User(name: String, email: String, id: Int, interests: List(String))
}

fn get_user_by_id(id: Int) -> User {
  User(
    name: "Alice Smith",
    email: "alice@example.com", 
    id: id,
    interests: ["reading", "hiking", "photography"]
  )
}