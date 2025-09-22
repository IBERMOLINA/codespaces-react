#!/bin/bash

# Production optimization script for Da-Kraken
echo "🚀 Optimizing Da-Kraken for production deployment..."

# Create production directory
mkdir -p dist
mkdir -p dist/assets
mkdir -p dist/scripts
mkdir -p dist/styles

# Copy and optimize HTML
echo "📝 Optimizing HTML..."
sed -e 's/    /\t/g' -e '/^\s*$/d' index.html > dist/index.html

# Copy and optimize CSS (remove comments and extra spaces)
echo "🎨 Optimizing CSS..."
sed -e '/\/\*/,/\*\//d' -e '/^\s*$/d' -e 's/  */ /g' styles/main.css > dist/styles/main.css

# Copy and optimize JavaScript (remove console logs for production)
echo "⚡ Optimizing JavaScript..."
for js_file in scripts/*.js; do
  filename=$(basename "$js_file")
  # Remove console.log statements but keep console.warn and console.error
  sed -e '/console\.log/d' -e '/^\s*$/d' "$js_file" > "dist/scripts/$filename"
done

# Copy assets
echo "📁 Copying assets..."
cp -r assets/* dist/assets/ 2>/dev/null || echo "No additional assets to copy"
cp manifest.json dist/
cp sw.js dist/

# Create offline.html for service worker fallback
cat > dist/offline.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Da-Kraken - Offline</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; 
            margin: 0; 
            background: #f8fafc; 
            text-align: center;
        }
        .offline { max-width: 400px; }
        .kraken { font-size: 4rem; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div class="offline">
        <div class="kraken">🐙</div>
        <h1>Da-Kraken is Offline</h1>
        <p>You're currently offline. Please check your internet connection and try again.</p>
        <button onclick="location.reload()">Try Again</button>
    </div>
</body>
</html>
EOF

# Calculate sizes
echo "📊 Build summary:"
echo "Original size: $(du -sh . | cut -f1)"
echo "Optimized size: $(du -sh dist | cut -f1)"

echo "✅ Production build complete in 'dist' directory!"
echo "🚀 Ready for deployment!"