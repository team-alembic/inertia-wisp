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

const bullet_list_0 = z.object({
  type: z.literal("bullet_list"),
  items: z.array(z.string()),
});

const code_block_1 = z.object({
  type: z.literal("code_block"),
  code: z.string(),
  highlight_lines: z.array(z.number()),
  language: z.string(),
});

const heading_3 = z.object({
  type: z.literal("heading"),
  text: z.string(),
});

const image_4 = z.object({
  type: z.literal("image"),
  alt: z.string(),
  url: z.string(),
  width: z.number(),
});

const image_row_5 = z.object({
  type: z.literal("image_row"),
  images: z.array(ImageDataSchema),
});

const link_button_6 = z.object({
  type: z.literal("link_button"),
  href: z.string(),
  text: z.string(),
});

const numbered_list_7 = z.object({
  type: z.literal("numbered_list"),
  items: z.array(z.string()),
});

const paragraph_8 = z.object({
  type: z.literal("paragraph"),
  text: z.string(),
});

const quote_9 = z.object({
  type: z.literal("quote"),
  author: z.string(),
  text: z.string(),
});

const spacer_10 = z.object({
  type: z.literal("spacer"),
});

const subheading_11 = z.object({
  type: z.literal("subheading"),
  text: z.string(),
});

type ContentBlockType =
  | z.infer<typeof bullet_list_0>
  | z.infer<typeof code_block_1>
  | {
      type: "columns";
    left: ContentBlockType[];
    right: ContentBlockType[];
    }
  | z.infer<typeof heading_3>
  | z.infer<typeof image_4>
  | z.infer<typeof image_row_5>
  | z.infer<typeof link_button_6>
  | z.infer<typeof numbered_list_7>
  | z.infer<typeof paragraph_8>
  | z.infer<typeof quote_9>
  | z.infer<typeof spacer_10>
  | z.infer<typeof subheading_11>;

export const ContentBlockSchema: z.ZodType<ContentBlockType> = z.lazy(() =>
  z.discriminatedUnion("type", [
  bullet_list_0,
  code_block_1,
  z.object({
    type: z.literal("columns"),
    left: z.array(ContentBlockSchema),
    right: z.array(ContentBlockSchema),
  }),
  heading_3,
  image_4,
  image_row_5,
  link_button_6,
  numbered_list_7,
  paragraph_8,
  quote_9,
  spacer_10,
  subheading_11,
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
