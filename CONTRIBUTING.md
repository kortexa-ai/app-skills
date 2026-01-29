# Contributing to app-skills

We welcome contributions! Here's how to get involved.

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your skill changes locally by running `./install.sh`
5. Commit your changes with clear, descriptive messages
6. Push to your fork
7. Open a Pull Request

## Skill Structure

Each skill lives in its own directory with a `SKILL.md` file:

```
skill-name/
└── SKILL.md
```

The `SKILL.md` file must have YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description shown in skill list
---

# Skill Title

Your skill content here...
```

## Guidelines

- Keep skills focused on a single workflow
- Include clear phase-by-phase instructions
- Add checklists for verification steps
- Test with Claude Code before submitting

## Questions or Suggestions

Feel free to open an issue for bugs, feature requests, or questions.

---

© 2025 kortexa.ai
