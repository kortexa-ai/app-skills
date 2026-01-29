---
name: ios-app
description: Create a complete iOS app (Expo + React Native) with landing page, from zero to App Store submission.
---

# iOS App - Expo + Landing Page

Create a complete iOS app with a landing page, from zero to App Store submission.

## Quick Reference - Key URLs

- **Developer Portal**: https://developer.apple.com (App IDs, certificates)
- **App Store Connect**: https://appstoreconnect.apple.com (app listing, builds, submission)
- **OG Tester**: https://opengraph.xyz (test social sharing previews)

## Quick Reference - Key Commands

```bash
# Archive build
xcodebuild -workspace ios/App.xcworkspace -scheme App -configuration Release \
  -archivePath ios/build/App.xcarchive archive

# Upload to TestFlight (destination:upload in ExportOptions.plist does the magic!)
xcodebuild -exportArchive -archivePath ios/build/App.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist -exportPath ios/build/export

# Simulator screenshots (6.5" = 1284x2778)
xcrun simctl io SIMULATOR_UUID screenshot screenshot.png
magick screenshot.png -resize 1284x2778! screenshot.png
```

## Project Structure

Create two sibling projects:
```
~/src/
├── myapp.app/              # iOS app (React Native / Expo)
└── myapp/                  # Landing page (Vite + React + Tailwind)
```

## Phase 1: Project Info

### Infer or Ask

1. **App name**: Infer from folder or ask user
2. **Slug**: URL slug for landing page (e.g., `myapp`)
3. **Bundle ID**: Confirm format like `com.yourcompany.myapp`
4. **Dev port**: Suggest available port (8001+)

---

# PART 1: iOS APP

## Phase 2: iOS App Setup

### Tech Stack
- React Native with Expo SDK
- NativeWind (Tailwind for React Native)
- react-native-reanimated for animations
- AsyncStorage for local persistence

### Key Files
```
myapp.app/
├── src/
│   ├── App.tsx              # Main entry
│   ├── components/          # UI components
│   └── hooks/               # Custom hooks (storage, etc.)
├── assets/
│   ├── icon.png             # App icon (1024x1024)
│   └── icon-tight.png       # Cropped version for wordmarks
├── app.config.js            # Expo config
├── package.json
├── .gitignore
└── ios/                     # Native iOS project (generated)
```

### App .gitignore
```gitignore
# Dependencies
node_modules/

# Expo
.expo/
dist/

# Native builds (regenerated with expo prebuild)
ios/
android/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Build
*.log
*.tsbuildinfo
```

### Bundle ID Convention
Use reverse domain: `com.yourcompany.myapp`

## Phase 3: Icon Generation

Use the `/app-logo` skill or generate directly with Gemini.

### Prerequisites

