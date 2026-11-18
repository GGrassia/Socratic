# Contributing

Contributions are welcome. See the Contributing section of the README for how revisions are handled.

## Licensing of contributions

This project is released under the Apache License 2.0 (see `LICENSE` and `NOTICE`). By submitting a contribution — a pull request, patch, or any change sent for inclusion — you agree that:

- you have the right to submit it, and it is your own work or you have permission to include it;
- you license it to the project under the same terms as the project, Apache 2.0;
- you are happy for it to be distributed, modified and used commercially by anyone, including in a paid product.

That last point follows from the license rather than adding to it: Apache 2.0 already permits commercial use, so there is no separate CLA to sign and no additional grant to make. If you are not comfortable with your words being resold, open an issue describing the change instead of sending a patch.

## Editing the prompts

Each prompt exists twice, once per harness:

| Prompt | Claude Code | OpenCode |
| --- | --- | --- |
| Tutor | `claude-code/output-styles/socratic.md` | `opencode/agents/socratic.md` |
| Researcher | `claude-code/agents/socratic-researcher.md` | `opencode/agents/socratic-researcher.md` |
| Reflect | `claude-code/skills/reflect/SKILL.md` | `opencode/commands/reflect.md` |

The bodies must stay word-for-word identical. Only the frontmatter, and the `## Tools in this harness` section at the end of the tutor prompt, may differ. Both installers check this and refuse to install if a pair has drifted, so a one-sided edit fails loudly rather than shipping two different tutors.
