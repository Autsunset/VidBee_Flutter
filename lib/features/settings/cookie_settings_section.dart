// 设置页 Cookie 管理区块（导入文件 + 站点登录卡片）
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/i18n/app_localizations.dart';

class CookieSettingsSection extends StatelessWidget {
  final AppLocalizations loc;
  final Map<String, String> cookies;
  final String? cookieFilePath;
  final VoidCallback onImportCookieFile;
  final VoidCallback onClearCookieFile;
  final VoidCallback onLoginBilibili;
  final VoidCallback onLoginYouTube;
  final VoidCallback onEditBilibiliCookie;
  final VoidCallback onEditYouTubeCookie;
  final VoidCallback onRemoveBilibiliCookie;
  final VoidCallback onRemoveYouTubeCookie;
  final VoidCallback onAddOtherCookies;
  final VoidCallback onClearAllCookies;

  const CookieSettingsSection({
    super.key,
    required this.loc,
    required this.cookies,
    required this.cookieFilePath,
    required this.onImportCookieFile,
    required this.onClearCookieFile,
    required this.onLoginBilibili,
    required this.onLoginYouTube,
    required this.onEditBilibiliCookie,
    required this.onEditYouTubeCookie,
    required this.onRemoveBilibiliCookie,
    required this.onRemoveYouTubeCookie,
    required this.onAddOtherCookies,
    required this.onClearAllCookies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImportCookieCard(
          loc: loc,
          cookieFilePath: cookieFilePath,
          onImport: onImportCookieFile,
          onClear: onClearCookieFile,
        ),
        _SiteLoginCard(
          title: 'Bilibili ${loc.login}',
          loc: loc,
          hasCookie: cookies.containsKey('bilibili.com'),
          onLogin: onLoginBilibili,
          onEdit: onEditBilibiliCookie,
          onRemove: onRemoveBilibiliCookie,
        ),
        _SiteLoginCard(
          title: 'YouTube ${loc.login}',
          loc: loc,
          hasCookie: cookies.containsKey('youtube.com'),
          onLogin: onLoginYouTube,
          onEdit: onEditYouTubeCookie,
          onRemove: onRemoveYouTubeCookie,
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: Text(loc.addOtherCookies),
          subtitle: Text(loc.manualCookieInput),
          trailing: const Icon(Icons.chevron_right),
          onTap: onAddOtherCookies,
        ),
        if (cookies.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(loc.clearAll),
            subtitle: Text('${cookies.length} Cookies'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onClearAllCookies,
          ),
      ],
    );
  }
}

class _ImportCookieCard extends StatelessWidget {
  final AppLocalizations loc;
  final String? cookieFilePath;
  final VoidCallback onImport;
  final VoidCallback onClear;

  const _ImportCookieCard({
    required this.loc,
    required this.cookieFilePath,
    required this.onImport,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_open_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  loc.importCookieFile,
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://github.com/Autsunset/VidBee_Flutter/blob/main/COOKIES_GUIDE.md',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.cookieHelp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              loc.importCookieFileHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    cookieFilePath != null
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: cookieFilePath != null
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cookieFilePath != null
                          ? '${loc.currentCookieFile}: ${cookieFilePath!.split('/').last.split('\\').last}'
                          : loc.noCookieFile,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onImport,
                    icon: const Icon(Icons.upload_file),
                    label: Text(loc.importCookieFile),
                  ),
                ),
                if (cookieFilePath != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(loc.clearCookieFile),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SiteLoginCard extends StatelessWidget {
  final String title;
  final AppLocalizations loc;
  final bool hasCookie;
  final VoidCallback onLogin;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _SiteLoginCard({
    required this.title,
    required this.loc,
    required this.hasCookie,
    required this.onLogin,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.login, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onLogin,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(loc.login),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: Text(loc.manualCookieInput),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasCookie
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: hasCookie
                      ? Colors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasCookie ? loc.success : loc.loginRequired,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasCookie
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (hasCookie)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text(loc.clear),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
