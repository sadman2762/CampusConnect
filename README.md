
<!-- Badges -->
[![Build Status](https://img.shields.io/github/actions/workflow/status/your-repo/CampusConnect/flutter-ci.yml?branch=main)](https://github.com/your-repo/CampusConnect/actions)  
[![Flutter](https://img.shields.io/badge/Flutter-3.10.0-blue)](https://flutter.dev/)  
[![Dart](https://img.shields.io/badge/Dart-2.18.0-blue)](https://dart.dev/)  
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE.txt)

# CampusConnect

## 🚀 Messaging & Learning App!

CampusConnect is a powerful and feature-rich messaging and learning platform, designed to provide a seamless communication experience while integrating AI-powered study tools. Built using a modern tech stack, it ensures high performance, security, and scalability.

---

## 📋 Table of Contents
- [CampusConnect](#campusconnect)
  - [🚀 Messaging \& Learning App!](#-messaging--learning-app)
  - [📋 Table of Contents](#-table-of-contents)
  - [🛠 Prerequisites](#-prerequisites)
  - [🚀 Installation \& Setup](#-installation--setup)
  - [📂 Project Structure](#-project-structure)
  - [💻 Usage](#-usage)
    - [Run the Flutter App](#run-the-flutter-app)
    - [Start the Backend Server](#start-the-backend-server)
  - [🔑 Environment Variables](#-environment-variables)
  - [📸 Screenshots / Demo](#-screenshots--demo)
  - [🤝 Contributing](#-contributing)
  - [📌 Contact \& Support](#-contact--support)
  - [🐝 License](#-license)

---

## 🛠 Prerequisites
<!-- Added Prerequisites section -->
- **Flutter SDK** ≥ 3.10.0  
- **Dart SDK** ≥ 2.18.0  
- **Firebase CLI** ≥ 11.0.0  
- **Node.js & npm** (for some tooling)  

Make sure you have these installed and on your `$PATH` before proceeding.

---

## 🚀 Installation & Setup
<!-- Updated Installation commands for Flutter & Dart -->
1. **Clone the repository**  
   ```bash
   git clone https://github.com/your-repo/CampusConnect.git
   cd CampusConnect
   ```
2. **Frontend Setup**

   ```bash
   cd Frontend
   flutter pub get                # Install Flutter dependencies
   ```

3. **Backend Setup**

   ```bash
   cd ../Backend/Backend_Development
   dart pub get                   # Install Dart backend dependencies
   ```

4. **Configure Firebase**

   * Place `google-services.json` into `Frontend/android/app/`
   * Place `GoogleService-Info.plist` into `Frontend/ios/Runner/`
   * Initialize Firebase in backend (if needed):

     ```bash
     firebase login
     firebase use --add
     ```

---

## 📂 Project Structure

<!-- Added Project Structure explanations -->

```
CampusConnect/
│
├── Frontend/                  # Flutter mobile & web client
│   ├── Figma_Design/          # UI/UX mockups
│   └── Frontend_Development/  # App code (Redux, screens, widgets)
│
├── Backend/                   # Dart server and API
│   ├── Backend_Development/   # Dart server source
│   └── Database/              # Firebase data modeling & rules
│
└── AI/                        # AI modules
    ├── Summarization_AI/      # Text summarization models
    └── Data_Extraction_AI/    # Information extraction services
```

---

## 💻 Usage

<!-- Added Usage instructions -->

### Run the Flutter App

```bash
cd Frontend/Frontend_Development
flutter run         # Launch on connected device or emulator
```

### Start the Backend Server

```bash
cd Backend/Backend_Development
dart run bin/server.dart
```

---

## 🔑 Environment Variables

<!-- Added Environment Variables section -->

Create a `.env` file in both frontend and backend root directories with:

```env
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
JWT_SECRET=your_jwt_secret
```

---

## 📸 Screenshots / Demo

<!-- Added placeholder for screenshots -->

![Chat Screen](docs/screenshots/chat_screen.png)
![Study Section](docs/screenshots/study_section.png)
*More screenshots in `docs/screenshots/`*

---

## 🤝 Contributing

<!-- Enhanced Contributing section -->

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m "Add YourFeature"`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a Pull Request

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

---

## 📌 Contact & Support

<!-- Updated Contact section with issues link -->

For any queries or issues, please open an issue on GitHub:
[https://github.com/your-repo/CampusConnect/issues](https://github.com/your-repo/CampusConnect/issues)
Or reach out at [4tyengine@gmail.com](mailto:4tyengine@gmail.com).

---

## 🐝 License

<!-- License badge already added at top -->

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE.txt) file for details.

```

