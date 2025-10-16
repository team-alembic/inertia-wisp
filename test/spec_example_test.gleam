import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleeunit/should
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
pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u: User) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field(
    "name",
    schema.StringType,
    fn(u: User) { u.name },
    fn(u, name) { User(..u, name: name) },
  )
  |> schema.field(
    "email",
    schema.StringType,
    fn(u: User) { u.email },
    fn(u, email) { User(..u, email: email) },
  )
  |> schema.schema()
}

pub fn post_schema() -> schema.RecordSchema {
  let default_user = User(id: 0, name: "", email: "")
  schema.record_schema(
    "Post",
    Post(id: 0, title: "", body: "", author: default_user),
  )
  |> schema.field("id", schema.IntType, fn(p: Post) { p.id }, fn(p, id) {
    Post(..p, id: id)
  })
  |> schema.field(
    "title",
    schema.StringType,
    fn(p: Post) { p.title },
    fn(p, title) { Post(..p, title: title) },
  )
  |> schema.field(
    "body",
    schema.StringType,
    fn(p: Post) { p.body },
    fn(p, body) { Post(..p, body: body) },
  )
  |> schema.field(
    "author",
    schema.RecordType(user_schema),
    fn(p: Post) { p.author },
    fn(p, author) { Post(..p, author: author) },
  )
  |> schema.schema()
}

pub fn pagination_schema() -> schema.RecordSchema {
  schema.record_schema(
    "PaginationInfo",
    PaginationInfo(current_page: 0, total_pages: 0, per_page: 0),
  )
  |> schema.field(
    "current_page",
    schema.IntType,
    fn(p: PaginationInfo) { p.current_page },
    fn(p, cp) { PaginationInfo(..p, current_page: cp) },
  )
  |> schema.field(
    "total_pages",
    schema.IntType,
    fn(p: PaginationInfo) { p.total_pages },
    fn(p, tp) { PaginationInfo(..p, total_pages: tp) },
  )
  |> schema.field(
    "per_page",
    schema.IntType,
    fn(p: PaginationInfo) { p.per_page },
    fn(p, pp) { PaginationInfo(..p, per_page: pp) },
  )
  |> schema.schema()
}

// Build a complete spec
pub fn blog_spec() -> spec.Spec {
  spec.new()
  |> spec.with_schemas([user_schema(), post_schema(), pagination_schema()])
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

  // Check schemas
  app_spec.schemas |> list.length() |> should.equal(3)

  // Check pages
  app_spec.pages |> list.length() |> should.equal(4)

  // Check routes
  app_spec.routes |> list.length() |> should.equal(4)
}

pub fn schema_map_lookup_test() {
  let app_spec = blog_spec()
  let schemas = spec.schema_map(app_spec)

  // Should be able to look up schemas by name
  let assert Ok(user) = dict.get(schemas, "User")
  user.name |> should.equal("User")

  let assert Ok(post) = dict.get(schemas, "Post")
  post.name |> should.equal("Post")

  let assert Ok(pagination) = dict.get(schemas, "PaginationInfo")
  pagination.name |> should.equal("PaginationInfo")
}

pub fn page_map_lookup_test() {
  let app_spec = blog_spec()
  let pages = spec.page_map(app_spec)

  // Should be able to look up pages by name
  let assert Ok(post_index) = dict.get(pages, "PostIndex")
  post_index.component_path |> should.equal("Pages/Posts/Index")
  post_index.props |> list.length() |> should.equal(2)

  let assert Ok(user_show) = dict.get(pages, "UserShow")
  user_show.component_path |> should.equal("Pages/Users/Show")
}

pub fn route_map_lookup_test() {
  let app_spec = blog_spec()
  let routes = spec.route_map(app_spec)

  // Should be able to look up routes by name
  let assert Ok(posts_index) = dict.get(routes, "posts.index")
  posts_index.path |> should.equal("/posts")
  posts_index.method |> should.equal(spec.GET)
  posts_index.page |> should.equal("PostIndex")

  let assert Ok(posts_show) = dict.get(routes, "posts.show")
  posts_show.path |> should.equal("/posts/:id")
  posts_show.params |> list.length() |> should.equal(1)
}

pub fn print_spec_structure_test() {
  let app_spec = blog_spec()

  io.println("\n========== Blog Application Spec ==========")

  io.println("\nSchemas: " <> list.length(app_spec.schemas) |> int.to_string())
  io.println("Pages: " <> list.length(app_spec.pages) |> int.to_string())
  io.println("Routes: " <> list.length(app_spec.routes) |> int.to_string())

  io.println("\n===========================================\n")

  // Test always passes
  True |> should.be_true()
}
