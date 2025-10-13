import fc from "fast-check";
import * as GleamContent from "../../shared/build/dev/javascript/shared/shared/content.mjs";
import type {
  ImageData$,
  ContentBlock$,
  Slide$,
  SlideNavigation$,
} from "../../shared/build/dev/javascript/shared/shared/content.d.mts";
import { toList } from "../../shared/build/dev/javascript/shared/gleam.mjs";

// Fast-check arbitraries that generate Gleam types directly

export const imageDataArbitrary: fc.Arbitrary<ImageData$> = fc
  .record({
    url: fc.webUrl(),
    alt: fc.string(),
    width: fc.integer({ min: 1, max: 2000 }),
  })
  .map(({ url, alt, width }) =>
    GleamContent.ImageData$ImageData(url, alt, width),
  );

const headingArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .string()
  .map((text) => GleamContent.ContentBlock$Heading(text));

const subheadingArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .string()
  .map((text) => GleamContent.ContentBlock$Subheading(text));

const paragraphArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .string()
  .map((text) => GleamContent.ContentBlock$Paragraph(text));

const codeBlockArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .record({
    code: fc.string(),
    language: fc.constantFrom("gleam", "typescript", "javascript", "rust"),
    highlight_lines: fc.array(fc.integer({ min: 1, max: 100 })),
  })
  .map(({ code, language, highlight_lines }) =>
    GleamContent.ContentBlock$CodeBlock(
      code,
      language,
      toList(highlight_lines),
    ),
  );

const bulletListArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .array(fc.string(), { minLength: 1, maxLength: 10 })
  .map((items) => GleamContent.ContentBlock$BulletList(toList(items)));

const numberedListArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .array(fc.string(), { minLength: 1, maxLength: 10 })
  .map((items) => GleamContent.ContentBlock$NumberedList(toList(items)));

const quoteArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .record({
    text: fc.string(),
    author: fc.string(),
  })
  .map(({ text, author }) => GleamContent.ContentBlock$Quote(text, author));

const imageBlockArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .record({
    url: fc.webUrl(),
    alt: fc.string(),
    width: fc.integer({ min: 1, max: 2000 }),
  })
  .map(({ url, alt, width }) =>
    GleamContent.ContentBlock$Image(url, alt, width),
  );

const imageRowArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .array(imageDataArbitrary, { minLength: 1, maxLength: 5 })
  .map((images) => GleamContent.ContentBlock$ImageRow(toList(images)));

const spacerArbitrary: fc.Arbitrary<ContentBlock$> = fc.constant(
  GleamContent.ContentBlock$Spacer(),
);

const linkButtonArbitrary: fc.Arbitrary<ContentBlock$> = fc
  .record({
    text: fc.string(),
    href: fc.webUrl(),
  })
  .map(({ text, href }) => GleamContent.ContentBlock$LinkButton(text, href));

// Full content block including recursive Columns (with limited depth)
export const contentBlockArbitrary: fc.Arbitrary<ContentBlock$> = fc.letrec(
  (tie) => ({
    block: fc.oneof(
      { maxDepth: 3 },
      headingArbitrary,
      subheadingArbitrary,
      paragraphArbitrary,
      codeBlockArbitrary,
      bulletListArbitrary,
      numberedListArbitrary,
      quoteArbitrary,
      imageBlockArbitrary,
      imageRowArbitrary,
      spacerArbitrary,
      linkButtonArbitrary,
      fc
        .record({
          left: fc.array(tie("block") as fc.Arbitrary<ContentBlock$>, {
            maxLength: 3,
          }),
          right: fc.array(tie("block") as fc.Arbitrary<ContentBlock$>, {
            maxLength: 3,
          }),
        })
        .map(({ left, right }) =>
          GleamContent.ContentBlock$Columns(toList(left), toList(right)),
        ),
    ),
  }),
).block;

export const slideArbitrary: fc.Arbitrary<Slide$> = fc
  .record({
    number: fc.integer({ min: 1, max: 100 }),
    title: fc.string(),
    content: fc.array(contentBlockArbitrary, { maxLength: 10 }),
    notes: fc.string(),
  })
  .map(({ number, title, content, notes }) =>
    GleamContent.Slide$Slide(number, title, toList(content), notes),
  );

export const slideNavigationArbitrary: fc.Arbitrary<SlideNavigation$> = fc
  .record({
    current: fc.integer({ min: 1, max: 100 }),
    total: fc.integer({ min: 1, max: 100 }),
  })
  .map(({ current, total }) => {
    const has_previous = current > 1;
    const has_next = current < total;
    const previous_url = has_previous ? `/slides/${current - 1}` : "#";
    const next_url = has_next ? `/slides/${current + 1}` : "#";
    return GleamContent.SlideNavigation$SlideNavigation(
      current,
      total,
      has_previous,
      has_next,
      previous_url,
      next_url,
    );
  });
