import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
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

  @override
  void dispose() {
    _departureCityController.dispose();
    _destinationCityController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: Text(
          'TravelFlow',
          style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                Icon(Icons.flight_takeoff, size: 64, color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  '开始您的旅程',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '智能旅行规划助手',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Departure City
                          TextFormField(
                            controller: _departureCityController,
                            decoration: InputDecoration(
                              labelText: '出发城市',
                              hintText: '例如：深圳',
                              prefixIcon: const Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入出发城市';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Destination City
                          TextFormField(
                            controller: _destinationCityController,
                            decoration: InputDecoration(
                              labelText: '目的地城市',
                              hintText: '例如：哈尔滨',
                              prefixIcon: const Icon(Icons.place),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入目的地城市';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Travel Days Slider
                          Text(
                            '旅行天数：$_travelDays 天',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                            ),
                          ),
                          Slider(
                            value: _travelDays.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_travelDays 天',
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _travelDays = value.toInt();
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Generate Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _generateTravelPlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.explore),
                                          const SizedBox(width: 8),
                                          Text(
                                            '生成旅行计划',
                                            style: GoogleFonts.notoSansSc(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
