# Claude Project Guidelines

## Interaction Rules
- **Don't act without request**: If I don't ask you to do something - don't do it
- **Answer questions only**: If I ask a question - just answer, don't modify the codebase
- **No automatic builds**: Only build the project when explicitly requested
- **Explicit confirmation**: Ask for confirmation before making significant changes

## Planning & Design
- When creating a plan, draw a tree-like structure showing the logic flow (algorithm)
- Use visual diagrams to illustrate complex workflows

## HTML/CSS Rules for web developement
- Add ID attributes to all HTML elements for easy navigation and debugging
- Use semantic IDs (e.g., `header-nav`, `footer-contact`, `btn-submit`)

## Rules for Mobile Development
- Wrap repository suspend methods with "withContext()"

## Git Workflow
- Commit format: `type: description`
- Types: feat, fix, refactor, style, docs, test

## Code Comments
- Write comments for web development projects only (skip for mobile development)
- Write comments in English
- Comment complex business logic
- Avoid obvious comments

## Priorities
1. Code structure
2. Performance
3. Reusability

## Response Style
- Keep answers concise and direct
- Show code examples when explaining
- Don't repeat the question back to me
- Skip phrases like "Sure!", "Certainly!", just get to the point
