# VidBee_Flutter 🐝

VidBee_Flutter is a modern, open-source video downloader for Android that lets you download videos and audios from 1000+ websites worldwide. Built with Flutter and powered by yt-dlp, VidBee_Flutter offers a clean, intuitive interface with powerful features for all your downloading needs.

---

### 👋🏻 Getting Started

VidBee_Flutter is currently under active development, and feedback is welcome for any [Issue](https://github.com/Autsunset/VidBee_Flutter/issues) encountered.

[📥 Download VidBee_Flutter](https://github.com/Autsunset/VidBee_Flutter/releases/latest)

#### 📸 Screenshots

| Parse Example | Settings (1) |
|------|----------|
| ![Parse Example](parse_example.jpg) | ![Settings 1](settings_1.jpg) |

| Settings (2) | Settings (3) |
|----------|--------------|
| ![Settings 2](settings_2.jpg) | ![Settings 3](settings_3.jpg) |

> [!IMPORTANT]
>
> **Star Us**, You will receive all release notifications from GitHub without any delay ~

---

### ✨ Features

#### 🌍 Global Video Download Support
Download videos from almost any website worldwide through the powerful yt-dlp engine. Support for 1000+ sites including YouTube, TikTok, Instagram, Twitter, and many more.

#### 🎨 Best-in-class UI Experience
Modern, clean interface with intuitive operations. Real-time progress tracking and comprehensive download queue management.

#### 🔐 Platform One-Click Login
Seamlessly log in to platforms like Bilibili and YouTube using WebView for accessing restricted content or high-quality streams.

#### ⚙️ Customizable Settings
- Download path selection
- Video and audio quality settings
- Theme switching (Light/Dark/System)
- Multi-language support (Chinese, English, Japanese, Korean, etc.)
- Cookie management and Custom User-Agent

---

### 💡 Tips & Troubleshooting

#### ⚠️ Custom User-Agent (Highly Recommended)
Some websites, such as **YouTube**, may fail to download or login correctly if you use the default system User-Agent. It is highly recommended to set a **real User-Agent** from your actual browser:

**How to obtain your real User-Agent:**
1. Open your browser (on PC or Android).
2. Search for **"my user agent"** on Google or Bing.
3. Copy the string (e.g., `Mozilla/5.0 (Windows NT 10.0; Win64; x64)...`) and paste it into the **Custom User-Agent** field in VidBee's settings.
4. Alternatively, on a PC, press **F12** to open Developer Tools, go to the **Network** tab, refresh the page, click any request, and find the `User-Agent` under **Request Headers**.


### 🌐 Supported Sites
VidBee_Flutter supports 1000+ video and audio platforms through yt-dlp.

### 🛠️ Tech Stack
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Drift** - Local database (SQLite)
- **extractor** - yt-dlp + FFmpeg integration
- **Material Design 3** - Modern UI design

### 🤝 Contributing
You are welcome to join the open source community to build together.

### 📄 License
This project is distributed under the MIT License.

### 🙏 Thanks
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The powerful video downloader engine
- [FFmpeg](https://ffmpeg.org/) - The multimedia framework for video and audio processing
- [Flutter](https://flutter.dev/) - Build beautiful native apps for mobile
- [VidBee](https://github.com/nexmoe/VidBee) - The original desktop version that inspired this project
