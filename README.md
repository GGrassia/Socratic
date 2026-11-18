# Socratic mode

Maieutic behavior for [Claude Code](https://code.claude.com) and [OpenCode ≥ 2.x](https://opencode.ai) following this study from [Stanford](https://scale.stanford.edu/ai/repository/beyond-automation-socratic-ai-epistemic-agency-and-implications-emergence-orchestrated-multi-agent-learning-architectures).
Instead of answering directly, the agent pushes you to reason and reach the answer yourself, with a ~~cheeky and insufferable~~ thought-provoking tone.

## BUT WHY???
If you're tired of having a sycophantic muppet regurgitating text and making references only it can understand, resulting in an eldritch wall of text you will fry your brain trying to decipher, this is the skill for you.
Money-back guarantee! (It's free.)

This is my personal answer for ai-assisted learning and is what I would try to give to junior devs if I had any to manage.
It's also a good response to shadow AI in my opinion, better to provide a tool that helps you learn rather than let the employees paste code randomly in a free chatbot.

## Grounding
The agent will check your code, the documentation and the web, then guides you to answers with questions, provocations and sources to read yourself.
But why stop there? Use it on research. Use it to decide which furniture you'd like in your basement!
Would not advise using it on what to wear, you are already stunning, you little critter you, stop second guessing yourself.

## Disclaimer
Yes this was made with AI, duh, this does not mean it was haphazardly slopped and left unread. I specifically reviewed it, edited it and later tuned with socratic mode itself to reason on the problems.
Yes, I plan to iterate on the skill, manually, some more.
Yes, I am actively using this.

## Contributing
Contributions are welcome. They will take some time as I won't delegate revisions to an agent, please disclose if you have used AI and how.

## Install

macOS / Linux:

```sh
./install.sh            # both harnesses
./install.sh claude     # Claude Code only
./install.sh opencode   # OpenCode only
```

Windows (PowerShell):

```powershell
.\install.ps1           # both harnesses
.\install.ps1 claude
.\install.ps1 opencode
# if scripts are blocked: powershell -ExecutionPolicy Bypass -File .\install.ps1
```

| Harness | Installs to |
| --- | --- |
| Claude Code | `$CLAUDE_CONFIG_DIR`, or `~/.claude` |
| OpenCode | `$XDG_CONFIG_HOME/opencode`, or `~/.config/opencode` |

Both create `~/socratic-journal/` for `/reflect` entries. Re-run the installer to update.

## Use

**Claude Code**
- Persistent: `/config` → Output style → **Socratic**. Takes effect after `/clear` or in a new session.
- Mid-conversation: `/socratic` to enter, `/socratic off` to leave.

**OpenCode**
- Press Tab to switch to the **socratic** agent.
- Web search needs `OPENCODE_ENABLE_EXA=1` unless you use OpenCode Zen models. Without it, the agent falls back to fetching documentation URLs.

**Both:** `/reflect` asks you three questions about the session and saves your answers to `~/socratic-journal/`.

## How it works

1. You describe the problem in a line or two *(Important!)*.
2. A private researcher subagent verifies the answer in code, docs and the web, and builds an answer key with exact sources.
3. Meanwhile, the main agent asks you to describe what you think is happening and why. This offers you the fantastic rubber-ducking approach to the problem, I'd bet this is 80% of the value of this.
4. Once the key is in, it steers with one question at a time, using a hint ladder: question → focus → a source to read → mechanism → parallel example → answer with sources. Say "hint" to climb a rung; ask for the answer twice and you get it (don't do it man, just don't do it).

It *should* never feign ignorance, say something false to test you, and *shouldn't* do the work for you. In OpenCode, file edits are blocked by the agent's permissions, except for the journal. In Claude Code this is an instruction only, since output styles can't restrict tools. In OpenCode, shell commands always ask; only git status, git diff and ls run automatically.

## Layout

```
claude-code/   copied into the Claude Code config dir
  output-styles/socratic.md      the mode itself
  agents/socratic-researcher.md  private researcher subagent
  skills/socratic/SKILL.md       /socratic on|off
  skills/reflect/SKILL.md        /reflect
opencode/      copied into the OpenCode config dir
  agents/socratic.md             primary agent (the mode)
  agents/socratic-researcher.md  private researcher subagent
  commands/reflect.md            /reflect
```

The tutor prompt is identical in `claude-code/output-styles/socratic.md` and `opencode/agents/socratic.md`, apart from the frontmatter and the final "Tools in this harness" paragraph. Keep them in sync when editing.

## Notes

- OpenCode also loads skills from `~/.claude/skills`, so with both harnesses installed it will see the Claude Code `/socratic` and `/reflect` skills too. The `/socratic` skill falls back gracefully there, but you may prefer to deny those skills in OpenCode's config.
- On Windows, the installer writes the resolved config path into the `/socratic` skill, because skill shell injection may run in either Git Bash or PowerShell (`CLAUDE_CODE_USE_POWERSHELL_TOOL=1`).

## Background

Based on Degen & Asanov (2025), [*Beyond Automation: Socratic AI, Epistemic Agency, and the Implications of the Emergence of Orchestrated Multi-Agent Learning Architectures*](https://arxiv.org/abs/2508.05116). In that study, students using a Socratic AI tutor reported significantly more support for critical, independent and reflective thinking than students using an uninstructed chatbot.

Keep the evidence in proportion: the study measured *perceived* support, over a short task, with 65 pre-service teachers, in biology research design. The researcher subagent, source hints, provocations and journal are design extrapolations, not tested findings.
