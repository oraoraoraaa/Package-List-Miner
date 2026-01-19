#!/bin/bash

# Script to publish Maven-Miner to Maven Central
# Usage: ./maven_publish.sh [snapshot|staging|release]
# - snapshot: Deploy snapshot version (requires version ending with -SNAPSHOT)
# - staging: Deploy to staging repository (manual release required)
# - release: Deploy and auto-release to Maven Central
# Default: staging

set -e  # Exit on error

PROJECT_DIR="Maven-Miner"
MODE="${1:-staging}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Maven Central Publishing Script"
echo "========================================="
echo ""

# Check if Maven-Miner directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: $PROJECT_DIR directory not found${NC}"
    exit 1
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}Error: Maven is not installed${NC}"
    echo "Please install Maven first:"
    echo "  macOS: brew install maven"
    echo "  Linux: sudo apt-get install maven"
    exit 1
fi

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}Error: GPG is not installed${NC}"
    echo "Please install GPG first:"
    echo "  macOS: brew install gnupg"
    echo "  Linux: sudo apt-get install gnupg"
    exit 1
fi

# Check Maven settings
SETTINGS_FILE="$HOME/.m2/settings.xml"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Warning: Maven settings file not found at $SETTINGS_FILE${NC}"
    echo "You may need to configure it with Sonatype credentials and GPG settings."
    echo "See .doc/Maven_Central_Publishing_Guide.md for details."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Get current version from pom.xml
VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo -e "${GREEN}Current version: $VERSION${NC}"
echo ""

# Validate mode and version
if [ "$MODE" = "snapshot" ]; then
    if [[ ! "$VERSION" =~ -SNAPSHOT$ ]]; then
        echo -e "${RED}Error: For snapshot deployment, version must end with -SNAPSHOT${NC}"
        echo "Current version: $VERSION"
        echo "Please update the version in pom.xml"
        exit 1
    fi
    echo "Mode: Snapshot Deployment"
    echo "Target: https://s01.oss.sonatype.org/content/repositories/snapshots"
    
elif [ "$MODE" = "staging" ]; then
    if [[ "$VERSION" =~ -SNAPSHOT$ ]]; then
        echo -e "${RED}Error: Staging deployment requires a non-SNAPSHOT version${NC}"
        echo "Current version: $VERSION"
        echo "Please update the version in pom.xml"
        exit 1
    fi
    echo "Mode: Staging Deployment (manual release required)"
    echo "After deployment, you need to:"
    echo "  1. Login to https://s01.oss.sonatype.org/"
    echo "  2. Go to 'Staging Repositories'"
    echo "  3. Find your repository and click 'Close'"
    echo "  4. After validation, click 'Release'"
    
elif [ "$MODE" = "release" ]; then
    if [[ "$VERSION" =~ -SNAPSHOT$ ]]; then
        echo -e "${RED}Error: Release deployment requires a non-SNAPSHOT version${NC}"
        echo "Current version: $VERSION"
        echo "Please update the version in pom.xml"
        exit 1
    fi
    echo "Mode: Automatic Release to Maven Central"
    echo "The artifact will be automatically released after validation"
    
else
    echo -e "${RED}Error: Invalid mode '$MODE'${NC}"
    echo "Usage: $0 [snapshot|staging|release]"
    exit 1
fi

echo ""
echo "========================================="
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
echo "========================================="
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Clean previous builds
echo ""
echo "Cleaning previous builds..."
mvn clean

# Run tests
echo ""
echo "Running tests..."
mvn test

# Deploy based on mode
echo ""
echo "========================================="
echo "Starting deployment..."
echo "========================================="

if [ "$MODE" = "snapshot" ]; then
    # Deploy snapshot
    mvn deploy
    
elif [ "$MODE" = "staging" ]; then
    # Deploy to staging (manual release)
    mvn deploy
    
elif [ "$MODE" = "release" ]; then
    # Deploy with auto-release
    # Temporarily modify pom.xml to enable auto-release
    if command -v gsed &> /dev/null; then
        SED_CMD="gsed"
    else
        SED_CMD="sed"
    fi
    
    # Create a backup
    cp pom.xml pom.xml.backup
    
    # Enable auto-release
    $SED_CMD -i 's/<autoReleaseAfterClose>false<\/autoReleaseAfterClose>/<autoReleaseAfterClose>true<\/autoReleaseAfterClose>/g' pom.xml
    
    # Deploy
    mvn deploy
    
    # Restore backup
    mv pom.xml.backup pom.xml
fi

# Check deployment status
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo "========================================="
    echo ""
    
    if [ "$MODE" = "snapshot" ]; then
        echo "Snapshot deployed to:"
        echo "  https://s01.oss.sonatype.org/content/repositories/snapshots/"
        echo ""
        echo "You can use it in your pom.xml:"
        echo "  <dependency>"
        echo "    <groupId>com.higolab</groupId>"
        echo "    <artifactId>maven-miner</artifactId>"
        echo "    <version>$VERSION</version>"
        echo "  </dependency>"
        
    elif [ "$MODE" = "staging" ]; then
        echo "Next steps:"
        echo "  1. Login to https://s01.oss.sonatype.org/"
        echo "  2. Click 'Staging Repositories' in the left sidebar"
        echo "  3. Find your repository (usually at the bottom)"
        echo "  4. Select it and click 'Close' button"
        echo "  5. Wait for validation to complete"
        echo "  6. Click 'Release' button to publish to Maven Central"
        echo ""
        echo "Maven Central sync takes 10-30 minutes, full propagation ~2 hours"
        
    elif [ "$MODE" = "release" ]; then
        echo "Artifact is being automatically released to Maven Central"
        echo ""
        echo "It will be available soon at:"
        echo "  https://repo1.maven.org/maven2/com/higolab/maven-miner/$VERSION/"
        echo "  https://search.maven.org/artifact/com.higolab/maven-miner/$VERSION/jar"
        echo ""
        echo "Maven Central sync takes 10-30 minutes, full propagation ~2 hours"
    fi
    
    echo ""
    echo "Version published: $VERSION"
    
else
    echo ""
    echo "========================================="
    echo -e "${RED}✗ Deployment failed!${NC}"
    echo "========================================="
    echo ""
    echo "Common issues:"
    echo "  - GPG passphrase incorrect"
    echo "  - Sonatype credentials not configured"
    echo "  - GPG key not published to key servers"
    echo "  - Missing required POM metadata"
    echo ""
    echo "Check the error messages above and refer to:"
    echo "  .doc/Maven_Central_Publishing_Guide.md"
    exit 1
fi

cd ..

echo ""
echo "========================================="
echo "Done!"
echo "========================================="
