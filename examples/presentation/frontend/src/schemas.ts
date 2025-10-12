// Zod schemas for validating props from Gleam backend
// These match the JSON structure produced by the backend encoders

import { z } from "zod";

// ImageData schema
export const ImageDataSchema = z.object({
  url: z.string(),
  alt: z.string(),
  width: z.number(),
});

// ContentBlock schemas with discriminated union
const HeadingBlockSchema = z.object({
  type: z.literal("heading"),
  text: z.string(),
});

const SubheadingBlockSchema = z.object({
  type: z.literal("subheading"),
  text: z.string(),
});

const ParagraphBlockSchema = z.object({
  type: z.literal("paragraph"),
  text: z.string(),
});

const CodeBlockSchema = z.object({
  type: z.literal("code_block"),
  code: z.string(),
  language: z.string(),
  highlight_lines: z.array(z.number()),
});

const BulletListBlockSchema = z.object({
  type: z.literal("bullet_list"),
  items: z.array(z.string()),
});

const NumberedListBlockSchema = z.object({
  type: z.literal("numbered_list"),
  items: z.array(z.string()),
});

const QuoteBlockSchema = z.object({
  type: z.literal("quote"),
  text: z.string(),
  author: z.string(),
});

const ImageBlockSchema = z.object({
  type: z.literal("image"),
  url: z.string(),
  alt: z.string(),
  width: z.number(),
});

const ImageRowBlockSchema = z.object({
  type: z.literal("image_row"),
  images: z.array(ImageDataSchema),
});

const SpacerBlockSchema = z.object({
  type: z.literal("spacer"),
});

// Recursive type using z.lazy() for proper type inference
export const ContentBlockSchema: z.ZodType<
  | z.infer<typeof HeadingBlockSchema>
  | z.infer<typeof SubheadingBlockSchema>
  | z.infer<typeof ParagraphBlockSchema>
  | z.infer<typeof CodeBlockSchema>
  | z.infer<typeof BulletListBlockSchema>
  | z.infer<typeof NumberedListBlockSchema>
  | z.infer<typeof QuoteBlockSchema>
  | z.infer<typeof ImageBlockSchema>
  | z.infer<typeof ImageRowBlockSchema>
  | z.infer<typeof SpacerBlockSchema>
  | {
      type: "columns";
      left: Array<z.infer<typeof ContentBlockSchema>>;
      right: Array<z.infer<typeof ContentBlockSchema>>;
    }
> = z.lazy(() =>
  z.discriminatedUnion("type", [
    HeadingBlockSchema,
    SubheadingBlockSchema,
    ParagraphBlockSchema,
    CodeBlockSchema,
    BulletListBlockSchema,
    NumberedListBlockSchema,
    QuoteBlockSchema,
    ImageBlockSchema,
    ImageRowBlockSchema,
    z.object({
      type: z.literal("columns"),
      left: z.array(ContentBlockSchema),
      right: z.array(ContentBlockSchema),
    }),
    SpacerBlockSchema,
  ]),
);

// Slide schema
export const SlideSchema = z.object({
  number: z.number(),
  title: z.string(),
  content: z.array(ContentBlockSchema),
  notes: z.string(),
});

// SlideNavigation schema
export const SlideNavigationSchema = z.object({
  current: z.number(),
  total: z.number(),
  has_previous: z.boolean(),
  has_next: z.boolean(),
  previous_url: z.string(),
  next_url: z.string(),
});

// SlidePageProps schema
export const SlidePagePropsSchema = z.object({
  slide: SlideSchema,
  navigation: SlideNavigationSchema,
  presentation_title: z.string(),
});

// Export inferred types
export type ImageData = z.infer<typeof ImageDataSchema>;
export type ContentBlock = z.infer<typeof ContentBlockSchema>;
export type Slide = z.infer<typeof SlideSchema>;
export type SlideNavigation = z.infer<typeof SlideNavigationSchema>;
export type SlidePageProps = z.infer<typeof SlidePagePropsSchema>;
