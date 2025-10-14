import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { z } from "zod";
import {
  SlideSchema,
  SlideNavigationSchema,
  UserSchema,
  UsersTablePagePropsSchema,
} from "../src/schemas.js";
import * as GleamContent from "@shared/content.mjs";
import * as GleamUser from "@shared/user.mjs";
import * as GleamJson from "@gleam/gleam_json/gleam/json.mjs";
import {
  slideArbitrary,
  slideNavigationArbitrary,
  userArbitrary,
} from "./arbitraries.js";

// Custom assertion: verifies that a Gleam value encodes to JSON that validates with Zod
// Also verifies strictness by ensuring extra properties are rejected
function assertEncodesToSchema<T>(
  value: T,
  encoder: (value: T) => unknown,
  schema: z.ZodSchema,
): void {
  // 1. Run Gleam JSON encoder
  const jsonObject = encoder(value);
  const jsonString = GleamJson.to_string(jsonObject);

  // 2. Parse string
  const parsed = JSON.parse(jsonString);

  // 3. Assert Zod validates successfully (strict mode)
  const result = schema.safeParse(parsed);
  expect(result.success).toBe(true);

  // 4. Verify strictness: adding extra properties should fail validation
  const withExtra = { ...parsed, __unexpected_field__: "should fail" };
  const strictResult = schema.safeParse(withExtra);
  expect(strictResult.success).toBe(false);
  if (!strictResult.success) {
    expect(strictResult.error.issues[0].code).toBe("unrecognized_keys");
  }
}

describe("Property-based type safety tests", () => {
  it("User: user_to_json can be parsed by UserSchema", () => {
    fc.assert(
      fc.property(userArbitrary, (gleamValue) => {
        assertEncodesToSchema(gleamValue, GleamUser.user_to_json, UserSchema);
      }),
      { numRuns: 1000 },
    );
  });

  it("Slide: slide_to_json can be parsed by SlideSchema", () => {
    fc.assert(
      fc.property(slideArbitrary, (gleamValue) => {
        assertEncodesToSchema(
          gleamValue,
          GleamContent.slide_to_json,
          SlideSchema,
        );
      }),
      { numRuns: 1000 },
    );
  });

  it("SlideNavigation: slide_navigation_to_json can be parsed by SlideNavigationSchema", () => {
    fc.assert(
      fc.property(slideNavigationArbitrary, (gleamValue) => {
        assertEncodesToSchema(
          gleamValue,
          GleamContent.slide_navigation_to_json,
          SlideNavigationSchema,
        );
      }),
      { numRuns: 1000 },
    );
  });
});
