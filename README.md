# TravelFlow - 智能旅行规划助手

一个基于 Flutter 开发的旅游规划应用，通过调用 AI 驱动的 API 来生成详细的旅行计划。

## 功能特性

- 🌍 输入出发地和目的地城市
- 📅 自定义旅行天数（1-30天）
- 🎯 获取详细的每日行程安排
- 🍽️ 包含餐饮和住宿建议
- 💡 提供实用的旅行提示
- 🎨 现代化的 UI 设计

## 应用截图

### 主页面
- 输入出发城市
- 输入目的地城市
- 选择旅行天数

### 详情页面
- 行程概览
- 每日详细计划（活动、餐饮、住宿）
- 交通信息
- 旅行提示

## API 接口

本应用使用以下 API：

**端点**: `https://api.lovec.at/v1/workflows/travelPlanFlow`

**请求格式**:
```json
{
  "data": {
    "travel_days": 7,
    "departure_city": "深圳",
    "destination_city": "哈尔滨"
  }
}
```

**响应格式**:
```json
{
  "result": {
    "destination": "哈尔滨",
    "duration": 7,
    "overview": "行程概述...",
    "daily_plan": [
      {
        "day": 1,
        "activities": ["活动1", "活动2"],
        "meals": ["早餐：...", "午餐：..."],
        "accommodation": "酒店名称"
      }
    ],
    "transportation": "交通信息",
    "tips": ["提示1", "提示2"]
  }
}
```

## 开始使用

### 前置要求

- Flutter SDK (>= 3.7.0)
- Dart SDK
- Android Studio / Xcode（用于移动端开发）
- VS Code 或其他代码编辑器

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# macOS
flutter run -d macos
```

## 项目结构

```
lib/
├── main.dart                  # 应用入口
├── models/
│   └── travel_plan.dart      # 数据模型
├── services/
│   └── api_service.dart      # API 服务
└── screens/
    ├── home_screen.dart      # 主页面（输入界面）
    └── plan_detail_screen.dart # 计划详情页面
```

## 依赖包

- `http: ^1.1.0` - HTTP 请求
- `google_fonts: ^6.1.0` - Google 字体
- `cupertino_icons: ^1.0.8` - iOS 风格图标

## 技术栈

- **框架**: Flutter
- **语言**: Dart
- **UI**: Material Design 3
- **状态管理**: StatefulWidget
- **网络请求**: http package

## 开发说明

### 添加新功能

1. 在 `lib/models` 中添加新的数据模型
2. 在 `lib/services` 中添加新的服务类
3. 在 `lib/screens` 中创建新的页面
4. 在 `main.dart` 中配置路由

### 自定义主题

在 `main.dart` 中修改 `ThemeData` 来自定义应用主题：

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // 修改主色调
    brightness: Brightness.light,
  ),
  useMaterial3: true,
),
```

 
