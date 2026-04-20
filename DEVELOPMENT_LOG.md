# VidBee_Flutter 功能开发记录

## 开发概述

本项目是一个基于 Flutter 的视频下载应用，支持从全球多个视频网站下载视频。

## 本次开发内容

### 一、自定义 User-Agent 功能

#### 需求
- 添加自定义 UA 功能，让所有地方都能用上
- 用户可以设置一个自定义 UA，应用到所有网络请求中

#### 实现方案
1. 在设置页面添加自定义 UA 输入框
2. 使用 SharedPreferences 保存用户设置的 UA
3. 集成到 yt-dlp 服务，所有网络请求都使用自定义 UA
4. 支持保存和恢复默认 UA

#### 代码修改
- `lib/core/services/ytdlp_service.dart`: 添加自定义 UA 参数支持
- `lib/features/settings/settings_page.dart`: 添加自定义 UA 设置界面
- `lib/features/download/add_url_dialog.dart`: 加载并传递自定义 UA

### 二、多语言支持

#### 需求
- 添加多语言支持，包括中文、英文、日语、韩语
- 用户可以在设置中切换语言

#### 实现方案
1. 创建多语言资源文件
2. 使用 Flutter 的 Localizations API
3. 在设置页面添加语言切换功能

#### 代码修改
- `lib/shared/i18n/app_localizations.dart`: 主本地化类
- `lib/shared/i18n/app_localizations_zh.dart`: 中文翻译
- `lib/shared/i18n/app_localizations_en.dart`: 英文翻译
- `lib/shared/i18n/app_localizations_ja.dart`: 日语翻译
- `lib/shared/i18n/app_localizations_ko.dart`: 韩语翻译
- `lib/main.dart`: 集成语言切换

### 三、浏览器 Cookie 提取功能

#### 需求
- 实现类似电脑版 VidBee 的浏览器 Cookie 提取功能
- 支持检测已安装的浏览器

#### 实现方案
1. 添加浏览器检测功能
2. 添加 Cookie 提取功能（需要相应权限）
3. 添加导出/导入 Cookie 功能

#### 代码修改
- `lib/core/services/cookie_service.dart`: 添加浏览器检测和 Cookie 提取功能

### 四、增强 Cookie 管理界面

#### 需求
- 增强 Cookie 管理界面，支持查看、删除、导出/导入 Cookie

#### 实现方案
1. 添加 Cookie 管理对话框
2. 支持查看所有保存的 Cookie
3. 支持删除单个 Cookie
4. 支持导出/导入 Cookie

#### 代码修改
- `lib/features/settings/settings_page.dart`: 添加 Cookie 管理功能

### 五、待处理

#### 抖音登录功能
- 用户要求去掉抖音登录功能，改为手动添加 Cookie

#### 多语言适配
- 界面部分还没有完全使用多语言支持，需要进一步适配

## 技术细节

### 文件结构
```
lib/
├── core/
│   ├── services/
│   │   ├── cookie_service.dart      # Cookie 管理服务
│   │   └── ytdlp_service.dart      # yt-dlp 服务
│   └── providers/
│       └── service_providers.dart  # 服务提供者
├── features/
│   ├── settings/
│   │   ├── settings_page.dart      # 设置页面
│   │   └── webview_login_page.dart # WebView 登录页面
│   └── download/
│       └── add_url_dialog.dart     # 添加 URL 对话框
├── shared/
│   └── i18n/
│       ├── app_localizations.dart       # 本地化主类
│       ├── app_localizations_zh.dart    # 中文
│       ├── app_localizations_en.dart    # 英文
│       ├── app_localizations_ja.dart    # 日语
│       └── app_localizations_ko.dart    # 韩语
└── main.dart                       # 应用入口
```

### 关键实现

#### 自定义 UA 使用
```dart
// 获取自定义 UA
final prefs = await SharedPreferences.getInstance();
final customUA = prefs.getString('custom_ua') ?? '';

// 在 WebView 登录中使用
WebViewLoginPage(
  userAgent: customUA.isNotEmpty ? customUA : null,
)

// 在 yt-dlp 服务中使用
ytDlpService.getVideoInfo(url: url, customUA: customUA);
```

#### 语言切换
```dart
// 在设置中保存语言
await prefs.setString('language', languageCode);

// 在 main.dart 中加载
ref.read(languageProvider.notifier).state = languageCode;
```
