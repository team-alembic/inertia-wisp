//// Slide: Travel Booking Demo
////
//// Introduction to the multi-step travel booking demo

import schemas/content_block.{
  BulletList, Heading, LinkButton, Paragraph, Spacer, Subheading,
}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 0,
    title: "Live Demo: Multi-Step Travel Booking",
    content: [
      Heading("Live Demo: Multi-Step Travel Booking"),
      Subheading("Client-Side State + POST-Redirect-GET + Deferred Props"),
      Spacer,
      BulletList([
        "📝 4-step form managed entirely with React useState",
        "🔄 Users can navigate back to modify previous steps",
        "🎯 Server only sees final submission - not individual steps",
        "✈️ POST-Redirect-GET pattern: one component, three handlers",
        "⏱️ Deferred props load flight deals after submission",
      ]),
      Spacer,
      Paragraph(
        "This demo shows how frontend and backend are decoupled. The single TravelBooking component works with three different backend handlers: GET /booking (form), POST /booking (submit), and GET /booking/:ref (results). Multi-step state lives entirely in React.",
      ),
      Spacer,
      LinkButton("Try the Travel Booking Demo →", "/travel/booking"),
    ],
    notes: "This demo showcases: (1) Client-side multi-step forms - all 4 steps managed in React with useState, server doesn't know about steps, (2) POST-Redirect-GET pattern - proper RESTful flow with redirect after submission, (3) Frontend/Backend decoupling - single component interacts with 3 different handlers, (4) Deferred props - deals load lazily to simulate external API query. Key insight: The server doesn't need to care about UI flow. Steps 1-4 are entirely client-side. Only final submission matters to backend. This enables rich UX without server complexity.",
    max_steps: 1,
  )
}
