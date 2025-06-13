#!/bin/bash

# 🚀 Space Dodger - Build and Release Script
# This script automates the process of building and preparing APK releases

set -e  # Exit on any error

echo "🚀 Space Dodger - Build and Release Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    print_status "Checking Flutter installation..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    flutter_version=$(flutter --version | head -n 1)
    print_success "Flutter found: $flutter_version"
}

# Clean and get dependencies
setup_project() {
    print_status "Setting up project..."
    
    print_status "Cleaning project..."
    flutter clean
    
    print_status "Getting dependencies..."
    flutter pub get
    
    print_success "Project setup complete"
}

# Build APK
build_apk() {
    local version=$1
    local build_type=${2:-release}
    
    print_status "Building $build_type APK for version $version..."
    
    # Create releases directory if it doesn't exist
    mkdir -p releases
    
    # Build APK
    if [ "$build_type" = "release" ]; then
        flutter build apk --release
        cp build/app/outputs/flutter-apk/app-release.apk "releases/SpaceDodge-v$version.apk"
        print_success "Release APK built: releases/SpaceDodge-v$version.apk"
    else
        flutter build apk --debug
        cp build/app/outputs/flutter-apk/app-debug.apk "releases/SpaceDodge-v$version-debug.apk"
        print_success "Debug APK built: releases/SpaceDodge-v$version-debug.apk"
    fi
}

# Build App Bundle (for Play Store)
build_app_bundle() {
    local version=$1
    
    print_status "Building App Bundle for version $version..."
    
    # Create releases directory if it doesn't exist
    mkdir -p releases
    
    # Build App Bundle
    flutter build appbundle --release
    cp build/app/outputs/bundle/release/app-release.aab "releases/SpaceDodge-v$version.aab"
    print_success "App Bundle built: releases/SpaceDodge-v$version.aab"
}

# Generate app icons
generate_icons() {
    print_status "Generating app icons..."
    
    if flutter pub run flutter_launcher_icons:main; then
        print_success "App icons generated successfully"
    else
        print_error "Failed to generate app icons"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    if flutter test; then
        print_success "All tests passed"
    else
        print_error "Tests failed"
        exit 1
    fi
}

# Analyze code
analyze_code() {
    print_status "Analyzing code..."
    
    if flutter analyze; then
        print_success "Code analysis passed"
    else
        print_warning "Code analysis found issues"
    fi
}

# Get APK file size
get_apk_size() {
    local apk_path=$1
    if [ -f "$apk_path" ]; then
        local size=$(du -h "$apk_path" | cut -f1)
        print_status "APK size: $size"
    fi
}

# Main build process
main() {
    local version=${1:-1.0.0}
    local build_type=${2:-release}
    local skip_tests=${3:-false}
    
    echo ""
    print_status "Starting build process for version $version ($build_type)"
    echo ""
    
    # Check Flutter installation
    check_flutter
    
    # Setup project
    setup_project
    
    # Generate icons
    generate_icons
    
    # Run tests (unless skipped)
    if [ "$skip_tests" != "true" ]; then
        run_tests
    else
        print_warning "Skipping tests"
    fi
    
    # Analyze code
    analyze_code
    
    # Build APK
    build_apk "$version" "$build_type"
    
    # Build App Bundle for release builds
    if [ "$build_type" = "release" ]; then
        build_app_bundle "$version"
    fi
    
    # Get file sizes
    if [ "$build_type" = "release" ]; then
        get_apk_size "releases/SpaceDodge-v$version.apk"
        get_apk_size "releases/SpaceDodge-v$version.aab"
    else
        get_apk_size "releases/SpaceDodge-v$version-debug.apk"
    fi
    
    echo ""
    print_success "Build process completed successfully!"
    echo ""
    print_status "Generated files:"
    ls -la releases/
    echo ""
    print_status "Next steps:"
    echo "1. Test the APK on a device"
    echo "2. Update RELEASE.md with any changes"
    echo "3. Create a GitHub release with the APK"
    echo "4. Upload to Google Play Console (if using App Bundle)"
}

# Show usage
show_usage() {
    echo "Usage: $0 [version] [build_type] [skip_tests]"
    echo ""
    echo "Arguments:"
    echo "  version     Version number (default: 1.0.0)"
    echo "  build_type  Build type: release or debug (default: release)"
    echo "  skip_tests  Skip tests: true or false (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build release v1.0.0 with tests"
    echo "  $0 1.1.0             # Build release v1.1.0 with tests"
    echo "  $0 1.0.0 debug       # Build debug v1.0.0 with tests"
    echo "  $0 1.0.0 release true # Build release v1.0.0 without tests"
    echo ""
}

# Check if help is requested
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

# Run main function with arguments
main "$@" 