Set up your Gemini API key (get one free at [Google AI Studio](https://aistudio.google.com/apikey)):

```bash
export GEMINI_API_KEY="your-api-key-here"
```

### Generate Icon

```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Generate an image: Minimalist app icon for [YOUR APP DESCRIPTION]. Style: minimal, bold, works at small sizes, iOS app icon style."
      }]
    }],
    "generationConfig": {
      "responseModalities": ["image", "text"]
    }
  }' | python3 -c "
import json, base64, sys
data = json.load(sys.stdin)
img_data = data['candidates'][0]['content']['parts'][0]['inlineData']['data']
with open('icon.png', 'wb') as f:
    f.write(base64.b64decode(img_data))
print('Icon saved to icon.png')
"

# Resize for iOS (1024x1024)
magick icon.png -resize 1024x1024 assets/icon.png
```

### Icon Processing
```bash
# Remove white background for transparency
magick icon.png -fuzz 10% -transparent white icon-transparent.png

# Create tight crop for wordmarks
magick icon.png -gravity center -crop 65%x85%+0+0 icon-tight.png
```

## Phase 4: Building for iOS

### Using XcodeBuildMCP
```bash
# Set session defaults
mcp__XcodeBuildMCP__session-set-defaults({
  workspacePath: "/path/to/ios/MyApp.xcworkspace",
  scheme: "MyApp",
  configuration: "Release"
})

# Build for device
mcp__XcodeBuildMCP__build_device()

# Build for simulator
mcp__XcodeBuildMCP__build_run_sim()
```

### Manual Build
```bash
cd ios
xcodebuild -workspace MyApp.xcworkspace \
  -scheme MyApp \
  -configuration Release \
  -archivePath /tmp/MyApp.xcarchive \
  archive -allowProvisioningUpdates
```

### Export and Upload to TestFlight

**Important**: The `destination: upload` setting uploads directly to App Store Connect/TestFlight. No API key or Fastlane needed!

```bash
# Create ExportOptions.plist (if not exists)
cat > ios/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
EOF

# Export and upload to TestFlight in one command
xcodebuild -exportArchive \
  -archivePath /tmp/MyApp.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath /tmp/MyApp-export
```

**Find your Team ID**: Open Xcode → Preferences → Accounts → Select your team → View Details → Team ID is shown.

After upload succeeds:
1. Build appears in App Store Connect within ~5-30 minutes
2. Go to TestFlight tab → Manage Compliance → answer encryption question
3. Build becomes available for testing

---

# PART 2: LANDING PAGE

## Phase 5: Landing Page Structure

```
myapp/
├── src/
│   ├── App.jsx               # Main + routing
│   ├── App.css               # Styles
│   ├── main.jsx
│   ├── index.css             # Base styles + Tailwind
│   ├── Privacy.jsx
│   └── Terms.jsx
├── public/
│   ├── favicon.png
│   ├── icon.png              # App icon
│   ├── screenshot.png        # App screenshot
│   └── og-image.png          # Social sharing (1200x630)
├── index.html
├── vite.config.js
├── tailwind.config.js
├── biome.json
├── package.json
└── .gitignore
```

## Phase 6: Landing Page Configuration

### package.json

```json
{
  "name": "myapp-landing",
  "version": "1.0.0",
  "type": "module",
  "private": true,
  "scripts": {
    "start": "vite",
    "dev": "vite",
    "build": "vite build --mode production",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^19.2.0",
    "react-dom": "^19.2.0"
  },
  "devDependencies": {
    "@tailwindcss/vite": "^4.1.7",
    "@vitejs/plugin-react-swc": "^4.2.2",
    "tailwindcss": "^4.1.7",
    "vite": "^7.2.4",
    "vite-plugin-mkcert": "^1.17.9"
  }
}
```

### vite.config.js

```javascript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import mkcert from "vite-plugin-mkcert";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [mkcert(), react(), tailwindcss()],
  build: {
    outDir: "./dist",
  },
  server: {
    host: "0.0.0.0",
    port: 8001,  // User-specified port
    open: true,
  },
  preview: {
    host: "0.0.0.0",
    port: 8001,
  },
});
```

### index.html

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#000000" />
    <title>MyApp - Tagline</title>
    <meta name="description" content="App description" />
    <meta property="og:title" content="MyApp - Tagline" />
    <meta property="og:description" content="App description" />
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://yoursite.com/" />
    <meta property="og:image" content="https://yoursite.com/og-image.png" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content="MyApp - Tagline" />
    <meta name="twitter:description" content="App description" />
    <meta name="twitter:image" content="https://yoursite.com/og-image.png" />
    <link rel="icon" type="image/png" href="/favicon.png" />
    <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

## Phase 7: Landing Page Source Files

### src/main.jsx

```javascript
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App.jsx";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>
);
```

### src/index.css

```css
@import "tailwindcss";

:root {
  --bg: #0a0a0a;
  --bg-card: #141414;
  --text: #fafafa;
  --text-muted: #737373;
  --text-dim: #525252;
  --accent: #E63946;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", system-ui, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}

a {
  color: inherit;
  text-decoration: none;
}
```

### src/App.jsx

```javascript
import { useState, useEffect } from "react";
import "./App.css";
import Privacy from "./Privacy.jsx";
import Terms from "./Terms.jsx";

const APP_STORE_URL = "https://apps.apple.com/app/idXXXXXXXXXX";  // Update after App Store Connect

function AppStoreButton({ className = "" }) {
  return (
    <a href={APP_STORE_URL} className={`app-store-button ${className}`}>
      <svg viewBox="0 0 24 24" fill="currentColor" className="apple-icon">
        <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
      </svg>
      <div className="app-store-text">
        <span className="app-store-small">Download on the</span>
        <span className="app-store-large">App Store</span>
      </div>
    </a>
  );
}

function Landing() {
  return (
    <div className="landing">
      <section className="hero">
        <div className="container">
          <h1 className="hero-title">App Name</h1>
          <p className="hero-tagline">Tagline here</p>
          <p className="hero-description">
            Description of what the app does.
          </p>

          <div className="hero-cta">
            <AppStoreButton />
          </div>

          <div className="hero-screenshot">
            <img src="/screenshot.png" alt="App screenshot" />
          </div>
        </div>
      </section>

      <footer className="footer">
        <div className="container">
          <p>Made by <a href="https://yoursite.com" target="_blank" rel="noopener noreferrer">Your Name</a></p>
          <p className="footer-links">
            <a href="/privacy">Privacy</a> · <a href="/terms">Terms</a>
          </p>
        </div>
      </footer>
    </div>
  );
}

export default function App() {
  const [path, setPath] = useState(window.location.pathname);

  useEffect(() => {
    const handlePopState = () => setPath(window.location.pathname);
    window.addEventListener("popstate", handlePopState);
    return () => window.removeEventListener("popstate", handlePopState);
  }, []);

  if (path === "/privacy") return <Privacy />;
  if (path === "/terms") return <Terms />;
  return <Landing />;
}
```

### src/App.css

```css
/* Landing page styles */
.landing {
  min-height: 100vh;
  position: relative;
}

.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 24px;
}

.hero {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 120px 0 80px;
}

.hero-title {
  font-size: clamp(3rem, 12vw, 6rem);
  font-weight: 800;
  letter-spacing: -0.03em;
  margin-bottom: 8px;
}

.hero-tagline {
  font-size: clamp(1.25rem, 3vw, 1.75rem);
  font-weight: 500;
  color: var(--accent);
  margin-bottom: 24px;
}

.hero-description {
  font-size: clamp(1rem, 2vw, 1.25rem);
  color: var(--text-muted);
  max-width: 500px;
  margin: 0 auto 48px;
  line-height: 1.7;
}

.hero-cta {
  margin-bottom: 64px;
}

.hero-screenshot {
  max-width: 280px;
  margin: 0 auto;
  border-radius: 32px;
  overflow: hidden;
  box-shadow: 0 25px 80px rgba(0, 0, 0, 0.3);
}

.hero-screenshot img {
  display: block;
  width: 100%;
}

/* App Store Button */
.app-store-button {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  background: var(--text);
  color: var(--bg);
  padding: 14px 28px;
  border-radius: 12px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.app-store-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(255, 255, 255, 0.1);
}

.apple-icon {
  width: 28px;
  height: 28px;
}

.app-store-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  text-align: left;
}

.app-store-small {
  font-size: 10px;
  font-weight: 500;
  line-height: 1;
}

.app-store-large {
  font-size: 20px;
  font-weight: 600;
  line-height: 1.2;
}

/* Footer */
.footer {
  padding: 48px 0;
  text-align: center;
  border-top: 1px solid var(--bg-card);
}

.footer p {
  font-size: 0.875rem;
  color: var(--text-dim);
}

.footer a {
  color: var(--text-muted);
  transition: color 0.2s;
}

.footer a:hover {
  color: var(--accent);
}

.footer-links {
  margin-top: 12px;
  font-size: 0.75rem;
}
```

### src/Privacy.jsx

```javascript
export default function Privacy() {
  return (
    <div className="legal-page">
      <div className="container">
        <h1>Privacy Policy</h1>
        <p className="updated">Last updated: [Date]</p>

        <h2>Data Collection</h2>
        <p>
          [App Name] does not collect any personal data. All your data stays on your device.
        </p>

        <h2>Analytics</h2>
        <p>
          We do not use any analytics or tracking services.
        </p>

        <h2>Contact</h2>
        <p>
          Questions? Email us at <a href="mailto:you@example.com">you@example.com</a>
        </p>

        <p className="back-link">
          <a href="/">← Back to home</a>
        </p>
      </div>
    </div>
  );
}
```

### src/Terms.jsx

```javascript
export default function Terms() {
  return (
    <div className="legal-page">
      <div className="container">
        <h1>Terms of Service</h1>
        <p className="updated">Last updated: [Date]</p>

        <h2>Use of Service</h2>
        <p>
          By using [App Name], you agree to these terms.
        </p>

        <h2>Disclaimer</h2>
        <p>
          The app is provided "as is" without warranty of any kind.
        </p>

        <h2>Contact</h2>
        <p>
          Questions? Email us at <a href="mailto:you@example.com">you@example.com</a>
        </p>

        <p className="back-link">
          <a href="/">← Back to home</a>
        </p>
      </div>
    </div>
  );
}
```

---

# PART 3: APP STORE SUBMISSION

## Phase 8: App Store Screenshots

Required sizes:
- 6.7" display: 1290 x 2796 (iPhone 15 Pro Max)
- 6.5" display: 1284 x 2778 (can scale from 6.7")
- 5.5" display: 1242 x 2208 (can scale from 6.7")

