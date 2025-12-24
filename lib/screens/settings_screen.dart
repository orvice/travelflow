import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设置',
          style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(
                  '关于 TravelFlow',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '版本 1.0.0',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TravelFlow',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 TravelFlow',
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        '智能旅行规划助手，让您的旅行更加轻松愉快。',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(
                  '隐私政策',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  // 可以添加隐私政策页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '隐私政策页面开发中...',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(
                  '使用帮助',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  // 可以添加帮助页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '使用帮助页面开发中...',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
