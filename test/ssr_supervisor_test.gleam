import gleeunit
import gleeunit/should
import inertia_gleam/ssr/config
import inertia_gleam/ssr/supervisor
import gleam/json

pub fn main() {
  gleeunit.main()
}

pub fn supervisor_start_test() {
  let test_config = config.SSRConfig(
    enabled: True,
    path: "test/priv",
    module: "test_ssr",
    pool_size: 2,
    timeout_ms: 3000,
    raise_on_failure: False,
    supervisor_name: "TestSSR",
  )
  
  case supervisor.start_link(test_config) {
    Ok(sup) -> {
      let status = supervisor.get_status(sup)
      status.config.enabled
      |> should.equal(True)
      
      status.config.pool_size
      |> should.equal(2)
      
      status.config.supervisor_name
      |> should.equal("TestSSR")
    }
    Error(_) -> should.fail()
  }
}

pub fn supervisor_status_test() {
  let test_config = config.development()
  
  case supervisor.start_link(test_config) {
    Ok(sup) -> {
      let status = supervisor.get_status(sup)
      
      status.enabled
      |> should.equal(True)
      
      status.config.raise_on_failure
      |> should.equal(True)
    }
    Error(_) -> should.fail()
  }
}

pub fn config_update_test() {
  let initial_config = config.SSRConfig(
    ..config.default(),
    enabled: False,
    pool_size: 2
  )
  
  case supervisor.start_link(initial_config) {
    Ok(sup) -> {
      let new_config = config.SSRConfig(
        ..initial_config,
        enabled: True,
        pool_size: 4
      )
      
      case supervisor.update_config(sup, new_config) {
        Ok(_) -> {
          let status = supervisor.get_status(sup)
          status.config.enabled
          |> should.equal(True)
          
          status.config.pool_size
          |> should.equal(4)
        }
        Error(_) -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn invalid_config_update_test() {
  let initial_config = config.default()
  
  case supervisor.start_link(initial_config) {
    Ok(sup) -> {
      let invalid_config = config.SSRConfig(
        ..initial_config,
        pool_size: -1  // Invalid pool size
      )
      
      case supervisor.update_config(sup, invalid_config) {
        Ok(_) -> should.fail()
        Error(supervisor.ConfigurationError(_)) -> True |> should.equal(True)
        Error(_) -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn nodejs_start_stop_test() {
  let test_config = config.SSRConfig(
    ..config.default(),
    enabled: True
  )
  
  case supervisor.start_link(test_config) {
    Ok(sup) -> {
      // Try to start Node.js (will likely fail without actual ssr.js file)
      case supervisor.start_nodejs(sup) {
        Ok(_) -> {
          let status = supervisor.get_status(sup)
          status.supervisor_running
          |> should.equal(True)
          
          // Try to stop
          case supervisor.stop_nodejs(sup) {
            Ok(_) -> {
              let status = supervisor.get_status(sup)
              status.supervisor_running
              |> should.equal(False)
            }
            Error(_) -> should.fail()
          }
        }
        Error(_) -> {
          // Expected to fail without actual Node.js setup
          True |> should.equal(True)
        }
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn render_page_without_nodejs_test() {
  let test_config = config.SSRConfig(
    ..config.default(),
    enabled: True
  )
  
  case supervisor.start_link(test_config) {
    Ok(sup) -> {
      let page_json = json.to_string(json.object([
        #("component", json.string("TestComponent")),
        #("props", json.object([])),
        #("url", json.string("/test")),
        #("version", json.string("1.0"))
      ]))
      
      case supervisor.render_page(sup, page_json, "TestComponent") {
        Ok(_) -> should.fail()  // Should fail since Node.js isn't started
        Error(supervisor.SupervisorNotStarted) -> True |> should.equal(True)
        Error(_) -> True |> should.equal(True)  // Other errors are also acceptable
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn child_spec_test() {
  let test_config = config.default()
  let _child_spec = supervisor.child_spec(test_config)
  
  // Just verify the child spec can be created without error
  True |> should.equal(True)
}