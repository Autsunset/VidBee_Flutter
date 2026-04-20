// 语言定义

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

const List<AppLanguage> supportedLanguages = [
  AppLanguage(
    code: 'zh',
    name: 'Chinese',
    nativeName: '简体中文',
  ),
  AppLanguage(
    code: 'en',
    name: 'English',
    nativeName: 'English',
  ),
  AppLanguage(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
  ),
  AppLanguage(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
  ),
];

// 获取语言列表
List<Map<String, String>> getLanguageList() {
  return supportedLanguages
      .map((lang) => {
            'code': lang.code,
            'name': lang.nativeName,
          })
      .toList();
}

// 根据代码获取语言
AppLanguage? getLanguageByCode(String code) {
  return supportedLanguages.firstWhere(
    (lang) => lang.code == code,
    orElse: () => supportedLanguages[0],
  );
}
