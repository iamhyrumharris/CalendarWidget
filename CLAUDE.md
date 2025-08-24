# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application project for a calendar widget, currently in initial development stage with the default Flutter counter app template.

## Essential Commands

### Development
- `flutter run` - Run the app on connected device/emulator
- `flutter run -d chrome` - Run the app in Chrome (web)
- `flutter run -d macos` - Run the app on macOS
- `flutter run -d ios` - Run the app on iOS simulator

### Build
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build for web deployment
- `flutter build macos` - Build macOS desktop app

### Testing & Quality
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter analyze` - Run static analysis and linting

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

## Architecture

The project follows standard Flutter application structure:

- **lib/main.dart**: Entry point containing MyApp (root widget) and MyHomePage (stateful widget with counter functionality)
- **Platform-specific code**: Located in android/, ios/, macos/, linux/, windows/, and web/ directories
- **Tests**: Widget tests in test/ directory

## Key Configuration

- **Flutter SDK**: ^3.8.1 (specified in pubspec.yaml)
- **Linting**: Uses flutter_lints package with rules defined in analysis_options.yaml
- **Material Design**: Enabled with uses-material-design: true