#!/bin/bash
# =============================================================================
# Infrastructure Setup Script
# =============================================================================

set -e

echo "🚀 Setting up Home Lab Docker Infrastructure..."

# Create .env from template if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env from template..."
    cp .env.template .env
    echo "⚠️  Edit .env with your actual values before deploying!"
else
    echo "✅ .env already exists"
fi

# Create required directories
echo "📁 Creating required directories..."
mkdir -p backups .secrets data logs tmp

# Set proper permissions
echo "🔐 Setting proper permissions..."
chmod 700 .secrets
chmod 755 backups data logs tmp

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Edit .env with your Vault token and backup passphrase"
echo "  2. Run 'make init-vault' to initialize Vault (first time)"
echo "  3. Run 'make deploy' to start infrastructure"