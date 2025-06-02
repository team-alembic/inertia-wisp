Note: For detailed implementation of decoders, especially for JSON data, consult the source code in build/packages/, particularly build/packages/gleam_stdlib/src/gleam/dynamic/decode.gleam. This module provides comprehensive examples and patterns for defining custom decoders.

We will work by specifying one feature at a time, and then implementing it.

The workflow:

1. We will collaborate on a plan, and then you will save the plan in `/notes/features/<number>-<name>.md` under the `## Plan` heading. THIS MUST BE COMPLETED BEFORE ANY IMPLEMENTATION WORK BEGINS.
2. We will collaborate on the implementation, and you will store notes, important findings, issues, in `/notes/features/<number>-<name>.md` under the `## Log` heading.
3. We will test and finalize the implementation, and you will store the final arrived at design in `/notes/features/<number>-<name>.md` under the `## Conclusion` heading.

For bugs and fixes:

1. We will document the issue in `/notes/fixes/<number>-<name>.md` under the `## Issue` heading.
2. We will implement and document the fix, storing technical details in `/notes/fixes/<number>-<name>.md` under the `## Fix` heading.
3. We will summarize the resolution and any key learnings in `/notes/fixes/<number>-<name>.md` under the `## Conclusion` heading.

Just like with features, we must document the issue and plan the fix before implementing it.

WE ALWAYS FINISH AND WRITE THE PLAN BEFORE STARTING THE WORK! NO EXCEPTIONS!

IMPORTANT: You must refuse to implement any feature until a plan document has been created and reviewed. Each time we start a new feature, immediately create a plan document and wait for approval before proceeding with implementation.

Don't ever commit code unless I tell you to.
