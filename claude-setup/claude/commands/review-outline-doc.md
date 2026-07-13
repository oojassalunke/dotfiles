Review comments on an Outline document and propose responses.

Document title: $ARGUMENTS

## Steps

### 1. Find the document
Use the `mcp__outline__get_document_id_from_title` tool with the document title above. If no match is found, tell the user and stop.

### 2. Read the full document
Use `mcp__outline__export_document` with the document ID to get the full markdown content. Keep this as context for evaluating comments.

### 3. Pull all comments
Use `mcp__outline__list_document_comments` with `include_anchor_text: true` to get every comment on the doc. Paginate if needed (default limit is 25 — if you get 25 back, call again with offset=25, etc.).

### 4. Classify comments
Split comments into two buckets:
- **New (unaddressed):** comments with no replies (no child comments referencing them as parent)
- **Already replied to:** comments that have at least one reply

Only process **new** comments. If there are zero new comments, say so and skip to the summary.

### 5. Review each new comment one-by-one
For each new comment, do the following:

**a) Evaluate against the document:**
- Is the concern already addressed somewhere in the doc? If so, cite the specific section/heading and quote the relevant sentence(s).
- Is the comment valid — pointing out a genuine gap, error, or improvement?
- Is it unclear or ambiguous?

**b) Propose a response using these tone/style rules:**
- Use soft language ("I think", "it seems like", "good catch")
- Keep it short — 3-5 sentences max
- Reference specific doc sections when saying something is already covered
- If a doc edit is warranted, propose a concrete snippet showing what to add/change and where (section heading + before/after text)

**c) Present to the user for approval:**
Show the user:
1. The comment text and anchor text (what part of the doc it's attached to)
2. Your assessment (addressed / valid / unclear)
3. Your proposed reply
4. Any proposed doc edit (if applicable)

Then ask the user (using AskUserQuestion) what to do:
- **Post reply as-is** — post the proposed reply via `mcp__outline__add_comment` as a reply to the original comment
- **Edit and post** — let the user modify the reply, then post it
- **Skip** — move on without replying
- **Edit doc** — if a doc edit was proposed, apply it via `mcp__outline__update_document`

Wait for user input before moving to the next comment.

### 6. Summary
After processing all comments, output a markdown table:

| # | Comment (truncated) | Author | Status | Action Taken |
|---|---------------------|--------|--------|--------------|

Where Status is one of: `addressed in doc`, `valid`, `unclear`, `already replied`
And Action Taken is one of: `replied`, `skipped`, `doc edited`, `already replied (no action)`
