//// Demo data utilities for testing and demonstration purposes.
////
//// This module contains functions and types used specifically for demos and tests.
//// It should not be used in production code.

import data/users
import gleam/list
import sqlight.{type Connection}

/// Generate activity feed for demo purposes (expensive operation for DeferredProp demo)
/// This simulates expensive calculations and should only be used in tests/demos
pub fn generate_activity_feed(
  db: Connection,
) -> Result(users.ActivityFeed, sqlight.Error) {
  // Get recent users for activity simulation
  let users_result = users.get_all_users(db)

  case users_result {
    Ok(user_list) -> {
      let activities =
        user_list
        |> list.take(5)
        |> list.index_fold([], fn(acc, user, index) {
          let activity =
            users.Activity(
              id: index + 1,
              user_name: user.name,
              action: case index % 3 {
                0 -> "logged in"
                1 -> "updated profile"
                _ -> "created post"
              },
              timestamp: user.created_at,
            )
          [activity, ..acc]
        })
        |> list.reverse()

      Ok(users.ActivityFeed(
        recent_activities: activities,
        total_activities: list.length(user_list) * 2,
        last_updated: "2024-01-01T12:00:00Z",
      ))
    }
    Error(err) -> Error(err)
  }
}
