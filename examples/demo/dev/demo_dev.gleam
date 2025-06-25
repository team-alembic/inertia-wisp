import demo
import gleam/erlang/charlist
import gleam/erlang/process
import gleam/io

pub fn main() {
  io.println("🚀 Starting development environment...")

  // Start frontend development server in background
  let _ = spawn_frontend_process()
  io.println("✅ Frontend npm dev started")

  // Give frontend a moment to start
  process.sleep(1000)

  io.println("🔧 Starting backend...")
  demo.main()
}

fn spawn_frontend_process() -> process.Pid {
  process.spawn(fn() {
    let _ = os_cmd(charlist.from_string("cd frontend && npm run dev"))
    Nil
  })
}

@external(erlang, "os", "cmd")
fn os_cmd(command: charlist.Charlist) -> charlist.Charlist
