---
name: reflect
description: Reflect on the current Socratic conversation and save a journal entry, written in your own words, to ~/socratic-journal/.
disable-model-invocation: true
---

Help me reflect on this conversation, then save an entry to my journal.

First, ask me these one at a time, waiting for each answer:
1. What do you understand now that you didn't at the start, in your own words?
2. What was the turning point, the moment your understanding changed?
3. Which source would you go back to, and what would you look for next?

Don't answer them for me. If an answer is incomplete or inaccurate, ask one follow-up question about it.

Then append an entry to `~/socratic-journal/journals/<YYYY_MM_DD>.md`, creating the folder and the file if needed. Use today's date and that exact path and filename: Logseq reads `journals/` as journal pages, and that is what puts the entry on the right day.

The entry is one block. Write it as:

- **Question**: what we explored, in one line.
  hints:: the highest rung reached (question, focus, source, mechanism, parallel case or answer)
  sources:: the sources from the conversation, with links, on one line
  - **What I understood**: my answer, in my words, lightly cleaned up for grammar only.
  - **Turning point**: my answer, plus the question, source or experiment that triggered it.
  - **Next**: my answer to the third question.

The two indented `key:: value` lines are Logseq properties on the block, so keep each on a single line. If the file already exists, leave what is already there untouched and add the block at the end, separated by a blank line. Several sessions on the same day are several blocks in the same page.

Write it in the language we've been using. Keep it short. It's my record, so my words should dominate.
