// Auto-generated from Gleam schemas - DO NOT EDIT

import { z } from "zod";

export const UserSchema = z.object({
  email: z.string(),
  id: z.number(),
  name: z.string(),
}).strict();

export type User = z.infer<typeof UserSchema>;

export const ContactFormDataSchema = z.object({
  email: z.string(),
  message: z.string(),
  name: z.string(),
}).strict();

export type ContactFormData = z.infer<typeof ContactFormDataSchema>;

export const ImageDataSchema = z.object({
  alt: z.string(),
  url: z.string(),
  width: z.number(),
}).strict();

export type ImageData = z.infer<typeof ImageDataSchema>;

export const SlideNavigationSchema = z.object({
  current: z.number(),
  has_next: z.boolean(),
  has_previous: z.boolean(),
  next_url: z.string(),
  previous_url: z.string(),
  total: z.number(),
}).strict();

export type SlideNavigation = z.infer<typeof SlideNavigationSchema>;

const BulletListSchema = z.object({
  type: z.literal("bullet_list"),
  items: z.array(z.string()),
});

const CodeBlockSchema = z.object({
  type: z.literal("code_block"),
  code: z.string(),
  highlight_lines: z.array(z.number()),
  language: z.string(),
});

const HeadingSchema = z.object({
  type: z.literal("heading"),
  text: z.string(),
});

const ImageSchema = z.object({
  type: z.literal("image"),
  alt: z.string(),
  url: z.string(),
  width: z.number(),
});

const ImageRowSchema = z.object({
  type: z.literal("image_row"),
  images: z.array(ImageDataSchema),
});

const LinkButtonSchema = z.object({
  type: z.literal("link_button"),
  href: z.string(),
  text: z.string(),
});

const NumberedListSchema = z.object({
  type: z.literal("numbered_list"),
  items: z.array(z.string()),
});

const ParagraphSchema = z.object({
  type: z.literal("paragraph"),
  text: z.string(),
});

const QuoteSchema = z.object({
  type: z.literal("quote"),
  author: z.string(),
  text: z.string(),
});

const SpacerSchema = z.object({
  type: z.literal("spacer"),
});

const SubheadingSchema = z.object({
  type: z.literal("subheading"),
  text: z.string(),
});

type ContentBlockType =
  | z.infer<typeof BulletListSchema>
  | z.infer<typeof CodeBlockSchema>
  | {
      type: "columns";
    left: ContentBlockType[];
    right: ContentBlockType[];
    }
  | z.infer<typeof HeadingSchema>
  | z.infer<typeof ImageSchema>
  | z.infer<typeof ImageRowSchema>
  | z.infer<typeof LinkButtonSchema>
  | z.infer<typeof NumberedListSchema>
  | z.infer<typeof ParagraphSchema>
  | z.infer<typeof QuoteSchema>
  | z.infer<typeof SpacerSchema>
  | z.infer<typeof SubheadingSchema>;

export const ContentBlockSchema: z.ZodType<ContentBlockType> = z.lazy(() =>
  z.discriminatedUnion("type", [
  BulletListSchema,
  CodeBlockSchema,
  z.object({
    type: z.literal("columns"),
    left: z.array(ContentBlockSchema),
    right: z.array(ContentBlockSchema),
  }),
  HeadingSchema,
  ImageSchema,
  ImageRowSchema,
  LinkButtonSchema,
  NumberedListSchema,
  ParagraphSchema,
  QuoteSchema,
  SpacerSchema,
  SubheadingSchema,
  ]),
);

export type ContentBlock = ContentBlockType;

export const SlideSchema = z.object({
  content: z.array(ContentBlockSchema),
  max_steps: z.number(),
  notes: z.string(),
  number: z.number(),
  title: z.string(),
}).strict();

export type Slide = z.infer<typeof SlideSchema>;
