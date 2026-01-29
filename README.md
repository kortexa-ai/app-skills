# App Skills for Claude Code

Skills for building iOS and macOS apps with Claude Code. From zero to App Store in a conversation.

## Skills Included

| Skill | Description |
|-------|-------------|
| `/ios-app` | Create a complete iOS app (Expo + React Native) with landing page |
| `/osx-app` | Create a macOS desktop app (Capacitor + Electron + React) |
| `/app-logo` | Generate app icons using Google's Gemini image generation |

## Installation

```bash
git clone https://github.com/kortexa-ai/app-skills.git
cd app-skills
./install.sh
```

This symlinks the skills to `~/.claude/skills/` where Claude Code discovers them.

## Prerequisites

- [Claude Code](https://claude.ai/download) CLI installed
- Node.js 18+ and npm
- Xcode (for iOS/macOS development)
- [XcodeBuildMCP](https://github.com/nickkaczmarek/XcodeBuildMCP) server configured (optional but recommended)

### For Icon Generation

Set up your Gemini API key:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Get a free API key at [Google AI Studio](https://aistudio.google.com/apikey).

## Usage

In Claude Code, invoke a skill:

```
/ios-app
/osx-app
/app-logo
```

Claude will guide you through the process interactively.

## What You Get

### /ios-app
- Expo + React Native project with NativeWind (Tailwind)
- Landing page (Vite + React + Tailwind)
- App Store submission checklist
- TestFlight upload workflow
- Privacy/Terms pages template

### /osx-app
- Capacitor + Electron + React desktop app
- Zero to running app in 3 commands
- System tray, dock icon, and menu customization guides
- Distribution build setup

### /app-logo
- AI-generated app icons using Gemini
- Prompt engineering tips for great icons
- Size conversion recipes for all platforms

## License

MIT - see [LICENSE](LICENSE)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
