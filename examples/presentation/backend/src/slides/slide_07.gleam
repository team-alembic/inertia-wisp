//// Slide 7: Inertia Pages - Fully Formed Props
////
//// How Inertia pages receive complete, validated data without loading states

import schemas/content.{
  type Slide, BulletList, CodeBlock, Heading, Paragraph, Slide, Spacer,
  Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 7,
    title: "Inertia Pages - Fully Formed Props",
    content: [
      Heading("Inertia Pages - Fully Formed Props"),
      Subheading("No loading states. No error states. Just data."),
      Spacer,
      CodeBlock(
        "function UsersTable({ users, page, total_pages }: Props) {
  const handleNext = () => {
    router.reload({
      data: { page: page + 1 },
      only: [\"users\", \"page\"]
    });
  };

  return (
    <div>
      <UsersDataTable users={users} />
      <PaginationControls
        page={page}
        total_pages={total_pages}
        onNext={handleNext}
      />
    </div>
  );
}",
        "tsx",
        [],
      ),
      Spacer,
      BulletList([
        "Props arrive fully formed - no null checks, no loading spinners",
        "Backend provides all data before rendering the page",
        "Type-safe props interface ensures props conform to expected schema",
        "Focus on UI logic, not data fetching orchestration",
      ]),
      Spacer,
      Paragraph(
        "Traditional SPAs: useState, useEffect, loading states, error boundaries, retry logic. Inertia: just render the data.",
      ),
    ],
    notes: "This slide emphasizes one of Inertia's biggest advantages - your React components receive fully formed, validated props directly. No need for loading states, error states, or complex data fetching logic. The backend ensures all data is ready before the page renders, so your frontend code stays simple and focused on presentation. This eliminates entire categories of bugs and complexity that plague traditional SPAs.",
    max_steps: 1,
  )
}
