import data/users as user_data
import handlers/utils
import inertia_wisp/inertia
import shared_types/users.{type User}
import sqlight
import wisp

pub fn show_user_page(
  req: inertia.InertiaContext(Nil),
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  case user_data.find_user_by_id(db, id) {
    Ok(user) -> render_user_page(req, user)
    Error(_) -> wisp.not_found()
  }
}

fn render_user_page(
  req: inertia.InertiaContext(Nil),
  user: User,
) -> wisp.Response {
  let user_prop_data =
    users.User(id: user.id, name: user.name, email: user.email)

  req
  |> inertia.with_encoder(users.encode_user_page_prop)
  |> inertia.always_prop("auth", users.Auth(utils.get_demo_auth()))
  |> inertia.always_prop("csrf_token", users.CsrfToken(utils.get_csrf_token()))
  |> inertia.prop("user", users.UserProp(user_prop_data))
  |> inertia.render("ShowUser")
}
