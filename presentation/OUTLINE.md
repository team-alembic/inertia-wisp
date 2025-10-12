# Gleam + TypeScript: Full-Stack Type Safety With Inertia-Wisp

**40-minute Conference Presentation Outline**

---

## I. Title & Acknowledgments (0.5 min)
- **Title slide**: Gleam + TypeScript: Full-Stack Type Safety With Inertia-Wisp
- **Sponsor acknowledgment**: "Thank you to [Your Employer] for sponsoring my attendance at this conference and supporting this work"
- Keep it brief and gracious - don't dwell on it

## II. About Me (1 min)
- Name and role
- Experience with Gleam/TypeScript/BEAM
- Why you built inertia-wisp
- Brief context: "I wanted to explore how modern AI tools could help teams adopt new languages"
- Keep it personal but concise - audience wants to get to the content

## III. Opening Hook: The Industry Problem (3-4 min)

### The Frontend Situation
- **Stack Overflow Survey 2025**: JavaScript used by 66% of developers (most popular language)
- TypeScript: 48.8% of professional developers
- React is the most popular frontend framework at 46.9% among professionals
- Teams have years of expertise invested

### The Backend Dilemma
- Backend language choice increasingly driven by frontend integration needs
- **The Full-Stack TypeScript Movement**:
  - Next.js: React framework with Node.js backend
  - Remix: TypeScript-first, full-stack framework
  - tRPC: End-to-end type safety in TypeScript ecosystem
- **The Value Proposition**: "Keep everything in TypeScript - types, tooling, team expertise"
- **The Trade-off**: You're locked into Node.js runtime characteristics

### But What If...
- What if you could keep your TypeScript/React expertise on the frontend?
- **AND** use a backend language that gives you:
  - ✅ Static typing
  - ✅ Functional programming
  - ✅ Beautiful, simple syntax
  - ✅ Fast builds
  - ✅ Crystal-clear error messages
  - ✅ **BEAM superpowers**: clustering, messaging, process supervision, massive scalability

### The Question This Talk Answers
- "Can we have both worlds?"
- "Can TypeScript teams adopt a different backend without losing type safety?"
- "Can we learn a new language fast enough to be productive?"
- **Demo teaser**: Show the final application briefly - "This is what's possible"

## IV. What Makes Gleam Special? (5 min)

### The Core Insight: Simplicity (Not What You Think)

**Many languages claim to be "simple"**
- Lisp family: Small core + powerful metaprogramming = build your own language
- Go: Limited features = fewer ways to do things wrong
- Python: Readable syntax = looks like English

**Gleam's simplicity is different - it's simplicity for the application programmer**

### Three Pillars of Gleam's Simplicity

#### 1. Straightforward Paradigm
- **Declare types** - describe your data
- **Write functions** - transform values of those types
- **Organize in modules** - that map directly to the filesystem
- That's it. No hidden magic.

#### 2. No Metaprogramming = Syntactic Familiarity
- Every piece of Gleam code you encounter **feels familiar**
- No macros that change the language under your feet
- No DSLs that require learning new syntax
- You understand code by:
  - Looking at the function's type signature
  - Reading the type definitions it operates on
  - Following the logic - it's all right there

#### 3. Simple Type System = Single Source of Truth
- No ad-hoc polymorphism
- No type classes or traits
- No higher-kinded types
- **Result**: Every function has exactly one definition
- Want to know what `map` does? Follow the import to its single definition
- No hunting through trait implementations or type class instances

### Why This Matters for Your Team

**For humans:**
- Onboarding is fast - the whole language fits in your head
- Code reviews are easier - less "clever" code to decipher
- Maintenance is predictable - code does what it looks like it does

**For AI assistants (critical for your adoption story):**
- Small syntax = fewer tokens to understand
- No metaprogramming = no context-dependent behavior
- Single definitions = Agent can find and read the actual code
- Explicit imports = clear dependency graph

### The BEAM Bonus
- All of this simplicity **compiles to the BEAM**
- You get fault tolerance, concurrency, scalability
- Without language complexity

### The Trade-offs (Be Honest)

**1. Embedded DSLs aren't as expressive**
- Languages like Elixir have powerful embedded DSLs (Ecto queries, Ash resources)
- Gleam's lack of metaprogramming means you can't build these
- **Instead**: External DSLs with code generation
- **Example**: Squirrel - write `.sql` files with parameterized queries, generate type-safe Gleam code
- Trade-off: More explicit, less "magical," but you lose the seamless embedding

