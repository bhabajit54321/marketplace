#!/bin/bash
set -e

echo "🚀 Setting up Flutter development environment..."

# Update system
apt update && apt upgrade -y

# Install Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
apt update
apt install google-chrome-stable -y

# Install required packages
apt install -y \
  git \
  curl \
  unzip \
  wget \
  ninja-build \
  libgtk-3-dev \
  mesa-utils \
  pkg-config \
  clang \
  cmake \
  libblkid-dev \
  liblzma-dev

# Install Flutter
echo "📱 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
export PATH="/opt/flutter/bin:$PATH"
echo 'export PATH="/opt/flutter/bin:$PATH"' >> /etc/bash.bashrc

# Setup Android SDK
echo "🤖 Setting up Android SDK..."
mkdir -p /opt/android-sdk
cd /opt/android-sdk
wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip -q commandlinetools-linux-9477386_latest.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
rm commandlinetools-linux-9477386_latest.zip

# Set Android environment variables
export ANDROID_HOME=/opt/android-sdk
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

echo 'export ANDROID_HOME=/opt/android-sdk' >> /etc/bash.bashrc
echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"' >> /etc/bash.bashrc
echo 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' >> /etc/bash.bashrc

# Install Android SDK components
echo "📦 Installing Android SDK components..."
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-33" "platforms;android-34" "build-tools;33.0.2" "build-tools;34.0.0"

# Configure Flutter
echo "⚙️ Configuring Flutter..."
flutter config --android-sdk /opt/android-sdk
flutter config --enable-web
flutter config --enable-linux-desktop

# Pre-cache Flutter artifacts
echo "🔄 Pre-caching Flutter artifacts..."
flutter precache

# Run Flutter doctor
echo "🏥 Running Flutter doctor..."
flutter doctor

echo "✅ Flutter development environment setup complete!"
echo "🎯 You can now run: flutter create my_app && cd my_app && flutter build apk"
