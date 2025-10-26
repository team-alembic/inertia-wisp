import gleam/dict
import gleam/list
import gleam/option
import inertia_wisp/schema
import inertia_wisp/spec

// Example types
pub type User {
  User(id: Int, name: String, email: String)
}

pub type Post {
  Post(id: Int, title: String, body: String, author: User)
}

pub type PaginationInfo {
  PaginationInfo(current_page: Int, total_pages: Int, per_page: Int)
}

// Example schemas
pub fn user_schema() -> schema.RecordSchema(_) {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType)
  |> schema.field("name", schema.StringType)
  |> schema.field("email", schema.StringType)
  |> schema.schema()
}

pub fn post_schema() -> schema.RecordSchema(_) {
  let default_user = User(id: 0, name: "", email: "")
  schema.record_schema(
    "Post",
    Post(id: 0, title: "", body: "", author: default_user),
  )
  |> schema.field("id", schema.IntType)
  |> schema.field("title", schema.StringType)
  |> schema.field("body", schema.StringType)
  |> schema.field("author", schema.RecordType(user_schema))
  |> schema.schema()
}

pub fn pagination_schema() -> schema.RecordSchema(_) {
  schema.record_schema(
    "PaginationInfo",
    PaginationInfo(current_page: 0, total_pages: 0, per_page: 0),
  )
  |> schema.field("current_page", schema.IntType)
  |> schema.field("total_pages", schema.IntType)
  |> schema.field("per_page", schema.IntType)
  |> schema.schema()
}

// Build a complete spec
pub fn blog_spec() -> spec.Spec {
  spec.new()
  |> spec.with_pages([
    spec.PageDef(name: "PostIndex", component_path: "Pages/Posts/Index", props: [
      spec.PropDef(name: "posts", schema_name: "Post", kind: spec.LazyProp),
      spec.PropDef(
        name: "pagination",
        schema_name: "PaginationInfo",
        kind: spec.DefaultProp,
      ),
    ]),
    spec.PageDef(name: "PostShow", component_path: "Pages/Posts/Show", props: [
      spec.PropDef(name: "post", schema_name: "Post", kind: spec.DefaultProp),
    ]),
    spec.PageDef(name: "UserIndex", component_path: "Pages/Users/Index", props: [
      spec.PropDef(name: "users", schema_name: "User", kind: spec.LazyProp),
      spec.PropDef(
        name: "pagination",
        schema_name: "PaginationInfo",
        kind: spec.DefaultProp,
      ),
    ]),
    spec.PageDef(name: "UserShow", component_path: "Pages/Users/Show", props: [
      spec.PropDef(name: "user", schema_name: "User", kind: spec.DefaultProp),
      spec.PropDef(name: "posts", schema_name: "Post", kind: spec.DeferredProp),
    ]),
  ])
  |> spec.with_routes([
    spec.RouteDef(
      name: "posts.index",
      path: "/posts",
      method: spec.GET,
      params: [],
      query_params: [
        spec.ParamDef(name: "page", param_type: spec.IntParam),
        spec.ParamDef(name: "per_page", param_type: spec.IntParam),
      ],
      body: option.None,
      page: "PostIndex",
    ),
    spec.RouteDef(
      name: "posts.show",
      path: "/posts/:id",
      method: spec.GET,
      params: [spec.ParamDef(name: "id", param_type: spec.IntParam)],
      query_params: [],
      body: option.None,
      page: "PostShow",
    ),
    spec.RouteDef(
      name: "users.index",
      path: "/users",
      method: spec.GET,
      params: [],
      query_params: [spec.ParamDef(name: "page", param_type: spec.IntParam)],
      body: option.None,
      page: "UserIndex",
    ),
    spec.RouteDef(
      name: "users.show",
      path: "/users/:id",
      method: spec.GET,
      params: [spec.ParamDef(name: "id", param_type: spec.IntParam)],
      query_params: [],
      body: option.None,
      page: "UserShow",
    ),
  ])
}

pub fn spec_has_correct_structure_test() {
  let app_spec = blog_spec()

  // Check pages
  assert list.length(app_spec.pages) == 4

  // Check routes
  assert list.length(app_spec.routes) == 4
}

pub fn page_map_lookup_test() {
  let app_spec = blog_spec()
  let pages = spec.page_map(app_spec)

  // Should be able to look up pages by name
  let assert Ok(post_index) = dict.get(pages, "PostIndex")
  assert post_index.component_path == "Pages/Posts/Index"
  assert list.length(post_index.props) == 2

  let assert Ok(user_show) = dict.get(pages, "UserShow")
  assert user_show.component_path == "Pages/Users/Show"
}

pub fn route_map_lookup_test() {
  let app_spec = blog_spec()
  let routes = spec.route_map(app_spec)

  // Should be able to look up routes by name
  let assert Ok(posts_index) = dict.get(routes, "posts.index")
  assert posts_index.path == "/posts"
  assert posts_index.method == spec.GET
  assert posts_index.page == "PostIndex"

  let assert Ok(posts_show) = dict.get(routes, "posts.show")
  assert posts_show.path == "/posts/:id"
  assert list.length(posts_show.params) == 1
}
