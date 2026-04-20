import os

keys = [
    ("noHistory", "暂无历史记录", "No History", "履歴なし", "기록 없음"),
    ("clearHistory", "清空历史", "Clear History", "履歴をクリア", "기록 지우기"),
    ("confirmClearHistory", "确定要清空所有历史记录吗？此操作不可撤销。", "Are you sure you want to clear all history? This action cannot be undone.", "すべての履歴をクリアしますか？この操作は元に戻せません。", "모든 기록을 지우시겠습니까? 이 작업은 취소할 수 없습니다."),
    ("taskDetails", "任务详情", "Task Details", "タスクの詳細", "작업 세부 정보"),
    ("unknownTitle", "未知标题", "Unknown Title", "不明なタイトル", "알 수 없는 제목"),
    ("titleField", "标题", "Title", "タイトル", "제목"),
    ("urlField", "链接", "URL", "URL", "URL"),
    ("typeField", "类型", "Type", "種類", "유형"),
    ("statusField", "状态", "Status", "ステータス", "상태"),
    ("close", "关闭", "Close", "閉じる", "닫기"),
    ("unknown", "未知", "Unknown", "不明", "알 수 없음"),
    ("parseFailedExpired", "解析失败！\n\n您的 Cookies 可能已过期，请尝试在设置中重新添加 Cookies。", "Parse failed!\n\nYour cookies may have expired. Please try adding cookies again in the settings.", "解析に失敗しました！\n\nCookieが期限切れの可能性があります。設定でCookieを再度追加してみてください。", "파싱 실패!\n\n쿠키가 만료되었을 수 있습니다. 설정에서 쿠키를 다시 추가해 보세요."),
    ("parseFailedFresh", "解析失败！\n\n该网站需要新鲜的 Cookies 才能解析，请在设置中添加 Cookies。", "Parse failed!\n\nThis site requires fresh cookies to parse. Please add cookies in the settings.", "解析に失敗しました！\n\nこのサイトの解析には新しいCookieが必要です。設定でCookieを追加してください。", "파싱 실패!\n\n이 사이트를 파싱하려면 새로운 쿠키가 필요합니다. 설정에서 쿠키를 추가하세요."),
    ("parseFailedBilibili", "解析失败！\n\n请检查网络连接或视频链接是否正确。Bilibili 的低清晰度视频无需 Cookies 也可解析。", "Parse failed!\n\nPlease check your network connection or if the video link is correct. Bilibili's low-resolution videos can be parsed without Cookies.", "解析に失敗しました！\n\nネットワーク接続やビデオリンクが正しいか確認してください。Bilibiliの低解像度ビデオはCookieなしで解析できます。", "파싱 실패!\n\n네트워크 연결이나 비디오 링크가 올바른지 확인하세요. Bilibili의 저해상도 비디오는 쿠키 없이 파싱할 수 있습니다."),
    ("parseFailedDefault", "解析失败！\n\n请检查网络连接或视频链接是否正确。某些网站可能需要 Cookies，请在设置中添加后重试。", "Parse failed!\n\nPlease check your network connection or if the video link is correct. Some sites may require Cookies. Please add them in the settings and try again.", "解析に失敗しました！\n\nネットワーク接続やビデオリンクが正しいか確認してください。一部のサイトではCookieが必要な場合があります。設定で追加して再試行してください。", "파싱 실패!\n\n네트워크 연결이나 비디오 링크가 올바른지 확인하세요. 일부 사이트에서는 쿠키가 필요할 수 있습니다. 설정에서 추가한 후 다시 시도하세요."),
    ("needStoragePermission", "需要存储权限", "Storage Permission Required", "ストレージ権限が必要です", "저장소 권한 필요"),
    ("storagePermissionMessage", "为了能保存视频到公共存储目录，需要授予\"管理所有文件\"权限。请在设置中开启此权限。", "To save videos to the public storage directory, you need to grant the 'Manage all files' permission. Please enable this permission in the settings.", "ビデオをパブリックストレージディレクトリに保存するには、「すべてのファイルを管理」権限を付与する必要があります。設定でこの権限を有効にしてください。", "비디오를 공용 저장소 디렉토리에 저장하려면 '모든 파일 관리' 권한을 부여해야 합니다. 설정에서 이 권한을 활성화하세요."),
    ("parsingVideo", "正在解析视频信息...", "Parsing video info...", "動画情報を解析中...", "비디오 정보 파싱 중..."),
    ("noAvailableFormat", "没有可用的格式", "No available format", "利用可能な形式がありません", "사용 가능한 형식 없음"),
    ("selectVideoQuality", "选择视频质量", "Select Video Quality", "画質を選択", "비디오 품질 선택"),
    ("selectAudioQuality", "选择音频质量", "Select Audio Quality", "音質を選択", "오디오 품질 선택"),
    ("highQualityRequiresLogin", "🔒 高清晰度需要登录，请在设置中添加 Cookie", "🔒 High definition requires login, please add Cookie in settings", "🔒 高解像度にはログインが必要です。設定でCookieを追加してください", "🔒 고해상도는 로그인이 필요합니다. 설정에서 쿠키를 추가하세요"),
]

base_dir = r"c:\Users\autsu\Documents\trae_projects\VidBee_Flutter\lib\shared\i18n"

# 1. Update app_localizations.dart
with open(os.path.join(base_dir, "app_localizations.dart"), "r", encoding="utf-8") as f:
    content = f.read()

getters = "\n".join([f"  String get {k[0]} => _translate('{k[0]}');" for k in keys])
content = content.replace("  String _translate(String key) {", getters + "\n\n  String _translate(String key) {")

with open(os.path.join(base_dir, "app_localizations.dart"), "w", encoding="utf-8") as f:
    f.write(content)

# 2. Update language files
langs = {"zh": 1, "en": 2, "ja": 3, "ko": 4}

for lang, idx in langs.items():
    file_path = os.path.join(base_dir, f"app_localizations_{lang}.dart")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    entries = "\n".join([f"    '{k[0]}': '{k[idx]}'," for k in keys])
    # Find the end of the _localizedValues map
    content = content.replace("  };\n\n  String getLocalizedValue", entries + "\n  };\n\n  String getLocalizedValue")
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

print("Done updating i18n files")
