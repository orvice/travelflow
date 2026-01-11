import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/location_marker.dart';

/// A panel widget for displaying location marker details.
///
/// Shows the marker's name, notes, and coordinates with options to
/// edit, delete, or toggle favorite status.
class DetailPanel extends StatelessWidget {
  /// The marker to display details for.
  final LocationMarker marker;

  /// Callback when the edit button is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete button is tapped.
  final VoidCallback onDelete;

  /// Callback when the favorite button is tapped.
  final VoidCallback onToggleFavorite;

  /// Callback when the panel is closed.
  final VoidCallback? onClose;

  const DetailPanel({
    super.key,
    required this.marker,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: marker.isFavorite
                        ? Colors.amber.withAlpha(26)
                        : colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    marker.isFavorite ? Icons.star : Icons.location_on,
                    color: marker.isFavorite
                        ? Colors.amber
                        : colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    marker.name,
                    style: GoogleFonts.notoSansSc(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coordinates
                _buildInfoRow(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  icon: Icons.location_on_outlined,
                  label: '坐标',
                  value:
                      '${marker.latitude.toStringAsFixed(6)}, ${marker.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 12),
                // Notes
                _buildInfoRow(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  icon: Icons.notes_outlined,
                  label: '备注',
                  value: marker.notes?.isNotEmpty == true
                      ? marker.notes!
                      : '暂无备注',
                  isPlaceholder: marker.notes?.isNotEmpty != true,
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    // Favorite button
                    Expanded(
                      child: _buildActionButton(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: marker.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: marker.isFavorite ? '已收藏' : '收藏',
                        onTap: onToggleFavorite,
                        isActive: marker.isFavorite,
                        activeColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    Expanded(
                      child: _buildActionButton(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: Icons.edit_outlined,
                        label: '编辑',
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    Expanded(
                      child: _buildActionButton(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: Icons.delete_outline,
                        label: '删除',
                        onTap: () => _confirmDelete(context),
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
    bool isPlaceholder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: isPlaceholder
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
    Color? activeColor,
  }) {
    final Color buttonColor;
    final Color iconColor;
    final Color textColor;

    if (isDestructive) {
      buttonColor = isDark ? Colors.red.withAlpha(26) : Colors.red.withAlpha(26);
      iconColor = Colors.red;
      textColor = Colors.red;
    } else if (isActive && activeColor != null) {
      buttonColor = activeColor.withAlpha(26);
      iconColor = activeColor;
      textColor = activeColor;
    } else {
      buttonColor = isDark ? Colors.white10 : Colors.black.withAlpha(13);
      iconColor = isDark ? Colors.white70 : Colors.black54;
      textColor = isDark ? Colors.white70 : Colors.black54;
    }

    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.notoSansSc(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '确认删除',
          style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '确定要删除 "${marker.name}" 吗？此操作无法撤销。',
          style: GoogleFonts.notoSansSc(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消', style: GoogleFonts.notoSansSc()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除', style: GoogleFonts.notoSansSc()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }
}

/// Shows the detail panel as a modal bottom sheet.
///
/// Returns true if the marker was deleted, false otherwise.
Future<bool> showDetailPanel({
  required BuildContext context,
  required LocationMarker marker,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required VoidCallback onToggleFavorite,
}) async {
  bool wasDeleted = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DetailPanel(
        marker: marker,
        onEdit: () {
          Navigator.of(context).pop();
          onEdit();
        },
        onDelete: () {
          wasDeleted = true;
          Navigator.of(context).pop();
          onDelete();
        },
        onToggleFavorite: onToggleFavorite,
        onClose: () => Navigator.of(context).pop(),
      );
    },
  );

  return wasDeleted;
}
