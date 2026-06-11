#!/bin/bash
# Clone the Flutter stable branch with depth 1 for speed
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Disable analytics for cleaner logs
flutter config --no-analytics

# Enable Web support
flutter config --enable-web

# Build Web in release mode
echo "Building Flutter Web..."
flutter build web --release