```bash
# Capture from simulator
xcrun simctl io SIMULATOR_UUID screenshot screenshot.png

# Scale for different sizes
sips -z 2778 1284 screenshot.png --out 6.5/screenshot.png
sips -z 2208 1242 screenshot.png --out 5.5/screenshot.png
```

### Screenshot Ideas
1. **Empty state** - Clean, inviting first impression
2. **Add item modal** - Show the input experience
3. **Main list with variety** - Hero shot showing core value prop
4. **Detail/interaction** - Swipe, edit, or special feature

## Phase 9: Apple Developer Portal

### Register App ID (developer.apple.com)
- [ ] Go to Identifiers → App IDs → Register
- [ ] Bundle ID: `com.yourcompany.myapp`
- [ ] Description: App name
- [ ] Capabilities: Only enable what you need

## Phase 10: App Store Connect Setup

### Create New App (appstoreconnect.apple.com)
- [ ] My Apps → + → New App
- [ ] Platform: iOS
- [ ] Name: App name
- [ ] Primary Language: English (U.S.)
- [ ] Bundle ID: Select from dropdown
- [ ] SKU: `myapp-ios-001`

### App Information Tab
- [ ] Subtitle (30 char max)
- [ ] Category: Primary category
- [ ] Content Rights: Confirm

