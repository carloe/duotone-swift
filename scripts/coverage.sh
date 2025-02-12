#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
BUILD_DIR=".build"
TEST_BINARY="$BUILD_DIR/debug/duotonePackageTests.xctest/Contents/MacOS/duotonePackageTests"
PROFDATA="$BUILD_DIR/debug/codecov/default.profdata"
IGNORE_REGEX=".build|Tests"

# Help message
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Generate test coverage reports for the duotone project"
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -u, --uncovered       Show uncovered lines"
    echo "  -d, --detailed        Show detailed coverage report"
    echo "  -c, --clean           Clean build directory before running"
    echo "  -x, --html            Generate HTML coverage report"
    exit 1
}

# Error handling
error() {
    echo "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 is required but not installed"
    fi
}

# Clean build directory
clean_build() {
    echo "${BLUE}Cleaning build directory...${NC}"
    rm -rf "$BUILD_DIR"
}

# Run tests with coverage
run_tests() {
    echo "${BLUE}Running tests with coverage...${NC}"
    if ! swift test --enable-code-coverage; then
        error "Tests failed"
    fi
}

# Generate basic coverage report
generate_report() {
    echo "${BLUE}Generating coverage report...${NC}"
    if [ ! -f "$TEST_BINARY" ]; then
        error "Test binary not found. Did tests run successfully?"
    fi
    
    if [ ! -f "$PROFDATA" ]; then
        error "Coverage data not found. Did tests run successfully?"
    fi
    
    xcrun llvm-cov report \
        "$TEST_BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="$IGNORE_REGEX" \
        -use-color
}

# Show uncovered lines
show_uncovered() {
    echo "${BLUE}Showing uncovered lines...${NC}"
    xcrun llvm-cov show \
        "$TEST_BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="$IGNORE_REGEX" \
        -use-color \
        -show-regions \
        -show-line-counts-or-regions
}

# Generate detailed report
generate_detailed() {
    echo "${BLUE}Generating detailed coverage report...${NC}"
    xcrun llvm-cov show \
        "$TEST_BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="$IGNORE_REGEX" \
        -use-color \
        -show-branches=count \
        -show-expansions \
        -show-regions
}

# Generate HTML report
generate_html() {
    echo "${BLUE}Generating HTML coverage report...${NC}"
    xcrun llvm-cov show \
        "$TEST_BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="$IGNORE_REGEX" \
        -use-color \
        -format=html \
        -output-dir="$BUILD_DIR/coverage" \
        -show-branches=count
    
    echo "${GREEN}HTML report generated at $BUILD_DIR/coverage/index.html${NC}"
}

# Check required commands
check_command swift
check_command xcrun

# Parse arguments
SHOW_UNCOVERED=0
SHOW_DETAILED=0
DO_CLEAN=0
GENERATE_HTML=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -u|--uncovered)
            SHOW_UNCOVERED=1
            shift
            ;;
        -d|--detailed)
            SHOW_DETAILED=1
            shift
            ;;
        -c|--clean)
            DO_CLEAN=1
            shift
            ;;
        -x|--html)
            GENERATE_HTML=1
            shift
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Main execution
if [ "$DO_CLEAN" -eq 1 ]; then
    clean_build
fi

run_tests
generate_report

if [ "$SHOW_UNCOVERED" -eq 1 ]; then
    show_uncovered
fi

if [ "$SHOW_DETAILED" -eq 1 ]; then
    generate_detailed
fi

if [ "$GENERATE_HTML" -eq 1 ]; then
    generate_html
fi

echo "${GREEN}Coverage analysis complete!${NC}" 