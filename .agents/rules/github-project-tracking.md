# GitHub Projects, Branching & Issue Tracking Rule (Bruno Collection)

## Mandate
All non-trivial feature implementations, bug fixes, architectural spikes, and epic roadmaps must be tied to GitHub Project #6 ([Projects Board #6](https://github.com/users/gatoknas/projects/6)), which serves as the **Single Unified Board** for the Banana Project ecosystem (`banana-project-go-api`, `banana-project-web`, `banana-project-mobile`, `banana-project-bruno-collection`).

## Rules & Quality Gates

### Gate 1: Issue-First Approval Protocol (MANDATORY)
1. **Formulation**: Groom requirements, API endpoints, and test assertions into user stories.
2. **Issue Creation on GitHub**: Create GitHub issues in the respective repository, apply the repository label (`repo:bruno`), and link them to Project #6 with status `Ready` / `Todo`.
3. **URL Presentation & Approval Gate**: Display the complete list of clickable GitHub Issue URLs in the chat. **STOP and wait for explicit user approval before writing any code.**

### Gate 2: Branch-First Creation & Checkout (MANDATORY)
1. **Trigger**: Occurs immediately after receiving user approval and before modifying any files.
2. **Selective Repository Rule**: Only create a branch if this repository requires collection/request modifications.
3. **Pull Latest from Main**:
   ```bash
   git checkout main
   git pull origin main
   ```
4. **Branch Naming Standard**: `<issue-number>-<slugified-issue-purpose>` (e.g. `1-revenue-summary-bruno-tests`).
5. **Checkout**:
   ```bash
   git checkout -b <issue-number>-<slugified-issue-purpose>
   ```
6. **Card Status**: Move the corresponding card on Project #6 to `In Progress`.
7. **Verification**: Verify `git branch --show-current` confirms you are on the issue branch before modifying collection files.

### Gate 3: Pull Request Creation & Review (MANDATORY)
1. **Trigger**: Occurs once collection requests and assertions are complete and committed to the issue branch.
2. **Push to Remote**:
   ```bash
   git push -u origin <issue-number>-<slugified-issue-purpose>
   ```
3. **Mandatory PR Template Content**:
   - **Title**: `test(bruno): #<issue> - <purpose>`
   - **Linked Issue**: `Closes #<issue>`
   - **Scope of Changes**: Endpoints covered, assertion logic, and environment variable abstractions.
   - **List of Files Affected**: Table of `.bru` files added or updated.
   - **Evidence of Execution Passing**: Bruno test run log asserting HTTP 200 and schema integrity.
   - **Security Audit**: Confirmation that no plain-text tokens or credentials are in `.bru` files.
4. **Board Update**: Transition card on Project #6 from `In Progress` to **`In Review`**.
5. **Presentation**: Display clickable PR URLs in chat and pause for user code review and merge.
6. **Completion**: Once merged into `main`, GitHub closes the issue and the card transitions to **`Done`**.

---

## Repository Label Mandate
Every card on Project #6 must have its corresponding repository label:
- `repo:bruno` for Bruno API collection tasks
- `repo:api` for Go backend tasks
- `repo:web` for Vue.js frontend tasks
- `repo:mobile` for Android mobile tasks

---

## Secret Prevention
- Never commit real API keys, bearer auth tokens, or production passwords into `.bru` or environment files. Follow the [secret-prevention rule](file:///c:/Users/danie/Documents/SourceCode/banana-project/banana-project-bruno-collection/.agents/rules/secret-prevention.md).
