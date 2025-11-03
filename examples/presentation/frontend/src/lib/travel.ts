/**
 * Clean re-exports for Travel booking types and accessors
 * Provides readable names for Gleam-compiled types
 */

import {
  decode_travel_booking_props,
  type TravelBookingProps$,
  TravelBookingProps$TravelBookingProps$booking,
  TravelBookingProps$TravelBookingProps$deals,
  TravelBookingProps$TravelBookingProps$info_message,
  type BookingRequest$,
  BookingRequest$BookingRequest,
  BookingRequest$BookingRequest$departure_date,
  BookingRequest$BookingRequest$origin,
  BookingRequest$BookingRequest$destination,
  BookingRequest$BookingRequest$passengers,
  BookingRequest$BookingRequest$travel_class,
  encode_booking_request,
  set_departure_date,
  set_origin,
  set_destination,
  set_passengers,
  set_travel_class,
  type TravelClass$,
  Economy,
  Business,
  FirstClass,
  travel_class_to_string,
  type Deal$,
  Deal$Deal$airline,
  Deal$Deal$flight_number,
  Deal$Deal$price,
  Deal$Deal$duration_hours,
  Deal$Deal$stops,
} from "@shared/travel.mjs";

// Type exports
export type TravelBookingProps = TravelBookingProps$;
export type BookingRequest = BookingRequest$;
export type TravelClass = TravelClass$;
export type Deal = Deal$;

// Decoder
export const decodeTravelBookingProps = decode_travel_booking_props;

// TravelBookingProps accessors
export const getBooking = TravelBookingProps$TravelBookingProps$booking;
export const getDeals = TravelBookingProps$TravelBookingProps$deals;
export const getInfoMessage =
  TravelBookingProps$TravelBookingProps$info_message;

// BookingRequest constructor and accessors
export const createBookingRequest = BookingRequest$BookingRequest;
export const getDepartureDate = BookingRequest$BookingRequest$departure_date;
export const getOrigin = BookingRequest$BookingRequest$origin;
export const getDestination = BookingRequest$BookingRequest$destination;
export const getPassengers = BookingRequest$BookingRequest$passengers;
export const getTravelClass = BookingRequest$BookingRequest$travel_class;

// BookingRequest encoder and decoder
export const encodeBookingRequest = encode_booking_request;

// BookingRequest field updaters (using Gleam spread operator)
export const setDepartureDate = set_departure_date;
export const setOrigin = set_origin;
export const setDestination = set_destination;
export const setPassengers = set_passengers;
export const setTravelClass = set_travel_class;

// TravelClass constructors
export { Economy, Business, FirstClass };

// TravelClass helpers
export const travelClassToString = travel_class_to_string;

// Deal accessors
export const getAirline = Deal$Deal$airline;
export const getFlightNumber = Deal$Deal$flight_number;
export const getPrice = Deal$Deal$price;
export const getDurationHours = Deal$Deal$duration_hours;
export const getStops = Deal$Deal$stops;
