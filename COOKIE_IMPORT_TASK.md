# Cookie 文件导入功能 - 开发进度

> 参考原版文档：https://docs.vidbee.org/cookies/

---

## ✅ 已完成（调研阶段）

- [x] 阅读原版 VidBee 的 Cookie 文档，理解两种使用方式：
  - **方式一**：从浏览器读取（Windows 仅支持 Firefox）
  - **方式二**：导入 cookies.txt 文件（Netscape 格式，需 Chrome/Edge 扩展 "Get cookies.txt LOCALLY"）
- [x] 通读 `settings_page.dart`（1461行），掌握现有 Cookie 管理 UI 结构
- [x] 通读 `cookie_service.dart`，了解现有实现：
  - 已有 `importCookies(filePath)` 方法，但实际上是自定义的 `domain:cookie` 格式，**不支持 Netscape 格式**
  - 已有 `exportCookies()` 方法
  - 已有 `extractCookiesFromBrowser()` 方法，但目前是空实现（返回 null）
- [x] 确认 `file_picker` 包已在 `pubspec.yaml` 中引入（可直接用于选择文件）
- [x] 确认 `url_launcher` 包已引入（可直接用于打开帮助文档链接）
- [x] 查看 `extractor` 包（v1.0.0）的 `DownloadRequest`，确认需要查看其是否支持 `cookiesFile` 参数（**未完成**，因权限问题无法读取包文件）
- [x] 通读全部四种语言的本地化文件（zh/en/ja/ko），确认现有 key 列表

---

## 🔲 待完成（实现阶段）

### 1. 研究 extractor 包 API（明天第一步）
- [ ] 读取 `C:\Users\autsu\AppData\Local\Pub\Cache\hosted\pub.dev\extractor-1.0.0\lib` 下的 Dart 文件
- [ ] 确认 `DownloadRequest` 是否有 `cookiesFile` 参数，以便下载时自动携带 Cookie

### 2. 改造 `CookieService`（`lib/core/services/cookie_service.dart`）
- [ ] 新增 `importNetscapeCookieFile(filePath)` 方法
  - 解析标准 Netscape 格式（`# Netscape HTTP Cookie File` 开头，Tab 分隔）
  - 提取每行的 domain 和 cookie value
  - 将解析结果保存到 SharedPreferences
- [ ] 新增 `getCookieFilePath()` / `setCookieFilePath(path)` 方法
  - 保存用户导入的原始 cookies.txt 文件路径（供 yt-dlp 直接使用）
- [ ] 新增 `clearCookieFile()` 方法

### 3. 更新 `YtDlpService`（`lib/core/services/ytdlp_service.dart`）
- [ ] 在 `startDownload()` 中，读取已保存的 cookies.txt 路径
- [ ] 若路径存在，把它传入 `DownloadRequest`（如有 `cookiesFile` 参数）
- [ ] 在 `getVideoInfo()` 中同样处理

### 4. 更新设置页面 UI（`lib/features/settings/settings_page.dart`）
- [ ] 在 **Cookie 管理** 分区顶部，新增一个 `ListTile`："📄 从文件导入 Cookie"
  - 点击调用文件选择器，选择 `.txt` 文件
  - 调用 `importNetscapeCookieFile()` 解析并保存
  - 显示当前已导入的文件路径（或"未导入"）
  - 提供"清除"按钮
- [ ] 新增一个"如何获取 Cookie 文件？"帮助入口
  - 点击打开 `https://docs.vidbee.org/cookies/`
- [ ] （可选）保留"从浏览器读取" `_extractCookiesFromBrowser()` 的入口，但要加平台说明（Windows 仅支持 Firefox）

### 5. 新增多语言 key（四个语言文件 + `app_localizations.dart`）

需要新增的 key：

| Key | 中文 | 英文 |
|-----|------|------|
| `importCookieFile` | 从文件导入 Cookie | Import Cookie File |
| `importCookieFileHint` | 支持 Netscape 格式 (.txt) | Supports Netscape format (.txt) |
| `cookieFileImported` | Cookie 文件导入成功 | Cookie file imported successfully |
| `cookieFileImportFailed` | 导入失败，请检查文件格式 | Import failed, check file format |
| `cookieFileCleared` | Cookie 文件已清除 | Cookie file cleared |
| `noCookieFile` | 未导入 | Not imported |
| `cookieHelp` | 如何使用 Cookie？ | How to use cookies? |
| `currentCookieFile` | 当前文件 | Current file |
| `clearCookieFile` | 清除文件 | Clear file |

### 6. 更新 README.md
- [ ] 在"🔐 Platform One-Click Login"或单独新开"🍪 Cookie Import"章节，说明：
  - 什么情况需要 Cookie（需要登录的内容、年龄限制、Bot 验证）
  - 如何获取 cookies.txt 文件（推荐浏览器扩展：Chrome/Edge 用 "Get cookies.txt LOCALLY"）
  - 如何在 VidBee 中导入（设置 → Cookie 管理 → 从文件导入）
  - 安全提示（不要分享 Cookie 文件）

---

## 📝 备注

- 现有的 `bilibili.com` / `youtube.com` WebView 登录卡片**保留不动**，作为"快速登录"功能
- 新的文件导入功能是独立的、更通用的方案，两者并存
- 如果 `DownloadRequest` 不支持 `cookiesFile` 参数，则退而求其次：把文件内容解析后转成 `--cookies-from-header` 格式注入（需进一步研究 extractor 包的自定义参数接口）
