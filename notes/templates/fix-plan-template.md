# [Number] - [Fix/Defect Name]

## Issue

### Problem Description
- [What exactly is broken or not working as expected?]
- [When does this issue occur?]
- [What should happen vs what actually happens?]

### Impact Assessment
- **Severity**: [Critical/High/Medium/Low]
- **Affected Users**: [Who is impacted and how many?]
- **Business Impact**: [Revenue, reputation, operational impact]
- **Workarounds**: [Any temporary solutions available?]

### Reproduction Steps
1. [Step 1 to reproduce]
2. [Step 2 to reproduce]
3. [Expected vs actual result]

### Environment Details
- **System**: [Production/Staging/Development]
- **Browser/Platform**: [If applicable]
- **Data Conditions**: [Specific data states that trigger issue]

## Root Cause Analysis

### Investigation Findings
- [What code/logic is causing the issue?]
- [When was this introduced? Related changes?]
- [Why did existing tests not catch this?]

### System Behavior
- [How does the current system behave incorrectly?]
- [What assumptions were wrong in the original implementation?]
- [Are there related issues or symptoms?]

## Fix Design

### Proposed Solution
- [What changes are needed to fix the root cause?]
- [Why is this the right approach vs alternatives?]
- [What are the risks of this fix?]

### Implementation Approach
- [Which files/modules need to be changed?]
- [What new tests are needed?]
- [Are any database migrations required?]

### Validation Plan
- [How will we verify the fix works?]
- [What regression testing is needed?]
- [How will we monitor for related issues?]

## Testing Plan

### Fix Verification Tests
- [Tests that specifically verify the bug is fixed]
- [Edge cases related to the fix]
- [Error conditions that should be handled]

### Regression Tests
- [Existing functionality that might be affected]
- [Related features to test]
- [Performance impact testing]

### Integration Tests (Local Dev)
- [End-to-end scenarios to verify]
- [Cross-system integration points]

### Production Verification
- [Monitoring and alerts to set up]
- [Success criteria for deployment]
- [Rollback plan if issues occur]

## Implementation Tasks

### Phase 1: Investigation & Planning
- [ ] Reproduce issue consistently
- [ ] Identify root cause
- [ ] Design fix approach
- [ ] Review fix design

### Phase 2: Implementation
- [ ] Implement fix
- [ ] Add regression tests
- [ ] Update related documentation
- [ ] Code review

### Phase 3: Validation & Deployment
- [ ] Test fix in staging
- [ ] Verify no regressions
- [ ] Deploy to production
- [ ] Monitor for issues

