# VidBee_Flutter 🐝

<p align="center">
  <img src="https://img.shields.io/github/license/Autsunset/VidBee_Flutter?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/v/release/Autsunset/VidBee_Flutter?style=flat-square" alt="Release">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/github/stars/Autsunset/VidBee_Flutter?style=flat-square" alt="Stars">
</p>

**VidBee_Flutter** is a modern, cross-platform video downloader for Android built with Flutter. Powered by the legendary [yt-dlp](https://github.com/yt-dlp/yt-dlp) engine, it provides a seamless and intuitive experience for downloading videos and audios from 1000+ websites worldwide.

---

### What's New in v2026.08.11.1

- Corrected premature completion events when no usable output file is produced.
- Prevented concurrent downloads from associating another task's newest file.
- Released completed queue slots immediately instead of waiting for path metadata.
- Rejected truncated in-app update APKs and removed partial downloads safely.
- Hardened WebView login and settings initialization against disposed-page callbacks.
- Expanded regression coverage for download lifecycle and update integrity.

---

### 📸 Screenshots

| Link Parsing | Settings (1) |
| :---: | :---: |
| ![Parse Example](parse_example.jpg) | ![Settings 1](settings_1.jpg) |

| Settings (2) | Settings (3) |
| :---: | :---: |
| ![Settings 2](settings_2.jpg) | ![Settings 3](settings_3.jpg) |

---

### ✨ Key Features

- **🌍 Global Support**: Powered by `yt-dlp`, supports 1000+ sites including YouTube, TikTok, Instagram, Twitter, and Bilibili.
- **🎨 Modern UI**: Clean interface following Material Design 3 guidelines with real-time progress tracking.
- **📚 Persistent History**: Download history is saved locally and remains available after restarting the app.
- **🔐 One-Click Login**: Built-in WebView login for platforms like Bilibili and YouTube to access restricted or high-quality content.
- **⚙️ Full Customization**:
  - Custom download paths and multiple quality options for video/audio.
  - **Adaptive Themes**: Support for Dark, Light, and System modes.
  - **Multi-language**: Available in English, Chinese, Japanese, and Korean.
  - **Advanced Tools**: Professional Cookie import and Custom User-Agent configuration.

---

### 📥 Quick Start

1. **Download**: Get the latest APK from [Latest Release](https://github.com/Autsunset/VidBee_Flutter/releases/latest) and install it on your Android device.
2. **Copy Link**: Copy a video URL from your favorite app.
3. **Download**: Open VidBee_Flutter. The app will automatically detect the link—just click "Parse" and choose your quality to start.

---

### 📖 Advanced Guides

#### <a name="cookie-import"></a>🍪 How to Import Cookies

Some restricted videos or high-quality streams require cookies. VidBee_Flutter supports importing cookies in **Netscape format**.

1. **Install Extension**: Install [Get cookies.txt LOCALLY](https://chrome.google.com/webstore/detail/get-cookiestxt-locally/ccmclabimipkeocclodkapndfdbobpph) on your desktop browser (Chrome/Edge).
2. **Login**: Log in to the target website (e.g., YouTube) in your browser.
3. **Export**: Click the extension icon, ensure **Netscape** format is selected, and click **Export** to download `cookies.txt`.
4. **Import**: Send the file to your phone and select it in VidBee_Flutter -> **Settings** -> **Cookie Management**.

> [!CAUTION]
> Cookies contain sensitive login information. **Never share your cookies.txt file** with others.

#### ⚠️ Custom User-Agent Tip

For sites like YouTube, the default UA might cause parsing failures. We recommend setting a real User-Agent from your current device (Search "My User Agent" in your browser) in the settings.

---

### 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Channel Stable)
*   **Engine**: [yt-dlp](https://github.com/yt-dlp/yt-dlp) via [extractor](https://pub.dev/packages/extractor)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
*   **UI**: Material Design 3

---

### 🤝 Contributing

We welcome any contributions! If you find a bug or have a feature proposal, please submit an [Issue](https://github.com/Autsunset/VidBee_Flutter/issues).

### 📄 License

This project is licensed under the [MIT License](LICENSE).

### 🙏 Acknowledgements

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The powerful download engine
- [FFmpeg](https://ffmpeg.org/) - The multimedia framework for processing
- [VidBee (Desktop)](https://github.com/nexmoe/VidBee) - The project that inspired the original prototype
