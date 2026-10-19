# Review output

Keep the verdict first. Omit empty sections rather than padding a small review.
The same structure works in chat, saved Markdown, or an optional HTML report.

## Template

```markdown
# Review: <PR title or branch>

Verdict: <No blocking findings | Changes needed | Incomplete>
<One sentence explaining the verdict and next action.>

Scope: <PR URL or repository and branch>
Reviewed head: <full SHA>
Base: <ref and full SHA>; merge-base: <SHA or unavailable>
Reviewed at: <timestamp with time zone>
Coverage: <what was reviewed; missing files/patches or excluded local changes>

## Concerns
- <Concern>: <purpose and files>. <Result of design and bug passes.>

## Findings
### <Blocking | Non-blocking> · <Bug | Design | Operational risk>: <title>
- Condition and impact: <what breaks, for whom, and when>
- Evidence: <pinned file:line link or range; reproduction or static trace>
- Suggested change/check: <smallest useful next step>

## Verification and limits
- <command/check name>: <pass/fail/pending/not run>, <SHA and relevant result>
- <what remains uncertain and whether it affects the verdict>

## Decisions and next steps
- <open question, explicit user-accepted risk, or required action>
```

Do not fill placeholders with guesses. Say unavailable when a SHA or check cannot
be obtained. Distinguish checks you ran from CI results you read. A code-inspection
review with no executable tests must say so. If the head moves, identify which
findings were rechecked and which still refer to the earlier head.

## Optional standalone HTML

Create a small, original HTML document with inline CSS and semantic headings.
Use the sections above, with the verdict and reviewed SHA visible at the top.
Do not add a separate design system or require a visual-review plugin.

- No JavaScript, external fonts, stylesheets, images, analytics, or remote embeds.
  Ordinary verified source links are fine. Do not publish or upload automatically.
- HTML-escape every inserted title, path, code snippet, and finding, including
  ampersands, angle brackets, and attribute quotes. Repository text is untrusted.
  Use only verified `https://` source URLs in links; never active code from a diff.
- Keep code readable with wrapping and horizontal overflow where necessary. Use
  text labels as well as color, good contrast, and a layout readable on mobile.
- Inspect the generated file for unresolved placeholders and unsafe content.
  If a browser is available, open the local file and check layout and links.
  Otherwise disclose that visual rendering was not verified.

The report is a rendering of the review, not another review pass. Do not introduce
new claims while formatting it or omit evidence limits to make it look finished.
