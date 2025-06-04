import data/users as user_data
import handlers/utils
import inertia_wisp/inertia
import shared_types/users
import shared_types/users as user_props
import sqlight
import wisp

pub fn users_page(
  ctx: inertia.InertiaContext(Nil),
  db: sqlight.Connection,
) -> wisp.Response {
  let users_data = get_users_data(db)

  ctx
  |> inertia.with_encoder(user_props.encode_user_page_prop)
  |> inertia.always_prop("auth", user_props.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    user_props.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("users", user_props.Users(users_data))
  |> inertia.render("Users")
}

fn get_users_data(db: sqlight.Connection) -> List(users.User) {
  case user_data.get_all_users(db) {
    Ok(user_list) -> user_list
    Error(_) -> []
  }
}
