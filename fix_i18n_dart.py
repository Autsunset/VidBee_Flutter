import os
import re

base_dir = r"c:\Users\autsu\Documents\trae_projects\VidBee_Flutter\lib\shared\i18n"
langs = ["zh", "en", "ja", "ko"]

for lang in langs:
    file_path = os.path.join(base_dir, f"app_localizations_{lang}.dart")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # We will grab everything inside `final Map<String, String> _localizedValues = { ... };`
    # and reconstruct it.
    match = re.search(r"final Map<String, String> _localizedValues = \{(.*?)\};\n\n  String getLocalizedValue", content, re.DOTALL)
    if not match:
        print(f"Skipping {lang}")
        continue
    
    dict_content = match.group(1)
    
    # We'll split the dict content by lines, but because of physical newlines inside strings,
    # this might be tricky. Let's just fix the specific broken strings!
    
    # Fix physical newlines inside single quotes
    # The pattern is: unescaped single quote -> some characters -> newline -> characters -> unescaped single quote
    # It's easier to just replace \n with \\n where they are inside strings.
    # Actually, the simplest fix is to just replace the physical newlines in those specific keys
    
    # Replace the physical newlines first
    content = content.replace("解析失败！\n\n您的", "解析失败！\\n\\n您的")
    content = content.replace("解析失败！\n\n该网站", "解析失败！\\n\\n该网站")
    content = content.replace("解析失败！\n\n请检查", "解析失败！\\n\\n请检查")
    
    content = content.replace("Parse failed!\n\nYour", "Parse failed!\\n\\nYour")
    content = content.replace("Parse failed!\n\nThis", "Parse failed!\\n\\nThis")
    content = content.replace("Parse failed!\n\nPlease", "Parse failed!\\n\\nPlease")

    content = content.replace("解析に失敗しました！\n\nCookie", "解析に失敗しました！\\n\\nCookie")
    content = content.replace("解析に失敗しました！\n\nこの", "解析に失敗しました！\\n\\nこの")
    content = content.replace("解析に失敗しました！\n\nネット", "解析に失敗しました！\\n\\nネット")

    content = content.replace("파싱 실패!\n\n쿠키가", "파싱 실패!\\n\\n쿠키가")
    content = content.replace("파싱 실패!\n\n이", "파싱 실패!\\n\\n이")
    content = content.replace("파싱 실패!\n\n네트워크", "파싱 실패!\\n\\n네트워크")

    # Fix the unescaped single quotes in english:
    # 'To save videos to the public storage directory, you need to grant the 'Manage all files' permission. Please enable this permission in the settings.'
    content = content.replace("grant the 'Manage all files' permission", "grant the \\'Manage all files\\' permission")
    
    # Also I noticed Bilibili's has a single quote
    content = content.replace("Bilibili's", "Bilibili\\'s")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
print("Fix applied")
