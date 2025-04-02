# Video Merger

A **Video Recording and Merging App** built with Flutter, designed to help users record, manage, and merge videos. The app features a clean and intuitive UI, video recording capabilities, thumbnail generation, local storage with SQFlite, and a custom video player with playback controls.

## Overview

The Sky Mute App is a mobile application that allows users to record videos using their device camera, view recorded videos in a grid layout, select multiple videos for merging, and play videos with a custom video player. The app uses SQFlite for local database storage to keep track of video metadata and thumbnails, creating an organized gallery experience.

The app is designed with a focus on usability, featuring a clean dark-themed UI, selection mode for merging videos, and a full-featured video player with playback controls.

## Features

- **Video Recording**:
    - Record videos using the device camera.
    - Automatically generate thumbnails for recorded videos.
    - Save videos to the app's private storage.

- **Video Management**:
    - Display recorded videos in a grid layout with thumbnails.
    - Select multiple videos for merging with long-press to enter selection mode.
    - Delete videos with swipe gestures.

- **Video Merging**:
    - Select multiple videos to combine into a single video file.
    - Visual indication of selected videos with blue borders.
    - Progress indicator during the merging process.

- **Local Storage**:
    - Video metadata and thumbnails stored locally using SQFlite.
    - Separate tables for recorded and merged videos.
    - Data persists across app restarts.

- **Custom Video Player**:
    - Full-featured video player with playback controls.
    - Seek forward/backward functionality.
    - Video progress bar with drag-to-seek capability.
    - Time indicators showing current position and video duration.
    - Hide/show controls with tap gesture.

- **Responsive UI**:
    - Clean and intuitive dark-themed UI.
    - Consistent design elements throughout the app.
    - Responsive grid layouts that adapt to different screen sizes.

## Installation

### Prerequisites
- **Flutter**: Version 3.0.0 or higher
- **Dart**: Version 2.17.0 or higher
- **Android Studio** or **VS Code** with Flutter plugins
- **Android Device/Emulator** or **iOS Simulator**

### Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/[YourUsername]/sky-mute.git
cd sky-mute
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Run the App
```bash
flutter run
```

#### 4. Grant Permissions
- When recording videos, the app will request camera and storage permissions.

## Technologies Used
- **Flutter**: Framework for building the cross-platform app.
- **SQFlite**: Local database for storing video metadata and thumbnail paths.
- **Image Picker**: For accessing the device camera to record videos.
- **Video Player**: For playing recorded and merged videos.
- **FFmpeg Kit Flutter**: For merging multiple videos into a single file.
- **Video Compress**: For generating video thumbnails.
- **Path Provider**: For accessing file directories.
- **Permission Handler**: For requesting camera and storage permissions.

## Project Structure
```plaintext
sky-mute/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Main source code
│   ├── helpers/              # Helper classes and services
│   │   ├── database_helper.dart  # SQFlite database helper
│   │   └── video_merger.dart     # Video merging functionality
│   ├── screens/              # UI screens
│   │   ├── camera_screen.dart    # Camera and recorded videos
│   │   ├── gallery_screen.dart   # Merged videos gallery
│   │   ├── home_screen.dart      # Main navigation screen
│   │   └── video_player_screen.dart # Custom video player
│   └── main.dart             # App entry point
├── pubspec.yaml              # Dependencies and metadata
```

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  image_picker: ^1.1.2
  path_provider: ^2.1.5
  path: ^1.9.0
  sqflite: ^2.4.1
  video_player: ^2.9.5
  ffmpeg_kit_flutter: ^6.0.3
  video_compress: ^3.1.4
  permission_handler: ^11.4.0
```
