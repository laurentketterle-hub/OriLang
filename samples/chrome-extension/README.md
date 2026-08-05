# Chrome Extension Sample (OriLang)

This sample demonstrates how to build a Chrome extension with OriLang integration.

## Structure

```
chrome-extension/
  manifest.json    Extension manifest (MV3)
  options.html     Settings/options page
  options.js       Options page logic (chrome.storage API)
  popup.html       Extension popup
  popup.js         Popup logic
  icon16.png       Extension icon (16px)
  icon48.png       Extension icon (48px)
  icon128.png      Extension icon (128px)
```

## Features

- **Options Page**: Full settings UI with API endpoint, theme, and result limits
- **Storage**: Uses `chrome.storage.sync` for cross-device settings
- **Clean Architecture**: Type-safe, modular JavaScript (OriLang style)
- **Error Handling**: User-friendly status messages

## Loading in Chrome

1. Open `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select this folder (`samples/chrome-extension/`)

## OriLang Integration

This sample shows the extension structure pattern. In a full integration:
- The popup would load the OriLang WASM runtime
- Settings would be passed to the Ori VM via `chrome.storage`
- Results would be rendered in the popup/options page

See also: Web platform in `platforms/web/`
