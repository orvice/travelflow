import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // 添加一些示例标记点
    _addSampleMarkers();
  }

  void _addSampleMarkers() {
    _markers = [
      Marker(
        point: const LatLng(39.9042, 116.4074), // 北京
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            _showLocationInfo('北京', const LatLng(39.9042, 116.4074));
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
      Marker(
        point: const LatLng(31.2304, 121.4737), // 上海
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            _showLocationInfo('上海', const LatLng(31.2304, 121.4737));
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
      Marker(
        point: const LatLng(22.3193, 114.1694), // 香港
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            _showLocationInfo('香港', const LatLng(22.3193, 114.1694));
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 40,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showLocationInfo(String name, LatLng position) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
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
                                '点击地图上的标记可以查看详细位置信息',
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
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          // 控制按钮
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
          // 底部信息栏
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
                          'OpenStreetMap',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '点击标记查看位置信息',
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
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '免费',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
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
