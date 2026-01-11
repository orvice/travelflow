import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/location_marker.dart';

/// A panel widget for displaying and managing favorite locations.
///
/// Displays a list of favorite locations with search functionality,
/// tap-to-select, and swipe-to-delete features.
class FavoritesPanel extends StatefulWidget {
  /// The list of favorite locations to display.
  final List<LocationMarker> favorites;

  /// Callback when a location is tapped.
  final void Function(LocationMarker marker) onLocationTap;

  /// Callback when a location is deleted via swipe.
  final void Function(String id) onDelete;

  const FavoritesPanel({
    super.key,
    required this.favorites,
    required this.onLocationTap,
    required this.onDelete,
  });

  @override
  State<FavoritesPanel> createState() => _FavoritesPanelState();
}

class _FavoritesPanelState extends State<FavoritesPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocationMarker> get _filteredFavorites {
    if (_searchQuery.isEmpty) {
      return widget.favorites;
    }
    final lowerQuery = _searchQuery.toLowerCase();
    return widget.favorites
        .where((marker) => marker.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '收藏地点',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.favorites.length} 个地点',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索地点...',
                hintStyle: GoogleFonts.notoSansSc(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withAlpha(13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.notoSansSc(
                color: isDark ? Colors.white : Colors.black87,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: _buildContent(isDark, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, ColorScheme colorScheme) {
    // Empty state - no favorites at all
    if (widget.favorites.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.favorite_border,
        title: '暂无收藏',
        subtitle: '长按地图添加标记，然后收藏喜欢的地点',
      );
    }

    final filtered = _filteredFavorites;

    // No results state - search has no matches
    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.search_off,
        title: '未找到结果',
        subtitle: '没有找到包含 "$_searchQuery" 的地点',
      );
    }

    // List of favorites
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final marker = filtered[index];
        return _buildFavoriteItem(marker, isDark, colorScheme);
      },
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.notoSansSc(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(
    LocationMarker marker,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Dismissible(
      key: Key(marker.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              '确认删除',
              style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
            ),
            content: Text(
              '确定要从收藏中移除 "${marker.name}" 吗？',
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
        ) ?? false;
      },
      onDismissed: (direction) {
        widget.onDelete(marker.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 0,
        color: isDark ? Colors.white10 : Colors.black.withAlpha(13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => widget.onLocationTap(marker),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${marker.latitude.toStringAsFixed(4)}, ${marker.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the favorites panel as a modal bottom sheet.
///
/// Returns the selected [LocationMarker] if a location was tapped,
/// or null if the panel was dismissed.
Future<LocationMarker?> showFavoritesPanel({
  required BuildContext context,
  required List<LocationMarker> favorites,
  required void Function(String id) onDelete,
}) async {
  return showModalBottomSheet<LocationMarker>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return FavoritesPanel(
            favorites: favorites,
            onLocationTap: (marker) {
              Navigator.of(context).pop(marker);
            },
            onDelete: onDelete,
          );
        },
      );
    },
  );
}
