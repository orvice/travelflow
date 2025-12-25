import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/wallpaper_service.dart';
import '../providers/theme_provider.dart';
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

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailScreen(travelPlan: travelPlan),
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

          // 半透明遮罩层，确保内容可读
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

          // 自定义标题栏（融入背景）
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
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
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
                                color: Colors.black.withValues(alpha: 0.5),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
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
            top: 80, // 为标题栏留出空间
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Title - 融入背景风格
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
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

                    // 主要标题 - 半透明背景
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
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

                    // 副标题
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '智能旅行规划助手',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 18,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Card - 半透明玻璃效果
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Departure City
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _departureCityController,
                                      style: GoogleFonts.notoSansSc(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: '出发城市',
                                        labelStyle: GoogleFonts.notoSansSc(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        hintText: '例如：深圳',
                                        hintStyle: GoogleFonts.notoSansSc(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                          ),
                                          onPressed:
                                              () => _showCityPicker(
                                                context,
                                                _departureCityController,
                                              ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '请输入出发城市';
                                        }
                                        return null;
                                      },
                                      readOnly: true,
                                      onTap:
                                          () => _showCityPicker(
                                            context,
                                            _departureCityController,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Destination City
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _destinationCityController,
                                      style: GoogleFonts.notoSansSc(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: '目的地城市',
                                        labelStyle: GoogleFonts.notoSansSc(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        hintText: '例如：哈尔滨',
                                        hintStyle: GoogleFonts.notoSansSc(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.place,
                                          color: Colors.white,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                          ),
                                          onPressed:
                                              () => _showCityPicker(
                                                context,
                                                _destinationCityController,
                                              ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '请输入目的地城市';
                                        }
                                        return null;
                                      },
                                      readOnly: true,
                                      onTap:
                                          () => _showCityPicker(
                                            context,
                                            _destinationCityController,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Travel Days Slider
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '旅行天数：$_travelDays 天',
                                          style: GoogleFonts.notoSansSc(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Slider(
                                          value: _travelDays.toDouble(),
                                          min: 1,
                                          max: 30,
                                          divisions: 29,
                                          label: '$_travelDays 天',
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white
                                              .withValues(alpha: 0.3),
                                          thumbColor: Colors.white,
                                          onChanged: (value) {
                                            setState(() {
                                              _travelDays = value.toInt();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Generate Button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : _generateTravelPlan,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 6,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                      ),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.explore, size: 22),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '生成旅行计划',
                                                    style:
                                                        GoogleFonts.notoSansSc(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
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
}
