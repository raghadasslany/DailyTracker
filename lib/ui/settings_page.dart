import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _handleClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              provider.clearGoals();
              provider.clearLogs();
              provider.clearMoods();
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF141920) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final borderCol = isDark
        ? const Color(0xFF1F2937)
        : const Color(0xFFE2E8F0);
    const accent = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your preferences',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // App Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    Text(
                      'DayStack',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0  •  Mood & Goal Tracker',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section (Dark Mode Toggle)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette_outlined,
                          size: 20,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              size: 22,
                              color: isDark
                                  ? Colors.amber.shade300
                                  : Colors.amber.shade600,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark
                                      ? 'Easier on the eyes'
                                      : 'Switch to dark theme',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (_) => provider.toggleDarkMode(),
                          activeColor: accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A personal companion for tracking daily activities and moods. Stay focused, monitor your progress, and build better habits over time.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storage_rounded,
                          size: 20,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data Management',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All your data is stored locally on your device. Clear it if you want to start fresh.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _handleClearAll(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.red.shade900.withOpacity(0.3)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear All Data',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6366F1),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTip('Log your mood daily to track patterns'),
                    _buildTip('Set realistic goals and stay consistent'),
                    _buildTip('Check your Recap to see your weekly progress'),
                    _buildTip('Add notes to remember important details'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.arrow_right_rounded,
              size: 16,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
