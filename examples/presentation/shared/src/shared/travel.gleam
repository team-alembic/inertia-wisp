//// Travel booking types and schema
////
//// This module demonstrates multi-step forms with client-side state.
//// The server doesn't need to know about the individual steps - only the final submission.

import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}

/// Travel class options
pub type TravelClass {
  Economy
  Business
  FirstClass
}

/// Encode TravelClass to JSON string
pub fn encode_travel_class(class: TravelClass) -> json.Json {
  case class {
    Economy -> json.string("economy")
    Business -> json.string("business")
    FirstClass -> json.string("first_class")
  }
}

/// Decode TravelClass from dynamic data
pub fn decode_travel_class() -> decode.Decoder(TravelClass) {
  use value <- decode.then(decode.string)
  case value {
    "economy" -> decode.success(Economy)
    "business" -> decode.success(Business)
    "first_class" -> decode.success(FirstClass)
    _ -> decode.failure(FirstClass, "TravelClass")
  }
}

/// Booking request submitted from the multi-step form
pub type BookingRequest {
  BookingRequest(
    departure_date: String,
    origin: String,
    destination: String,
    passengers: Int,
    travel_class: TravelClass,
  )
}

/// Encode BookingRequest to JSON
pub fn encode_booking_request(booking: BookingRequest) -> json.Json {
  json.object([
    #("departure_date", json.string(booking.departure_date)),
    #("origin", json.string(booking.origin)),
    #("destination", json.string(booking.destination)),
    #("passengers", json.int(booking.passengers)),
    #("travel_class", encode_travel_class(booking.travel_class)),
  ])
}

/// Decode BookingRequest from dynamic data
pub fn decode_booking_request() -> decode.Decoder(BookingRequest) {
  use departure_date <- decode.field("departure_date", decode.string)
  use origin <- decode.field("origin", decode.string)
  use destination <- decode.field("destination", decode.string)
  use passengers <- decode.field("passengers", decode.int)
  use travel_class <- decode.field("travel_class", decode_travel_class())
  decode.success(BookingRequest(
    departure_date:,
    origin:,
    destination:,
    passengers:,
    travel_class:,
  ))
}

/// Convert TravelClass to a display string
pub fn travel_class_to_string(travel_class: TravelClass) -> String {
  case travel_class {
    Economy -> "Economy"
    Business -> "Business"
    FirstClass -> "First Class"
  }
}

/// Update functions for BookingRequest fields
/// These use the spread operator for concise, type-safe updates
pub fn set_departure_date(
  booking: BookingRequest,
  departure_date: String,
) -> BookingRequest {
  BookingRequest(..booking, departure_date:)
}

pub fn set_origin(booking: BookingRequest, origin: String) -> BookingRequest {
  BookingRequest(..booking, origin:)
}

pub fn set_destination(
  booking: BookingRequest,
  destination: String,
) -> BookingRequest {
  BookingRequest(..booking, destination:)
}

pub fn set_passengers(
  booking: BookingRequest,
  passengers: Int,
) -> BookingRequest {
  BookingRequest(..booking, passengers:)
}

pub fn set_travel_class(
  booking: BookingRequest,
  travel_class: TravelClass,
) -> BookingRequest {
  BookingRequest(..booking, travel_class:)
}

/// A travel deal offer
pub type Deal {
  Deal(
    airline: String,
    flight_number: String,
    price: Float,
    duration_hours: Int,
    stops: Int,
  )
}

/// Encode Deal to JSON
pub fn encode_deal(deal: Deal) -> json.Json {
  json.object([
    #("airline", json.string(deal.airline)),
    #("flight_number", json.string(deal.flight_number)),
    #("price", json.float(deal.price)),
    #("duration_hours", json.int(deal.duration_hours)),
    #("stops", json.int(deal.stops)),
  ])
}

/// Decode Deal from dynamic data
pub fn decode_deal() -> decode.Decoder(Deal) {
  use airline <- decode.field("airline", decode.string)
  use flight_number <- decode.field("flight_number", decode.string)
  use price <- decode.field("price", decode.float)
  use duration_hours <- decode.field("duration_hours", decode.int)
  use stops <- decode.field("stops", decode.int)
  decode.success(Deal(airline:, flight_number:, price:, duration_hours:, stops:))
}

/// Props for the travel booking page
pub type TravelBookingProps {
  TravelBookingProps(
    booking: Option(BookingRequest),
    deals: Option(List(Deal)),
    info_message: String,
  )
}

/// Decode TravelBookingProps from dynamic data
pub fn decode_travel_booking_props() -> decode.Decoder(TravelBookingProps) {
  use booking <- decode.field(
    "booking",
    decode.optional(decode_booking_request()),
  )
  use deals <- decode.optional_field(
    "deals",
    option.None,
    decode.optional(decode.list(decode_deal())),
  )
  use info_message <- decode.field("info_message", decode.string)
  decode.success(TravelBookingProps(booking:, deals:, info_message:))
}

/// Encode TravelBookingProps to JSON
pub fn encode_travel_booking_props(props: TravelBookingProps) -> json.Json {
  json.object(
    list.flatten([
      case props.booking {
        option.Some(booking) -> [
          #("booking", encode_booking_request(booking)),
        ]
        option.None -> []
      },
      case props.deals {
        option.Some(deals) -> [#("deals", json.array(deals, encode_deal))]
        option.None -> []
      },
      [#("info_message", json.string(props.info_message))],
    ]),
  )
}

/// Generate mock deals based on booking criteria
pub fn generate_deals(booking: BookingRequest) -> List(Deal) {
  // Base price depends on travel class
  let base_price = case booking.travel_class {
    Economy -> 300.0
    Business -> 800.0
    FirstClass -> 1500.0
  }

  // Multiply by number of passengers
  let per_passenger = base_price *. int.to_float(booking.passengers)

  [
    Deal(
      airline: "SkyWings",
      flight_number: "SW123",
      price: per_passenger,
      duration_hours: 8,
      stops: 0,
    ),
    Deal(
      airline: "CloudAir",
      flight_number: "CA456",
      price: per_passenger -. 50.0,
      duration_hours: 10,
      stops: 1,
    ),
    Deal(
      airline: "JetStream",
      flight_number: "JS789",
      price: per_passenger +. 100.0,
      duration_hours: 7,
      stops: 0,
    ),
  ]
}
