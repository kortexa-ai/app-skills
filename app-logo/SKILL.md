---
name: app-logo
description: Generate app icons using Google's Gemini image generation model.
---

# App Logo - AI Image Generation

Generate professional app icons and logos using Google's Gemini image generation.

## Prerequisites

### Get a Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Create or sign in to your Google account
3. Generate an API key
4. Set it in your environment:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Add to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist:

```bash
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.zshrc
```

## Quick Reference

```bash
# Generate an icon
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Generate an image: Minimalist app icon, 3D cube, dark navy with purple cyan gradient, macOS style"
      }]
    }],
    "generationConfig": {
      "responseModalities": ["image", "text"]
    }
  }'
```

## API Configuration

### Endpoint

**URL**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent`

**Method**: `POST`

**Authentication**: API key as query parameter (`?key=$GEMINI_API_KEY`)

## Request Format

```json
{
  "contents": [{
    "parts": [{
      "text": "Generate an image: <your prompt here>"
    }]
  }],
  "generationConfig": {
    "responseModalities": ["image", "text"]
  }
}
```

### Prompt Tips for App Icons

- Start with "Generate an image:" prefix
- Include "app icon" in the prompt
- Specify style: "minimalist", "3D", "flat design"
- Mention colors: "dark navy background", "purple cyan gradient"
- Add "macOS app icon style" for platform-appropriate look
- Include "rounded corners" for modern app icons

## Response Format

```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "inlineData": {
          "mimeType": "image/png",
          "data": "base64-encoded-image-data..."
        }
      }]
    }
  }]
}
```

## Parsing and Saving

### Bash + Python (Recommended)

```bash
# Generate and save in one command
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Generate an image: Minimalist app icon for task manager, 3D checkbox with checkmark, dark background with gradient glow, professional macOS app icon style"
      }]
    }],
    "generationConfig": {
      "responseModalities": ["image", "text"]
    }
  }' | python3 -c "
import json, base64, sys
data = json.load(sys.stdin)
img_data = data['candidates'][0]['content']['parts'][0]['inlineData']['data']
with open('appIcon.png', 'wb') as f:
    f.write(base64.b64decode(img_data))
print('Icon saved to appIcon.png')
"
```

### Python Script

```python
import json
import base64
import os
import urllib.request

api_key = os.environ.get('GEMINI_API_KEY')
prompt = "Generate an image: Minimalist app icon, 3D geometric cube, dark navy background with purple cyan gradient"

url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={api_key}"

request_data = {
    "contents": [{"parts": [{"text": prompt}]}],
    "generationConfig": {"responseModalities": ["image", "text"]}
}

req = urllib.request.Request(
    url,
    data=json.dumps(request_data).encode(),
    headers={"Content-Type": "application/json"}
)

with urllib.request.urlopen(req) as response:
    data = json.load(response)

img_data = data['candidates'][0]['content']['parts'][0]['inlineData']['data']

with open('appIcon.png', 'wb') as f:
    f.write(base64.b64decode(img_data))

print("Icon saved to appIcon.png")
```

## Complete Workflow

### 1. Generate Icon

```bash
PROMPT="Minimalist app icon for AI assistant, 3D brain or neural network, dark navy background with purple indigo cyan gradient glow, professional macOS app icon style, rounded corners, sleek modern design"

curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{\"parts\": [{\"text\": \"Generate an image: $PROMPT\"}]}],
    \"generationConfig\": {\"responseModalities\": [\"image\", \"text\"]}
  }" > response.json
```

### 2. Extract and Save

```bash
python3 << 'EOF'
import json
import base64

with open('response.json') as f:
    data = json.load(f)

img_data = base64.b64decode(
    data['candidates'][0]['content']['parts'][0]['inlineData']['data']
)

with open('appIcon.png', 'wb') as out:
    out.write(img_data)

print(f"Icon saved: {len(img_data)} bytes")
EOF
```

### 3. Resize for Different Uses

```bash
# For iOS app icon (1024x1024)
magick appIcon.png -resize 1024x1024 assets/icon.png

# For macOS dock (512x512)
magick appIcon.png -resize 512x512 electron/assets/appIcon.png

# For header logo (64x64)
magick appIcon.png -resize 64x64 src/assets/logo.png

# For favicon (32x32)
magick appIcon.png -resize 32x32 public/favicon.png

# For web favicon.ico
magick appIcon.png -resize 32x32 public/favicon.ico
```

## Best Practices

### Icon Sizes

| Use Case | Size | Format |
|----------|------|--------|
| iOS App Store | 1024x1024 | PNG |
| macOS Dock | 512x512 | PNG |
| macOS App | 1024x1024 | PNG/ICNS |
| Header logo | 64x64 | PNG |
| Favicon | 32x32 | ICO/PNG |

### Prompt Engineering

**Good prompts:**
- "Minimalist app icon, 3D geometric shape, dark background with gradient glow"
- "Professional macOS app icon, rounded square, modern design"
- "Sleek logo, glass morphism effect, purple cyan gradient"

**Avoid:**
- Text in icons (hard to read at small sizes)
- Too many details
- Cluttered compositions

## Icon Processing

### Remove White Background

```bash
magick appIcon.png -fuzz 10% -transparent white appIcon-transparent.png
```

### Create Tight Crop for Wordmarks

```bash
magick appIcon.png -gravity center -crop 65%x85%+0+0 appIcon-tight.png
```

### Invert for Dark Mode (CSS)

```css
.logo-dark {
  filter: invert(1) hue-rotate(180deg);
}
```

## Troubleshooting

### API Errors

- **400 Bad Request**: Check JSON format and prompt structure
- **403 Forbidden**: Verify API key is correct and has access
- **429 Rate Limited**: Wait and retry, or upgrade quota
- **500 Server Error**: Retry after a moment

### Empty or Invalid Response

```bash
# Debug: print raw response
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Generate an image: simple red circle"}]}],"generationConfig":{"responseModalities":["image","text"]}}' \
  | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin), indent=2))"
```

### Large Response

Responses contain base64 image data (~500KB-1MB). Always pipe to Python for parsing:

```bash
# Check response has image data
cat response.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
if 'candidates' in d:
    part = d['candidates'][0]['content']['parts'][0]
    if 'inlineData' in part:
        print(f'Image size: {len(part[\"inlineData\"][\"data\"])} bytes (base64)')
    else:
        print('No image in response')
        print(part.get('text', 'No text either'))
else:
    print('Error:', d)
"
```

## See Also

- `/ios-app` - Create iOS apps with generated icons
- `/osx-app` - Create macOS apps with dock icons
