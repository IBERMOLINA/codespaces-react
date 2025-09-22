#!/bin/bash

# Da-Kraken Deployment Verification Script
echo "🐙 Da-Kraken Deployment Verification"
echo "===================================="

# Check if we're in the right directory
if [[ ! -f "index.html" ]]; then
  echo "❌ Error: Run this script from the Da-Kraken root directory"
  exit 1
fi

echo "📁 Checking file structure..."

# Check core files
files_to_check=(
  "index.html"
  "manifest.json"
  "sw.js"
  "styles/main.css"
  "scripts/app.js"
  "scripts/utils.js"
  "scripts/theme.js"
  "scripts/tools.js"
)

missing_files=0
for file in "${files_to_check[@]}"; do
  if [[ -f "$file" ]]; then
    echo "✅ $file"
  else
    echo "❌ Missing: $file"
    missing_files=$((missing_files + 1))
  fi
done

# Check production build
echo ""
echo "🚀 Checking production build..."
if [[ -d "dist" ]]; then
  echo "✅ dist directory exists"
  dist_files=$(find dist -type f | wc -l)
  echo "✅ $dist_files files in production build"
else
  echo "❌ Production build not found - run ./build.sh"
  missing_files=$((missing_files + 1))
fi

# Test JSON files
echo ""
echo "📱 Validating configuration files..."
if command -v node >/dev/null 2>&1; then
  node -e "
    try {
      const manifest = JSON.parse(require('fs').readFileSync('manifest.json', 'utf8'));
      console.log('✅ manifest.json is valid JSON');
      console.log('✅ PWA name:', manifest.name);
    } catch (e) {
      console.log('❌ manifest.json error:', e.message);
      process.exit(1);
    }
  "
else
  echo "ℹ️  Node.js not available - skipping JSON validation"
fi

# Test web server capability
echo ""
echo "🌐 Testing deployment options..."

# Check for Python
if command -v python3 >/dev/null 2>&1; then
  echo "✅ Python 3 available for local server"
  echo "   Run: python3 -m http.server 8000"
else
  echo "⚠️  Python 3 not available"
fi

# Check for Node.js
if command -v node >/dev/null 2>&1; then
  echo "✅ Node.js available for development"
  echo "   Run: npx http-server"
else
  echo "⚠️  Node.js not available"
fi

# Check for PHP
if command -v php >/dev/null 2>&1; then
  echo "✅ PHP available for local server"
  echo "   Run: php -S localhost:8000"
else
  echo "⚠️  PHP not available"
fi

echo ""
echo "📊 Summary:"
echo "==========="
if [[ $missing_files -eq 0 ]]; then
  echo "🎉 All checks passed! Da-Kraken is ready for deployment."
  echo ""
  echo "🚀 Quick start:"
  echo "   cd dist && python3 -m http.server 8000"
  echo "   Then open: http://localhost:8000"
  echo ""
  echo "📱 For PWA installation, look for 'Install' button in your browser."
else
  echo "❌ $missing_files issues found. Please fix before deploying."
  exit 1
fi