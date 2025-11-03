//// Travel booking handler
////
//// Demonstrates multi-step forms with client-side state management.
//// Shows POST -> Redirect -> GET pattern with 3 separate handlers:
//// 1. GET /travel/booking - show form
//// 2. POST /travel/booking - submit and redirect
//// 3. GET /travel/booking/:ref - show results with deferred deals

import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/int
import gleam/json
import gleam/option
import gleam/string
import inertia_wisp/inertia
import shared/travel
import wisp.{type Request, type Response}

/// Encode travel booking props to JSON dict
pub fn encode_props(
  props: travel.TravelBookingProps,
) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("info_message", json.string(props.info_message)),
    #("booking", json.nullable(props.booking, travel.encode_booking_request)),
    #("deals", json.nullable(props.deals, json.array(_, travel.encode_deal))),
  ])
}

/// Show the travel booking form (initial load)
pub fn show_travel_booking(req: Request) -> Response {
  let props =
    travel.TravelBookingProps(
      booking: option.None,
      deals: option.None,
      info_message: "✈️ Multi-step form with client-side state!",
    )

  req
  |> inertia.response_builder("TravelBooking")
  |> inertia.props(props, encode_props)
  |> inertia.response(200)
}

/// Handle booking submission - POST -> Redirect -> GET pattern
pub fn submit_booking(req: Request) -> Response {
  // Parse the booking request from form data
  use body <- wisp.require_json(req)

  let booking_result = decode.run(body, travel.decode_booking_request())

  case booking_result {
    Error(_) -> wisp.unprocessable_content()
    Ok(booking) -> {
      // Generate a simple booking reference (in real app, would store in DB)
      let booking_ref = generate_booking_ref(booking)

      // Redirect to the results page
      wisp.redirect("/travel/booking/" <> booking_ref)
    }
  }
}

/// Show booking results with deals (deferred)
pub fn show_booking_results(req: Request, booking_ref: String) -> Response {
  // In a real app, would fetch booking from DB using booking_ref
  // For demo, we'll reconstruct from the ref
  let booking = parse_booking_ref(booking_ref)

  let props =
    travel.TravelBookingProps(
      booking: option.Some(booking),
      deals: option.None,
      info_message: "🎉 Booking submitted! Finding the best deals for your trip...",
    )

  req
  |> inertia.response_builder("TravelBooking")
  |> inertia.props(props, encode_props)
  |> inertia.defer("deals", fn(props) {
    process.sleep(5000)
    let deals = travel.generate_deals(booking)
    Ok(travel.TravelBookingProps(..props, deals: option.Some(deals)))
  })
  |> inertia.response(200)
}

/// Generate a booking reference from the booking data
/// In a real app, this would be a UUID or database ID
fn generate_booking_ref(booking: travel.BookingRequest) -> String {
  // Encode all booking data into the ref (URL-safe)
  // Format: date:origin:destination:passengers:class
  booking.departure_date
  <> ":"
  <> booking.origin
  <> ":"
  <> booking.destination
  <> ":"
  <> int.to_string(booking.passengers)
  <> ":"
  <> case booking.travel_class {
    travel.Economy -> "economy"
    travel.Business -> "business"
    travel.FirstClass -> "first_class"
  }
}

/// Parse booking reference back to BookingRequest
/// In a real app, would fetch from database
fn parse_booking_ref(ref: String) -> travel.BookingRequest {
  // Parse the encoded booking data from the ref
  // Format: date:origin:destination:passengers:class
  let parts = string.split(ref, ":")

  case parts {
    [date, origin, destination, passengers_str, class_str] -> {
      let passengers = case int.parse(passengers_str) {
        Ok(p) -> p
        Error(_) -> 1
      }

      let travel_class = case class_str {
        "business" -> travel.Business
        "first_class" -> travel.FirstClass
        _ -> travel.Economy
      }

      travel.BookingRequest(
        departure_date: date,
        origin: origin,
        destination: destination,
        passengers: passengers,
        travel_class: travel_class,
      )
    }
    _ -> {
      // Fallback for invalid refs
      travel.BookingRequest(
        departure_date: "2025-12-01",
        origin: "New York",
        destination: "London",
        passengers: 2,
        travel_class: travel.Economy,
      )
    }
  }
}
