#!/bin/bash
set -o errexit

echo "🚀 Starting Render deployment build..."

# Create necessary temporary directories with proper permissions
echo "📁 Creating temporary asset directories..."
mkdir -p /tmp/assets/builds
chmod 755 /tmp/assets/builds

# Install dependencies
echo "📦 Installing dependencies..."
npm install --legacy-peer-deps --production --no-optional --verbose --loglevel=error

# Build TailwindCSS to temporary directory
echo "🎨 Building TailwindCSS..."
npm run build:css

# Copy the generated CSS to the Rails assets directory
echo "📋 Copying CSS to Rails assets directory..."
mkdir -p ./app/assets/builds
cp /tmp/assets/builds/tailwind.css ./app/assets/builds/tailwind.css

# Run database migrations
echo "🗄️  Running database migrations..."
bundle exec rails db:migrate

# Precompile Rails assets
echo "⚡ Precompiling Rails assets..."
bundle exec rails assets:precompile

echo "✅ Build completed successfully!"