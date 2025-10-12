//// Slide 11: With Type-Safe Integration (Use in React)
////
//// Shows how to use the projected types in React components

import slides/content.{type Slide, CodeBlock, Heading, Spacer, Subheading}

pub fn slide() -> Slide {
  content.Slide(
    number: 11,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Use in React:"),
      CodeBlock(
        "
        import type { PageProps } from \"../types/gleam-projections\";
        type DashboardProps = PageProps<DashboardPageProp$>

        export default function Dashboard(props: DashboardProps) {
          const { name, email, role } = props;
          return ...
        }
        ",
        "tsx",
        [],
      ),
    ],
    notes: "Through clever projection types, React components get clean, type-safe props directly from Gleam definitions.",
  )
}
