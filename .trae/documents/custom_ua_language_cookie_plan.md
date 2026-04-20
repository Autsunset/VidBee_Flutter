# 自定义UA、语言切换和Cookie提取功能实现计划

## 项目现状分析

### 1. 自定义UA功能
- ✅ 已在设置页面实现基本UI和存储逻辑
- ❌ 未在 yt-dlp 服务中集成使用
- ❌ YouTube 登录失败（可能是UA问题）

### 2. 语言切换功能
- ✅ 有语言选择UI
- ❌ 语言切换逻辑未实现
- ❌ 多语言资源文件缺失

### 3. Cookie提取功能
- ✅ 基本的Cookie存储和管理
- ❌ 无从浏览器提取Cookie的功能
- ❌ 无类似电脑版VidBee的Firefox Cookie提取功能

## 实现计划

### 第一阶段：完善自定义UA功能

#### 1.1 集成自定义UA到 yt-dlp 服务
- **文件**：`lib/core/services/ytdlp_service.dart`
- **修改**：
  - 添加 `customUA` 参数到 `getVideoInfo` 和 `downloadVideo` 方法
  - 确保自定义UA在所有网络请求中生效
  - 为 YouTube 提供推荐的UA配置

#### 1.2 优化YouTube登录
- **文件**：`lib/features/settings/webview_login_page.dart`
- **修改**：
  - 为 YouTube 登录页面设置特定的UA
  - 改进登录流程和错误处理

### 第二阶段：实现语言切换功能

#### 2.1 创建多语言资源文件
- **文件**：
  - `lib/shared/constants/languages.dart` - 语言定义
  - `lib/shared/i18n/` 目录 - 多语言翻译文件
- **实现**：
  - 支持简体中文、英文等常用语言
  - 提供语言切换的下拉选择

#### 2.2 集成语言切换逻辑
- **文件**：`lib/main.dart`、`lib/features/settings/settings_page.dart`
- **修改**：
  - 使用 Flutter 的本地化机制
  - 确保语言设置持久化
  - 实现应用内语言实时切换

### 第三阶段：实现Cookie提取功能

#### 3.1 浏览器Cookie提取
- **文件**：`lib/core/services/cookie_service.dart`
- **实现**：
  - 检测已安装的浏览器（Chrome、Firefox、Edge等）
  - 提供从浏览器提取Cookie的选项
  - 支持导出/导入Cookie功能

#### 3.2 增强Cookie管理
- **文件**：`lib/features/settings/settings_page.dart`
- **修改**：
  - 添加Cookie管理界面
  - 支持查看、编辑、删除Cookie
  - 提供Cookie备份和恢复功能

## 技术实现细节

### 自定义UA实现
- 使用 `SharedPreferences` 存储自定义UA
- 在 `YtDlpService` 中通过 `extractor` 插件的配置传递UA
- 为不同网站提供推荐UA模板

### 语言切换实现
- 使用 Flutter 的 `intl` 包进行国际化
- 创建 `.arb` 文件存储翻译
- 实现语言选择器和设置持久化

### Cookie提取实现
- 对于 Android：访问浏览器的Cookie数据库
- 对于 Windows：读取浏览器的Cookie文件
- 提供手动输入和导入/导出功能

## 风险和注意事项

1. **权限问题**：
   - 访问浏览器Cookie可能需要特殊权限
   - Android 10+ 需要存储权限

2. **兼容性问题**：
   - 不同浏览器的Cookie存储格式不同
   - 不同版本的操作系统可能有不同的限制

3. **安全性问题**：
   - Cookie包含敏感信息，需要安全存储
   - 确保不会泄露用户的登录凭证

4. **性能问题**：
   - 语言切换可能需要重建整个Widget树
   - Cookie提取可能涉及大量I/O操作

## 预期效果

1. **自定义UA**：
   - 用户可以设置全局自定义UA
   - YouTube 可以正常登录
   - 提供常用网站的UA模板

2. **语言切换**：
   - 支持多语言界面
   - 语言设置在重启后保持
   - 实时预览语言效果

3. **Cookie提取**：
   - 从浏览器一键提取Cookie
   - 支持多种浏览器
   - 提供Cookie管理功能

## 实现步骤

1. **准备阶段**：
   - 创建多语言资源文件
   - 配置项目依赖

2. **核心功能实现**：
   - 集成自定义UA到 yt-dlp 服务
   - 实现语言切换逻辑
   - 开发Cookie提取功能

3. **UI完善**：
   - 优化设置页面布局
   - 添加语言选择界面
   - 实现Cookie管理界面

4. **测试和优化**：
   - 测试不同网站的登录
   - 验证语言切换效果
   - 测试Cookie提取功能

5. **部署**：
   - 提交代码到GitHub
   - 构建测试版本
