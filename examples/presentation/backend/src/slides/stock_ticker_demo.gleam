//// Slide 14: Stock Ticker Demo
////
//// Introduction to the live stock ticker demo

import schemas/content_block.{
  BulletList, Heading, LinkButton, Paragraph, Spacer, Subheading,
}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 0,
    title: "Live Demo: Stock Ticker",
    content: [
      Heading("Live Demo: Stock Ticker"),
      Subheading("Gleam Decoders + Polling + Merge Props"),
      Spacer,
      BulletList([
        "✨ Props validated with Gleam decoder compiled to JavaScript",
        "🔄 Auto-refreshes every 2 seconds using usePoll hook",
        "🎯 React useState accumulates price history client-side",
        "📊 Watch sparklines grow as price history builds up",
        "🚀 Same decoder validates on backend AND frontend!",
      ]),
      Spacer,
      Paragraph(
        "Backend sends current prices only. Frontend accumulates history using useState + useEffect keyed by timestamp. This demonstrates client-side state management with Inertia polling.",
      ),
      Spacer,
      LinkButton("Try the Stock Ticker Demo →", "/stocks/ticker"),
    ],
    notes: "This demo showcases: (1) Type Safety Approach #1 - Gleam decoders compiled to JavaScript, (2) Inertia's usePoll hook for auto-refresh, (3) Client-side state accumulation. The key insight: Backend sends only current prices, frontend accumulates history using useState. useEffect keyed by timestamp detects new data and adds points to history. This is a clean pattern for building up client-side state from polling updates. Open console to see Gleam decoder validating on every update!",
    max_steps: 1,
  )
}
