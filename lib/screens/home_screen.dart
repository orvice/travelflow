import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/wallpaper_service.dart';
import '../providers/theme_provider.dart';
import '../models/travel_plan.dart';
import 'plan_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureCityController = TextEditingController();
  final _destinationCityController = TextEditingController();
  int _travelDays = 7;
  bool _isLoading = false;
  String? _wallpaperPath;
  bool _isWallpaperLoading = false;

  // 国内热门城市列表
  final List<String> _popularCities = [
    '北京',
    '上海',
    '广州',
    '深圳',
    '杭州',
    '成都',
    '重庆',
    '西安',
    '武汉',
    '南京',
    '天津',
    '青岛',
    '大连',
    '厦门',
    '昆明',
    '三亚',
    '哈尔滨',
    '长沙',
    '郑州',
    '济南',
  ];

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  @override
  void dispose() {
    _departureCityController.dispose();
    _destinationCityController.dispose();
    super.dispose();
  }

  // 加载壁纸
  Future<void> _loadWallpaper() async {
    setState(() {
      _isWallpaperLoading = true;
    });

    try {
      final wallpaperService = WallpaperService();

      // 先尝试获取缓存的壁纸
      final cachedPath = await wallpaperService.getCachedWallpaper();

      if (cachedPath != null) {
        setState(() {
          _wallpaperPath = cachedPath;
          _isWallpaperLoading = false;
        });
      } else {
        // 如果没有缓存，获取新的壁纸
        final newPath = await wallpaperService.fetchRandomWallpaper();
        if (newPath != null && mounted) {
          setState(() {
            _wallpaperPath = newPath;
            _isWallpaperLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _isWallpaperLoading = false;
          });
        }
      }
    } catch (e) {
      // 壁纸加载失败，保持默认背景
      if (mounted) {
        setState(() {
          _isWallpaperLoading = false;
        });
      }
    }
  }

  // 刷新壁纸
  Future<void> _refreshWallpaper() async {
    setState(() {
      _isWallpaperLoading = true;
    });

    try {
      final wallpaperService = WallpaperService();
      await wallpaperService.clearCache();

      final newPath = await wallpaperService.fetchRandomWallpaper();
      if (newPath != null && mounted) {
        setState(() {
          _wallpaperPath = newPath;
          _isWallpaperLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isWallpaperLoading = false;
        });
      }
    } catch (e) {
      // 刷新壁纸失败，保持当前状态
      if (mounted) {
        setState(() {
          _isWallpaperLoading = false;
        });
      }
    }
  }

  // 显示城市选择底部弹出菜单
  void _showCityPicker(BuildContext context, TextEditingController controller) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择城市',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 城市列表
              Expanded(
                child: ListView.builder(
                  itemCount: _popularCities.length,
                  itemBuilder: (context, index) {
                    final city = _popularCities[index];
                    return ListTile(
                      title: Text(
                        city,
                        style: GoogleFonts.notoSansSc(fontSize: 16),
                      ),
                      onTap: () {
                        setState(() {
                          controller.text = city;
                        });
                        Navigator.pop(context, city);
                      },
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateTravelPlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        final travelPlan = await apiService.getTravelPlan(
          travelDays: _travelDays,
          departureCity: _departureCityController.text,
          destinationCity: _destinationCityController.text,
        );

        // 创建带有ID和时间戳的新旅行计划
        final planWithMetadata = TravelPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          destination: travelPlan.destination,
          duration: travelPlan.duration,
          overview: travelPlan.overview,
          dailyPlan: travelPlan.dailyPlan,
          transportation: travelPlan.transportation,
          tips: travelPlan.tips,
          timestamp: DateTime.now(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PlanDetailScreen(travelPlan: planWithMetadata),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      // 移除传统 AppBar，使用自定义标题栏
      body: Stack(
        children: [
          // 壁纸背景
          if (_wallpaperPath != null)
            Positioned.fill(
              child: Image.file(
                File(_wallpaperPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 如果图片加载失败，显示渐变背景
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withValues(alpha: 0.1),
                          primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            // 默认渐变背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withValues(alpha: 0.1),
                      primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

          // 半透明遮罩层，优化内容可读性（降低透明度）
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 自定义标题栏（融入背景）- 降低透明度
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: Colors.white,
                          size: 28,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'TravelFlow',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 刷新按钮
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon:
                            _isWallpaperLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(Icons.refresh, color: Colors.white),
                        onPressed:
                            _isWallpaperLoading ? null : _refreshWallpaper,
                        tooltip: '更换壁纸',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 内容区域
          Positioned.fill(
            top: 90, // 增加顶部间距，为标题栏留出更多空间
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10), // 顶部额外间距
                    // App Title - 融入背景风格（提高透明度）
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.flight_takeoff,
                          size: 56,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 主要标题 - 半透明背景（提高透明度）
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '开始您的旅程',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 副标题（提高透明度）
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '输入您的旅行信息，生成个性化行程',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 表单容器 - 半透明玻璃效果
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // 出发城市输入框
                            _buildInputField(
                              controller: _departureCityController,
                              label: '出发城市',
                              icon: Icons.flight_takeoff,
                              onTap:
                                  () => _showCityPicker(
                                    context,
                                    _departureCityController,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // 目的城市输入框
                            _buildInputField(
                              controller: _destinationCityController,
                              label: '目的城市',
                              icon: Icons.location_on,
                              onTap:
                                  () => _showCityPicker(
                                    context,
                                    _destinationCityController,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // 旅行天数选择
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '旅行天数',
                                        style: GoogleFonts.notoSansSc(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$_travelDays 天',
                                        style: GoogleFonts.notoSansSc(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Slider(
                                    value: _travelDays.toDouble(),
                                    min: 1,
                                    max: 14,
                                    divisions: 13,
                                    onChanged: (value) {
                                      setState(() {
                                        _travelDays = value.toInt();
                                      });
                                    },
                                    activeColor: Colors.white.withValues(
                                      alpha: 0.8,
                                    ),
                                    inactiveColor: Colors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                    thumbColor: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 生成按钮
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _generateTravelPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black87,
                                                ),
                                          ),
                                        )
                                        : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '生成旅行计划',
                                              style: GoogleFonts.notoSansSc(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.notoSansSc(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.notoSansSc(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.9)),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: false,
        ),
        readOnly: true,
        onTap: onTap,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入$label';
          }
          return null;
        },
      ),
    );
  }
}
