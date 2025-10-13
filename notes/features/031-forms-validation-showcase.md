# 031 - Forms and Validation Showcase

## Product Level Requirements

### Business Objectives
- Demonstrate Inertia-Wisp's form handling with `useForm` hook
- Show backend validation with error handling
- Provide a practical, reusable form pattern

### Success Metrics
- Clear demonstration of form submission and validation flow
- Full type safety from Gleam → JSON → TypeScript
- Easy to understand and replicate

## User Level Requirements

### User Motivations
- Learn how to build forms with Inertia.js and Gleam
- Understand validation error handling
- See `useForm` hook in action

### UX Affordances
- Dedicated form page (not embedded in slide)
- Link from presentation slide to form page
- Link from form page back to next slide
- Visual validation feedback (inline errors)
- Submit button loading states

## Implementation Design

### Domain Model

```gleam
// Form submission data
pub type ContactFormData {
  ContactFormData(name: String, email: String, message: String)
}

// Validation errors (standard Inertia format)
pub type FormErrors {
  Dict(String, String)  // field -> error message
}
```

### Workflows

#### Form Flow
1. Slide 18 → link to `/forms/contact`
2. User fills form and submits
3. Backend validates
4. If errors: return to form with errors
5. If valid: redirect to `/slides/19` with success message
6. Continue presentation

### Pages/Components

#### Slide 18 - Forms Introduction
- Heading: "Forms & Validation"
- Bullet points about what we'll see
- Link button: "Try the Demo →" → `/forms/contact`

#### ContactForm Page (`frontend/src/Pages/ContactForm.tsx`)
- Uses `useForm` hook from `@inertiajs/react`
- Fields: name, email, message
- Inline validation errors
- Submit button with loading state
- Success message on rerender after validation pass
- Link at bottom: "Continue to Next Slide →" → `/slides/19`

### Backend Modules

#### `backend/src/handlers/forms.gleam`
- `show_contact_form/1` - Render form page (GET)
- `submit_contact_form/1` - Handle submission with validation (POST)
- `validate_contact_form/1` - Validation rules

#### `backend/src/slides/slide_18.gleam`
- Simple slide with intro and link to form

## Testing Plan

### TDD Unit Tests
- Validation: empty fields, too short, invalid email
- Successful validation passes
- Error format matches Inertia expectations

## Implementation Tasks

### Phase 1: Backend Form Handler (TDD)
- [ ] Create `handlers/forms.gleam` with function stubs
- [ ] Write validation tests (RED)
- [ ] Implement validation (GREEN)
- [ ] Write handler tests (RED)
- [ ] Implement handlers (GREEN)
- [ ] Add routes to router

### Phase 2: Frontend Form Page
- [ ] Create `Pages/ContactForm.tsx`
- [ ] Implement form with `useForm` hook
- [ ] Add form fields and validation display
- [ ] Style with Tailwind
- [ ] Add navigation links

### Phase 3: Slide Integration
- [ ] Create slide 18 with form intro
- [ ] Add link to form page
- [ ] Update total_slides count
- [ ] Add slide to handler map

### Phase 4: Success Flow
- [ ] Handle successful submission (redirect + flash message)
- [ ] Display success message on form page or slide 19
- [ ] Test complete flow

### Phase 5: Type Safety
- [ ] Add TypeScript types for form props
- [ ] Add Zod schemas for validation
- [ ] Test type compatibility