**2. Generic abstractions require explicit dictionary passing**
- No type classes/traits means no implicit polymorphism
- **Instead**: Pass behavior explicitly as function parameters or operations structs
- **Example**: Instead of a generic `Sortable` trait, pass a comparison function
- Trade-off: More verbose, but always explicit about what's happening


### Transition to Demo
- "Let me show you what this looks like in practice..."

## V. Demo Application Overview (5 min)

### Show the User Experience
- SPA-like navigation (no full page reloads)
- Instant feedback
- Smooth transitions
- Server-side rendering for first load

### Architecture Overview Diagram
- Backend: Gleam + Wisp (HTTP framework)
- Frontend: React + TypeScript
- Bridge: Inertia.js
- Key insight: Each world stays in its comfort zone

## VI. Understanding Inertia.js: The Bridge (5 min)

### The Core Concept: SPA UX with Traditional Backends

**What Inertia.js gives you:**
- Single-page application user experience
- Without building a separate API
- Server-side routing and rendering
- Client-side navigation and state

### Clear Separation of Concerns

**Backend Responsibilities (Gleam + Wisp):**
- Routing - which URL goes where
- Navigation - deciding what page to show
- Validations - ensuring data is correct
- Authorization - who can access what
- Data fetching and business logic

**Frontend Responsibilities (React + TypeScript):**
- Rendering props received from backend
- Component-local UI state (form inputs, modals, etc.)
- Browser history management
- Client-side interactions

### Beyond the Basics

**You can still use traditional APIs:**
- Ad-hoc `fetch()` calls from frontend work fine
- Inertia doesn't prevent you from building REST/GraphQL endpoints
- Use Inertia for page navigation, fetch for real-time updates

**Inertia Protocol Powers:**
- **Partial reloads**: Only fetch specific props when needed
- **Lazy data evaluation**: Defer expensive computations until after first render
- **Example**: Load paginated data without full page reload
- **Example**: Render page immediately, load analytics data in background

### Why This Matters for Type Safety

**Inertia creates a clear contract:**
- Backend sends props as JSON
- Frontend receives props as typed data
- This boundary is where type safety becomes critical
- This is what we'll focus on next: how to make this boundary safe

## VII. The Type Safety Journey (20 min)

**The Evolution of Type Safety at the Gleam/TypeScript Boundary**

### Stage 0: The Naive Approach (2 min)
```typescript
function UserIndex({ props }: { props: any }) {
  // Hope and pray
}
```
- **Problem**: No type safety at all
- **Risk**: Runtime errors everywhere
- **AI Assistance Note**: Even AI can't help when types are `any`

### Stage 1: TypeScript Interface Declarations (3 min)
```typescript
interface UserIndexProps {
  users: User[];
  pagination: PaginationMeta;
}
```
- **Problem**: Types that lie - backend can send anything
- **Disconnect**: Gleam backend types vs TypeScript frontend types drift apart
- **AI Assistance**: AI can generate interfaces, but can't guarantee correctness

### Stage 2: Runtime Validation with Zod (4 min)
```typescript
const UserIndexPropsSchema = z.object({
  users: z.array(UserSchema),
  pagination: PaginationMetaSchema,
});
```
- **Improvement**: Runtime validation catches mismatches
- **Problem**: Still maintaining two type systems manually
- **Problem**: Schema maintenance burden
- **AI Assistance**: AI can write schemas, but they still drift from backend

### Stage 3: Shared Types - Backend to Frontend (5 min)
```gleam
// Backend: Gleam type definition
pub type UserIndexProps {
  UserIndexProps(
    users: List(User),
    pagination: PaginationMeta,
  )
}
```
↓ *Compilation* ↓
```typescript
// Frontend: Generated TypeScript
export interface UserIndexProps {
  users: User[];
  pagination: PaginationMeta;
}
```
- **Breakthrough**: Single source of truth
- **Benefit**: Compile-time guarantees across the boundary
- **Live Demo**: Change backend type, see TypeScript error
- **AI Assistance Highlight**: AI can read Gleam types, generate compliant backend code

