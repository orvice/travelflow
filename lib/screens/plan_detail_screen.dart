import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/travel_plan.dart';
import '../providers/theme_provider.dart';
import '../services/history_service.dart';

class PlanDetailScreen extends StatefulWidget {
  final TravelPlan travelPlan;

  const PlanDetailScreen({super.key, required this.travelPlan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    try {
      final historyService = HistoryService();
      await historyService.addTravelPlan(widget.travelPlan);
      setState(() {
        _isSaved = true;
      });
    } catch (e) {
      print('Error saving to history: $e');
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
          // 渐变背景
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
                  children: [
                    // 返回按钮
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    // 标题
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.travelPlan.destination,
                            style: GoogleFonts.notoSansSc(
                              fontSize: 20,
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
                          Text(
                            '${widget.travelPlan.duration} 天行程',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 保存状态指示
                    if (_isSaved)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 内容区域
          Positioned.fill(
            top: 90, // 增加顶部间距，为标题栏留出更多空间
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8), // 顶部额外间距
                  // 行程概览 - 半透明玻璃效果
                  _buildSectionCard(
                    icon: Icons.info_outline,
                    title: '行程概览',
                    primaryColor: primaryColor,
                    child: Text(
                      widget.travelPlan.overview,
                      style: GoogleFonts.notoSansSc(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 每日行程标题
                  _buildSectionTitle(
                    '每日行程',
                    Icons.calendar_today,
                    primaryColor,
                  ),
                  const SizedBox(height: 12),
                  ...widget.travelPlan.dailyPlan.map(
                    (day) => _buildDayCard(day, primaryColor),
                  ),

                  // 交通信息
                  if (widget.travelPlan.transportation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      icon: Icons.directions_car,
                      title: '交通信息',
                      primaryColor: primaryColor,
                      child: Text(
                        widget.travelPlan.transportation,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  // 旅行提示
                  if (widget.travelPlan.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      icon: Icons.lightbulb_outline,
                      title: '旅行提示',
                      primaryColor: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            widget.travelPlan.tips.map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Colors.green.shade300,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: GoogleFonts.notoSansSc(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.notoSansSc(
              fontSize: 20,
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
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 18,
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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(DailyPlan day, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.notoSansSc(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '第 ${day.day} 天',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 20,
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
            const SizedBox(height: 16),

            // Activities
            if (day.activities.isNotEmpty) ...[
              _buildSubSection(
                icon: Icons.directions_walk,
                title: '活动安排',
                items: day.activities,
              ),
              const SizedBox(height: 12),
            ],

            // Meals
            if (day.meals.isNotEmpty) ...[
              _buildSubSection(
                icon: Icons.restaurant,
                title: '餐饮',
                items: day.meals,
              ),
              const SizedBox(height: 12),
            ],

            // Accommodation
            if (day.accommodation.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.hotel,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '住宿',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.accommodation,
                          style: GoogleFonts.notoSansSc(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.notoSansSc(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.notoSansSc(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
