import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanly/core/providers/theme_provider.dart';
import 'package:scanly/core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // Tema Ayarı
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: Text(_getThemeName(themeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Aydınlık')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Karanlık')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                }
              },
            ),
          ),

          const Divider(),

          // Kalite Ayarı
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Görüntü Kalitesi'),
            subtitle: const Text('Yüksek (önerilen)'),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),

          // Varsayılan Filtre
          ListTile(
            leading: const Icon(Icons.photo_filter),
            title: const Text('Varsayılan Filtre'),
            subtitle: const Text('Orijinal'),
            onTap: () {
              // TODO: Filtre seçme dialogu
            },
          ),

          const Divider(),

          // Hakkında
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Uygulama Hakkında'),
            subtitle: const Text('Scanly v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Scanly',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.document_scanner, size: 48),
                children: [
                  const Text('Profesyonel belge tarama uygulaması.'),
                  const SizedBox(height: 8),
                  const Text('Tüm veriler cihazınızda saklanır.'),
                ],
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Uygulamayı Değerlendir'),
            onTap: () {
              // TODO: Play Store linki
            },
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Aydınlık';
      case ThemeMode.dark:
        return 'Karanlık';
      default:
        return 'Sistem';
    }
  }
}