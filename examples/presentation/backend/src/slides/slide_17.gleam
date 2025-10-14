//// Slide 17: Pagination & Partial Reloads
////
//// Introduction to pagination with partial reload optimization

import shared/content.{
  type Slide, BulletList, Heading, LinkButton, Paragraph, Slide, Spacer,
  Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 17,
    title: "Pagination & Partial Reloads",
    content: [
      Heading("Pagination & Deferred Props"),
      Subheading("Optimizing with DeferProp"),
      Spacer,
      BulletList([
        "DeferProp loads in a separate request after initial render",
        "Page renders immediately without waiting for slow data",
        "Only specified props reload during navigation",
        "Watch the prop load with a 2-second delay",
        "Dramatically improves perceived performance",
      ]),
      Spacer,
      Paragraph(
        "Click the button below to see a paginated users table with a deferred prop. Watch it load after 2 seconds!",
      ),
      Spacer,
      LinkButton("Try the Pagination Demo →", "/users/table"),
    ],
    notes: "This slide introduces DeferProp for optimizing expensive data loading. The demo shows a users table with a DeferProp that has an artificial 2-second delay. Watch it load separately after the initial page render. When navigating pages, only the 'users', 'page', and 'total_pages' props reload - the 'demo_info' DeferProp is not re-fetched. Open browser dev tools network tab to see the separate request for the deferred prop.",
    max_steps: 1,
  )
}
