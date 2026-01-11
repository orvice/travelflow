import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/location_marker.dart';
import '../services/location_service.dart';
import '../widgets/marker_dialog.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/detail_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final Uuid _uuid = const Uuid();
  
  List<LocationMarker> _locationMarkers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final markers = await _locationService.getAllMarkers();
      setState(() {
        _locationMarkers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载标记失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Marker> _buildMapMarkers() {
    return _locationMarkers.map((locationMarker) {
      return Marker(
        point: LatLng(locationMarker.latitude, locationMarker.longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showDetailPanel(locationMarker),
          child: Icon(
            locationMarker.isFavorite ? Icons.star : Icons.location_on,
            color: locationMarker.isFavorite ? Colors.amber : Colors.red,
            size: 40,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _handleLongPress(TapPosition tapPosition, LatLng position) async {
    final result = await showMarkerDialog(
      context: context,
      position: position,
    );

    if (result != null) {
      final (name, notes) = result;
      final now = DateTime.now();
      final newMarker = LocationMarker(
        id: _uuid.v4(),
        name: name,
        notes: notes,
        latitude: position.latitude,
        longitude: position.longitude,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      try {
        await _locationService.addMarker(newMarker);
        await _loadMarkers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已添加标记: $name'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加标记失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDetailPanel(LocationMarker marker) async {
    await showDetailPanel(
      context: context,
      marker: marker,
      onEdit: () => _editMarker(marker),
      onDelete: () => _deleteMarker(marker.id),
      onToggleFavorite: () => _toggleFavorite(marker.id),
    );
  }

  Future<void> _editMarker(LocationMarker marker) async {
    final result = await showMarkerDialog(
      context: context,
      marker: marker,
    );

    if (result != null) {
      final (name, notes) = result;
      final updatedMarker = marker.copyWith(
        name: name,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      try {
        await _locationService.updateMarker(updatedMarker);
        await _loadMarkers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已更新标记: $name'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新标记失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteMarker(String id) async {
    try {
      await _locationService.deleteMarker(id);
      await _loadMarkers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已删除标记'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除标记失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await _locationService.toggleFavorite(id);
      await _loadMarkers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新收藏状态失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showFavoritesPanel() async {
    final favorites = _locationMarkers.where((m) => m.isFavorite).toList();
    
    final selectedMarker = await showFavoritesPanel(
      context: context,
      favorites: favorites,
      onDelete: (id) async {
        await _toggleFavorite(id);
      },
    );

    if (selectedMarker != null) {
      _centerOnLocation(selectedMarker);
    }
  }

  void _centerOnLocation(LocationMarker marker) {
    _mapController.move(
      LatLng(marker.latitude, marker.longitude),
      14,
    );
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _centerOnUser() {
    // 模拟用户位置（北京）
    _mapController.move(const LatLng(39.9042, 116.4074), 12);
  }

  void _showMapInfo(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'OpenStreetMap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('数据源', 'OpenStreetMap', Icons.language),
                      const SizedBox(height: 12),
                      _buildInfoRow('服务类型', '免费开源地图', Icons.lock_open),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        '功能',
                        '查看位置、缩放、定位',
                        Icons.featured_play_list,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              size: 18,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '长按地图添加标记，点击标记查看详情',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.blue.shade600),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteCount = _locationMarkers.where((m) => m.isFavorite).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? Colors.black87 : Colors.white,
                isDark ? Colors.transparent : Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: AppBar(
            title: const Text(
              'OpenStreetMap',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              // Favorites button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 20,
                        color: favoriteCount > 0 
                            ? Colors.red 
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                      onPressed: _showFavoritesPanel,
                    ),
                    if (favoriteCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$favoriteCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info button
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    _showMapInfo(context, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(35.8617, 104.1954), // 中国中心
              initialZoom: 4,
              minZoom: 2,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onLongPress: _handleLongPress,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(markers: _buildMapMarkers()),
            ],
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Control buttons
          Positioned(
            right: 16,
            bottom: 100,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black54 : Colors.white70,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    icon: Icons.add,
                    onPressed: _zoomIn,
                    isDark: isDark,
                    isFirst: true,
                  ),
                  _buildControlButton(
                    icon: Icons.remove,
                    onPressed: _zoomOut,
                    isDark: isDark,
                  ),
                  _buildControlButton(
                    icon: Icons.my_location,
                    onPressed: _centerOnUser,
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          // Bottom info bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? Colors.black87 : Colors.white,
                    isDark ? Colors.black54 : Colors.white70,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.map,
                      size: 18,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_locationMarkers.length} 个标记',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '长按地图添加标记',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$favoriteCount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? Colors.black54 : Colors.white70,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        border: Border(
          top:
              isFirst
                  ? BorderSide.none
                  : BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 0.5,
                  ),
          bottom:
              isLast
                  ? BorderSide.none
                  : BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 0.5,
                  ),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 26),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(16) : Radius.zero,
              bottom: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