### Pricing & Availability Tab
- [ ] Price: Free (or set price tier)
- [ ] Availability: All countries/regions

### App Privacy Tab
- [ ] Privacy Policy URL: `https://yoursite.com/privacy`
- [ ] Data Collection questionnaire

### Version Information
- [ ] Screenshots: Upload 6.5" screenshots
- [ ] Promotional Text (170 char)
- [ ] Description: Full app description
- [ ] Keywords (100 char max)
- [ ] Support URL: `https://yoursite.com/`
- [ ] Version: `1.0`
- [ ] Copyright: `© 2025 Your Name`

### Build
- [ ] Archive and upload
- [ ] Wait for processing
- [ ] **TestFlight → Manage Compliance**: Answer encryption question
- [ ] Select build

### Submit
- [ ] Review all sections
- [ ] **Submit for Review**

### App Store URL
Get APP_ID from App Store Connect URL:
```
https://apps.apple.com/app/id{APP_ID}
```
Update landing page with this URL immediately (works even before app is live).

---

# PART 4: DEPLOYMENT & TESTING

## Phase 11: Development

### Landing Page
```bash
cd ~/src/myapp
npm install
npm run dev  # https://localhost:8001/
```

### Verify
- [ ] Landing loads at `https://localhost:PORT/`
- [ ] Privacy page at `/privacy`
- [ ] Terms page at `/terms`
- [ ] Screenshot displays correctly
- [ ] App Store button works

## Phase 12: Production Deployment

### Landing Page

```bash
# Build
npm run build

# Deploy to your hosting (Vercel, Netlify, etc.)
# Or deploy to your own server:
git add -A && git commit -m "Initial landing page"
git push
```

### OG Image
```bash
# Capture from live site
# Use browser screenshot or puppeteer

# Crop to OG dimensions (1200x630)
magick hero-screenshot.png -gravity North -crop 1280x670+0+0 -resize 1200x630! public/og-image.png
```

## Phase 13: Final Checklist

### iOS App
- [ ] Remove `expo-dev-client` before production build (`npm uninstall expo-dev-client` then `npx expo prebuild --clean -p ios`)
- [ ] Build uploaded and processed
- [ ] All metadata complete
- [ ] Screenshots uploaded
- [ ] Age rating set
- [ ] Submitted for review

### Landing Page
- [ ] Live at your domain
- [ ] App Store button has correct URL
- [ ] Privacy/Terms pages accessible
- [ ] OG image working (test at opengraph.xyz)

### Post-Launch
- [ ] Test App Store link
- [ ] Social preview images working

## Copy Guidelines

Write with:
- Direct, punchy sentences
- Benefit-focused, not feature-focused
- Privacy as a feature ("All data stays on your device")

Note: Apple may reject certain emoji in descriptions. Use sparingly.

## See Also

- `/app-logo` - Generate app icons with AI
- `/osx-app` - Create macOS desktop apps
