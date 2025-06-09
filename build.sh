#!/bin/bash
# Build script for ZIP Extractor Tool

echo "🛠️  Building ZIP Extractor Tool..."
echo "=================================="

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart SDK not found. Please install Dart first:"
    echo "   https://dart.dev/get-dart"
    exit 1
fi

echo "✅ Dart SDK found: $(dart --version)"

# Install dependencies
echo "📦 Installing dependencies..."
dart pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create build directory
mkdir -p build

# Detect platform and compile accordingly
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    echo "🖥️  Building for Windows..."
    dart compile exe zip_extractor.dart -o build/zip_extractor.exe
    EXECUTABLE="build/zip_extractor.exe"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "🍎 Building for macOS..."
    dart compile exe zip_extractor.dart -o build/zip_extractor_mac
    EXECUTABLE="build/zip_extractor_mac"
else
    # Linux
    echo "🐧 Building for Linux..."
    dart compile exe zip_extractor.dart -o build/zip_extractor_linux
    EXECUTABLE="build/zip_extractor_linux"
fi

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📁 Executable created: $EXECUTABLE"
    
    # Show file size
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "📊 File size: $(powershell -command "(Get-Item '$EXECUTABLE').length / 1MB | ForEach-Object { '{0:N2}' -f $_ }")MB"
    else
        echo "📊 File size: $(du -h "$EXECUTABLE" | cut -f1)"
    fi
    
    echo ""
    echo "🚀 To run the tool:"
    echo "   ./$EXECUTABLE"
    echo ""
    echo "💡 You can now distribute the executable file to other users!"
    echo "   They don't need Dart installed to run it."
else
    echo "❌ Build failed!"
    exit 1
fi