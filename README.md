# 💰 Pennywize

> *Your money, finally wize.*

A smart personal finance tracker built with Flutter — featuring AI-powered receipt scanning, beautiful spending insights, and a home screen widget to keep your budget top of mind.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🤖 **AI Receipt Scanner** | Snap a receipt and let AI auto-fill the expense for you |
| 📊 **Spending Dashboard** | Visual breakdown of spending by category with interactive charts |
| 📄 **PDF Export** | Export monthly expense reports as PDF |
| 🏠 **Home Widget** | Glanceable spending summary on your home screen |
| 🗂️ **Category Tracking** | Organize expenses across customizable categories |
| 🔥 **Firebase Sync** | Auth + Firestore cloud backup |
| 🌙 **Dark-first UI** | Clean dark theme with smooth animations |

---

## 🛠️ Tech Stack

```
Flutter 3.24+  ·  Dart 3.5+
```

| Layer | Tech |
|---|---|
| State Management | `flutter_bloc` + `equatable` |
| Dependency Injection | `get_it` |
| Local Database | `sqflite` |
| Cloud | Firebase Auth + Firestore |
| Charts | `fl_chart` |
| AI Integration | OpenCode.ai (DeepSeek vision model) |
| PDF | `pdf` + `printing` |
| Home Widget | `home_widget` |
| Fonts | Google Fonts |

---

## 🏗️ Architecture

Feature-first Clean Architecture with BLoC pattern:

```
lib/
├── core/               # Shared theme, constants, DI, widgets
│   ├── constants/
│   ├── di/             # get_it injector
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── dashboard/      # Spending overview + PDF export
│   ├── expense/        # CRUD expenses, home page
│   ├── scanner/        # AI receipt scanning
│   └── settings/       # App settings + widget customization
└── services/           # Cross-cutting services (home widget)
```

Each feature follows:
```
feature/
├── data/
│   ├── datasources/    # Local DB / API calls
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Pure domain objects
│   └── repositories/   # Abstract contracts
└── presentation/
    ├── bloc/           # BLoC state management
    ├── pages/
    └── widgets/
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter `>=3.24.0`
- Dart `>=3.5.0`
- Firebase project (for auth + Firestore)

### Setup

```bash
# Clone
git clone https://github.com/arifana-dev/pennywize.git
cd pennywize

# Install dependencies
flutter pub get

# Run
flutter run
```

### Environment Variables

```bash
cp .env.json.example .env.json
# Edit .env.json and fill in your API key
```

Then run with:
```bash
flutter run --dart-define-from-file=.env.json
```

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Google Sign-In) and **Firestore**
3. Run `flutterfire configure` and replace `lib/firebase_options.dart`

---

## 📸 Screenshots

> Coming soon

---

## 📄 License

MIT © [arifana-dev](https://github.com/arifana-dev)
