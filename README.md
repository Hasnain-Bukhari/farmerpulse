# 🌾 FarmerPulse - Smart Farm Management App

> **Offline-first farm management made simple.** Complete tracking of seasons, plots, activities, reminders, and finances with bilingual support (English + Urdu).

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Hive](https://img.shields.io/badge/Hive-orange?style=flat-square&logo=apache-hive&logoColor=white)](https://docs.hivedb.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-blue?style=flat-square&logo=flutter&logoColor=white)](https://riverpod.dev)

---

## 📱 **What is FarmerPulse?**

FarmerPulse is a comprehensive **offline-first mobile application** designed for farmers to efficiently manage their farming operations. Built with Flutter, it provides complete farm management capabilities without requiring internet connectivity.

### 🎯 **Key Features**

- 🗓️ **Season Management** - Track farming seasons with crop types and timelines
- 📍 **Plot Organization** - Manage multiple plots with area calculations and soil tracking  
- 📋 **Activity Logging** - Record farming activities with costs and durations
- 🔔 **Smart Reminders** - Local notifications for farming tasks with repeat options
- 💰 **Financial Tracking** - Revenue and expense tracking with profit/loss analysis
- 🌍 **Bilingual Support** - Complete English and Urdu interface with RTL layout
- 💾 **Data Backup** - JSON export/import for data portability and safety
- 📱 **Offline-First** - Works completely offline with local data storage

---

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK 3.19+ 
- Android Studio / VS Code
- Git

### **Installation**

```bash
# Clone the repository
git clone https://github.com/yourusername/farmerpulse.git
cd farmerpulse

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **First Launch**
1. **Create Your First Season** - Start by creating a farming season (e.g., "Spring 2026")
2. **Add Plots** - Define your land plots with area and soil information
3. **Log Activities** - Record farming activities with costs and details
4. **Set Reminders** - Schedule notifications for upcoming tasks
5. **Track Finances** - Add revenue and monitor your profit/loss

---

## 🏗️ **Architecture Overview**

FarmerPulse follows **Clean Architecture** principles with a **Feature-First** approach:

```
lib/
├── core/                    # Shared utilities and services
│   ├── db/                 # Hive database configuration
│   ├── router/             # Navigation (GoRouter)
│   ├── services/           # Notification, backup services
│   └── theme/              # App theming
├── features/               # Feature-based organization
│   ├── season/            # Season management
│   ├── plot/              # Plot management  
│   ├── activity/          # Activity tracking
│   ├── reminder/          # Notifications & reminders
│   ├── analytics/         # Financial analytics
│   └── settings/          # App settings & backup
├── l10n/                  # Localization (English + Urdu)
└── shared/                # Shared UI widgets
```

### **Each Feature Module Structure:**
```
features/[feature]/
├── data/                   # Data layer
│   ├── data_sources/      # Hive operations
│   ├── models/            # Hive models (@HiveType)
│   └── repositories/      # Data abstraction
├── domain/                # Business logic
│   ├── entities/          # Pure Dart objects
│   └── use_cases/         # Business operations
└── presentation/          # UI layer
    ├── providers/         # Riverpod state management
    ├── screens/           # Full-page UI
    └── widgets/           # Reusable components
```

---

## 💾 **Data Management**

### **Local Database (Hive)**
- **Offline-First**: All data stored locally using Hive NoSQL database
- **Fast Performance**: Optimized for mobile with lazy loading
- **Type Safety**: Strongly-typed models with generated adapters
- **Data Integrity**: Relationship validation and orphaned record cleanup

### **Entities & Relationships**
```
Season (1) → Many Plots
Plot (1) → Many Activities  
Plot (1) → Many Reminders
Season (1) → Many Revenues
Activity ← Many Reminders (optional link)
```

### **Backup System**
- **JSON Export**: Human-readable backup format
- **Cross-Platform**: Share backups between devices
- **Data Integrity**: Validation on import/export
- **Version Control**: Backup format versioning for compatibility

---

## 🌍 **Localization & Accessibility**

### **Supported Languages**
- 🇺🇸 **English** - Complete interface
- 🇵🇰 **Urdu (اردو)** - Native translation with RTL support

### **RTL Layout Support**
- Automatic right-to-left layout for Urdu
- Mirrored navigation and form layouts
- Proper text alignment and reading flow
- Cultural appropriateness in farming terminology

### **Accessibility Features**
- Screen reader compatibility
- High contrast color schemes
- Large touch targets (44dp minimum)
- Keyboard navigation support

---

## 📊 **Feature Deep Dive**

### **🗓️ Season Management**
Track your farming cycles with comprehensive season data:
```dart
// Example: Create a new season
final season = Season(
  name: 'Spring 2026',
  startDate: DateTime(2026, 3, 1),
  endDate: DateTime(2026, 6, 30),
  cropType: 'Wheat',
  isActive: true,
);
```

### **📋 Activity Tracking**
Log detailed farming activities with costs:
- **Activity Types**: Land preparation, seeding, watering, spray, harvest, fertilizer, cleaning
- **Cost Tracking**: Record expenses for accurate profit calculation
- **Duration Logging**: Track time spent on activities
- **Photo Attachments**: Visual records of activities (future feature)

### **💰 Financial Analytics**
Comprehensive profit/loss analysis:
- **Revenue Tracking**: Multiple revenue types (harvest sales, livestock, subsidies, etc.)
- **Expense Calculation**: Automatic aggregation from activity costs
- **Profit Margins**: ROI and break-even analysis
- **Comparative Analytics**: Season-to-season performance comparison

### **🔔 Smart Reminders**
Never miss important farming tasks:
- **Local Notifications**: Offline reminder system
- **Repeat Intervals**: Daily, weekly, custom intervals
- **Activity Linking**: Connect reminders to specific activities
- **Urgency Levels**: Prioritize critical tasks

---

## 🛠️ **Development Guide**

### **Technology Stack**
- **Framework**: Flutter 3.19+
- **Language**: Dart 3.3+
- **State Management**: Riverpod 2.4+
- **Local Database**: Hive 4.0+
- **Navigation**: GoRouter 13.0+
- **Notifications**: flutter_local_notifications
- **Localization**: flutter_localizations + intl

### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk
  flutter_riverpod: ^2.4.10
  hive_flutter: ^1.1.0
  go_router: ^13.0.1
  flutter_local_notifications: ^17.1.2
  share_plus: ^7.2.2
  file_picker: ^6.1.1
  intl: ^0.19.0
```

### **Adding New Features**
1. **Create Feature Structure**: Follow the three-layer architecture
2. **Define Entities**: Pure Dart business objects in `domain/entities/`
3. **Create Hive Models**: Add `@HiveType` annotations and register adapters
4. **Implement Use Cases**: Business logic in `domain/use_cases/`
5. **Setup Providers**: Riverpod providers for state management
6. **Build UI**: Screens and widgets in `presentation/`

### **Code Examples**

#### **State Management with Riverpod**
```dart
// Provider definition
final seasonsStreamProvider = StreamProvider<List<Season>>((ref) {
  final repository = ref.read(seasonRepositoryProvider);
  return repository.watchSeasons();
});

// UI consumption
class SeasonListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsStreamProvider);
    
    return seasonsAsync.when(
      data: (seasons) => ListView.builder(
        itemCount: seasons.length,
        itemBuilder: (context, index) => SeasonCard(seasons[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### **Business Logic with Use Cases**
```dart
class CreateSeasonUseCase {
  final SeasonRepository repository;
  
  CreateSeasonUseCase(this.repository);
  
  Future<void> call(Season season) async {
    // Business validation
    if (season.endDate.isBefore(season.startDate)) {
      throw ArgumentError('End date must be after start date');
    }
    
    // Check for overlapping active seasons
    final activeSeasons = await repository.getActiveSeasons();
    if (activeSeasons.any((s) => s.overlaps(season))) {
      throw StateError('Cannot have overlapping active seasons');
    }
    
    // Create season
    await repository.createSeason(season);
  }
}
```

---

## 🧪 **Testing**

### **Testing Strategy**
- **Unit Tests**: Business logic and use cases
- **Widget Tests**: UI components and interactions  
- **Integration Tests**: Complete user workflows
- **Performance Tests**: Large dataset handling

### **Test Coverage**
- ✅ CRUD operations for all entities
- ✅ Calculation accuracy (expenses, profit/loss)
- ✅ Notification scheduling and delivery
- ✅ Localization and RTL layout
- ✅ Backup/restore functionality
- ✅ Error handling and recovery

### **Running Tests**
```bash
# Run unit and widget tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📱 **Platform Support**

### **Minimum Requirements**
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Storage**: 50MB available space
- **RAM**: 2GB minimum, 4GB recommended

### **Supported Features by Platform**
| Feature | Android | iOS |
|---------|---------|-----|
| Local Notifications | ✅ | ✅ |
| File Sharing | ✅ | ✅ |
| RTL Layout | ✅ | ✅ |
| Backup Export | ✅ | ✅ |
| Offline Operation | ✅ | ✅ |

---

## 🔧 **Configuration**

### **Database Setup**
Hive boxes are automatically initialized on first launch:
```dart
// Box initialization in HiveHelper.init()
await Hive.openBox<SeasonModel>('seasons');
await Hive.openBox<PlotModel>('plots');
await Hive.openBox<ActivityModel>('activities');
await Hive.openBox<ReminderModel>('reminders');
await Hive.openBox<RevenueModel>('revenues');
```

### **Notification Permissions**
The app requests notification permissions on first launch:
- **Android**: Configured via `android/app/src/main/AndroidManifest.xml`
- **iOS**: Automatic permission request dialog

---

## 📋 **User Guide**

### **Getting Started**
1. **First Season**: Create your first farming season with crop type and dates
2. **Plot Setup**: Add plots with area measurements and soil information
3. **Daily Logging**: Record activities as you perform farming tasks
4. **Financial Tracking**: Add revenue entries and monitor expenses automatically
5. **Backup Data**: Regularly export your data for safety

### **Best Practices**
- 🎯 **Consistent Logging**: Record activities daily for accurate tracking
- 💰 **Cost Tracking**: Always include costs for activities to get accurate profit calculations  
- 🔔 **Set Reminders**: Use notifications to stay on top of farming schedules
- 💾 **Regular Backups**: Export data weekly to prevent loss
- 🌍 **Language Preference**: Switch languages in settings for comfortable use

### **Troubleshooting**
- **App Crashes**: Try restarting the app; persistent issues may require data backup and reinstall
- **Missing Data**: Check if data was accidentally deleted; restore from backup if available
- **Notifications Not Working**: Verify notification permissions in device settings
- **Performance Issues**: Clear old data or restart the app to free memory

---

## 🤝 **Contributing**

We welcome contributions! Please see our contributing guidelines:

### **How to Contribute**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Setup**
```bash
# Clone and setup
git clone https://github.com/yourusername/farmerpulse.git
cd farmerpulse
flutter pub get

# Run tests before contributing
flutter test
flutter analyze

# Check formatting
dart format --set-exit-if-changed .
```

### **Code Standards**
- Follow Dart/Flutter style guidelines
- Maintain test coverage above 80%
- Update documentation for new features
- Use meaningful commit messages

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 **Contact & Support**

- **Issues**: [GitHub Issues](https://github.com/yourusername/farmerpulse/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/farmerpulse/discussions)
- **Email**: support@farmerpulse.app

---

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Hive developers for the excellent local database
- Riverpod community for state management patterns
- Farmers worldwide who inspired this project

---

<div align="center">

**Built with ❤️ for farmers worldwide**

[⬆ Back to Top](#-farmerpulse---smart-farm-management-app)

</div>