### Stage 4: Type Projection - Idiomatic TypeScript (6 min)
```gleam
// Backend: Gleam's natural types
pub type Article {
  Article(
    id: Int,
    title: String,
    published_at: Option(Time),
    tags: List(String),
  )
}
```
↓ *Intelligent Projection* ↓
```typescript
// Frontend: Idiomatic TypeScript
export interface Article {
  id: number;
  title: string;
  publishedAt: string | null;  // ISO-8601 timestamp
  tags: string[];
}
```
- **Evolution**:
  - Gleam `Option(T)` → TypeScript `T | null`
  - Gleam `List(T)` → TypeScript `T[]`
  - Gleam `snake_case` → TypeScript `camelCase`
  - Gleam `Time` → TypeScript `string` (with semantic meaning)
- **Benefit**: Each language feels natural
- **Live Demo**: Show the type projections in action

## VIII. AI-Assisted Development: The Secret Weapon (5 min)

### Why Gleam + AI Works So Well

#### 1. Language Simplicity
- No hidden magic, no complex metaprogramming
- Coding assistants see: types, functions, modules
- Easy to understand, easy to generate
- For all the reasons that Gleam is easy for humans to learn and use day-to-day, it is easy for coding assistants to read, generate, and fix.

#### 2. Excellent Error Messages
```
error: Type mismatch

  ┌─ src/app/web.gleam:45:18
  │
45│     render(response, 404)
  │                      ^^^

This argument has type:

    Int

But the function `render` expects:

    inertia.Response

Hint: Did you mean to use `inertia.response(response, 404)`?
```
- AI can parse these errors
- AI can apply the hints
- Rapid iteration: write code → error → fix → repeat

#### 3. Source-Based Packages
- All dependencies in `build/packages/`
- No complex MCP servers needed
- Just `grep` for types and functions
- AI can read documentation and implementation

#### 4. Live Demo: AI Fixing Real Errors
- Show coding assistant making a mistake
- Show error message
- Show assistant reading error and fixing
- Show assistant using grep to find relevant package code

### The Result
- Productive in hours, not weeks
- AI becomes your Gleam mentor
- TypeScript team can lean on AI to learn Gleam gradually

## IX. Real-World Considerations (2 min)

### What We've Built
- Production-ready patterns
- Testing strategies (show test example)
- Deployment considerations

### What Comes Next
- Growing Gleam ecosystem
- Team adoption strategies
- Migration paths

## X. Conclusion (1 min)

### The Value Proposition Recap
✅ Keep TypeScript expertise on frontend
✅ Gain BEAM superpowers on backend
✅ End-to-end type safety across the boundary
✅ AI assistance accelerates learning curve
✅ Inertia provides seamless bridge

### Call to Action
- Try inertia-wisp: [github link]
- Gleam resources
- Questions?

---

## Supporting Materials Needed

### Slide Design Notes
1. **Title slide**: Clean, professional, sponsor logo (check conference guidelines for size/placement)
2. **About me slide**: Photo optional, keep text minimal, focus on relevant experience
3. Consider having sponsor logo subtly in footer of all slides (check conference requirements)

### Code Examples to Prepare
1. Simple Gleam HTTP handler
2. Corresponding React component
3. Type projection examples
4. Error message examples
5. AI interaction recording/screenshots

### Diagrams to Create
1. Architecture diagram (Gleam ← Inertia → React)
2. Type safety evolution visual
3. Build/deployment flow
4. Type projection transformation

### Live Demo Requirements
1. Working demo app (keep it simple)
2. Backend code changes that trigger frontend type errors
3. AI coding assistant session (pre-recorded or live?)
4. Package grep demonstration

### Backup Slides (if time permits)
- Performance characteristics
- Testing patterns (TDD with Gleam)
- Deployment options
- Team adoption strategies
- Comparison with other frameworks

---

## Pacing Notes

- **Sponsor acknowledgment**: Keep to 5-10 seconds - brief and gracious
- **About me**: Max 1 minute - establish credibility but don't belabor it
- **Dense technical content**: Practice thoroughly
- **Live demos**: Have recordings as backup
- **AI segment**: Most novel - could expand if audience engaged
- **Type safety stages**: Core of talk - don't rush
- **Q&A buffer**: Aim to finish at 37-38 minutes for questions

## Key Takeaways (What audience should remember)

1. Gleam + TypeScript is a pragmatic choice, not a rewrite
2. Type safety across language boundaries is achievable and valuable
3. AI assistance makes learning Gleam faster than traditional approaches
4. Inertia bridges worlds without forcing either side to compromise
5. You can start small - one route, one component
