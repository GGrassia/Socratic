---
name: socratic
description: Turn Socratic (maieutic) mode on or off in the middle of any conversation, without restarting. "/socratic" or "/socratic on" enters it, "/socratic off" leaves it.
argument-hint: "[on|off]"
disable-model-invocation: true
allowed-tools: Read, Bash(echo *)
---

The argument is: $ARGUMENTS

Claude config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`

If the argument is "off": tell the person in one line that Socratic mode is off, and from your next turn answer normally. If the Socratic output style is selected in `/config`, mention that it stays active until they switch the style back and run `/clear`.

Otherwise (empty or "on"):
1. Read `output-styles/socratic.md` inside the Claude config directory shown above, and ignore its frontmatter. If that line doesn't show an absolute path (it's blank, or shows the raw command), run `echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` with Bash to get it, and if that fails too, try `~/.claude`.
2. Follow those instructions on every turn from now until the person runs `/socratic off`. They take priority over your usual habit of giving answers and making changes directly.
3. Tell the person in one line that Socratic mode is on and how to leave it. If the conversation already contains a question, start from it rather than asking them to repeat it.
