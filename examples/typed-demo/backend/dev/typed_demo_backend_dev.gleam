import gleam/erlang/charlist
import gleam/erlang/process
import gleam/io
import typed_demo_backend

pub fn main() {
  io.println("🚀 Starting typed-demo development environment...")
  
  // Build shared_types for JavaScript
  let _ = os_cmd(charlist.from_string("cd ../shared_types && gleam build --target=javascript"))
  io.println("✅ Shared types built")
  
  // Start frontend development server
  let _ = spawn_frontend_process()
  io.println("✅ Frontend npm dev started")
  
  // Give frontend a moment to start
  process.sleep(1000)
  
  io.println("🔧 Starting backend...")
  typed_demo_backend.main()
}

fn spawn_frontend_process() -> process.Pid {
  process.start(fn() {
    let _ = os_cmd(charlist.from_string("cd ../frontend && npm run dev"))
    Nil
  }, False)
}

@external(erlang, "os", "cmd")
fn os_cmd(command: charlist.Charlist) -> charlist.Charlist