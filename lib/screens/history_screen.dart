import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/wallpaper_service.dart';
import '../services/history_service.dart';
import '../models/travel_plan.dart';
import 'plan_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _wallpaperPath;
  List<TravelPlan> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
    _loadHistory();
  }

  // 加载壁纸
  Future<void> _loadWallpaper() async {
    try {
      final wallpaperService = WallpaperService();
      final cachedPath = await wallpaperService.getCachedWallpaper();

      if (cachedPath != null && mounted) {
        setState(() {
          _wallpaperPath = cachedPath;
        });
      }
    } catch (e) {
      // 壁纸加载失败，保持默认背景
    }
  }

  // 加载历史记录
  Future<void> _loadHistory() async {
    try {
      final historyService = HistoryService();
      final history = await historyService.getHistory();

      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 删除历史记录
  Future<void> _deleteHistoryItem(String id) async {
    try {
      final historyService = HistoryService();
      await historyService.removeTravelPlan(id);

      if (mounted) {
        setState(() {
          _history.removeWhere((plan) => plan.id == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已删除'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 清空所有历史记录
  Future<void> _clearAllHistory() async {
    try {
      final historyService = HistoryService();
      await historyService.clearHistory();

      if (mounted) {
        setState(() {
          _history.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已清空所有历史记录'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 查看历史记录详情
  void _viewHistoryDetail(TravelPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(travelPlan: plan),
      ),
    );
  }

  // 格式化时间
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
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
                      child: Text(
                        '历史记录',
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
                    ),
                    // 清空按钮
                    if (_history.isNotEmpty)
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
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.95,
                                    ),
                                    title: Text(
                                      '清空历史记录',
                                      style: GoogleFonts.notoSansSc(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      '确定要清空所有历史记录吗？此操作不可恢复。',
                                      style: GoogleFonts.notoSansSc(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          '取消',
                                          style: GoogleFonts.notoSansSc(),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _clearAllHistory();
                                        },
                                        child: Text(
                                          '清空',
                                          style: GoogleFonts.notoSansSc(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          tooltip: '清空历史记录',
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
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '加载中...',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // 顶部额外间距
            // 图标容器 - 半透明玻璃效果
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
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
                  Icons.history,
                  size: 56,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 主要标题
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '暂无历史记录',
                style: GoogleFonts.notoSansSc(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // 副标题
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                '生成的旅行计划将在这里显示',
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

            const SizedBox(height: 40), // 底部额外间距
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final plan = _history[index];
        return _buildHistoryItem(plan, index);
      },
    );
  }

  Widget _buildHistoryItem(TravelPlan plan, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewHistoryDetail(plan),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：目的地和操作按钮
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.destination,
                            style: GoogleFonts.notoSansSc(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.duration} 天行程',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 删除按钮
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.95,
                                  ),
                                  title: Text(
                                    '删除记录',
                                    style: GoogleFonts.notoSansSc(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    '确定要删除 "${plan.destination}" 的旅行记录吗？',
                                    style: GoogleFonts.notoSansSc(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        '取消',
                                        style: GoogleFonts.notoSansSc(),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteHistoryItem(plan.id);
                                      },
                                      child: Text(
                                        '删除',
                                        style: GoogleFonts.notoSansSc(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        tooltip: '删除',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 时间信息
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(plan.timestamp),
                      style: GoogleFonts.notoSansSc(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    // 查看详情按钮
                    Row(
                      children: [
                        Text(
                          '查看详情',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
