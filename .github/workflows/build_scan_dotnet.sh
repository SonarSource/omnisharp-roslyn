#!/bin/bash

# This script expects 2 environment variables to be set:
# * SONAR_TOKEN
# * SONAR_HOST_URL

set -euo pipefail

# Read the version from the build script
VERSION=$(cat scripts/common.cake | grep ' SemVer = "' | sed -nre 's/.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/p')
echo "Sonar project version is '${VERSION}'"

REGION_FLAG=$([ "$SONAR_REGION" = "us" ] && echo "-d:sonar.region=$SONAR_REGION" || echo "")

# Setup SonarQube scan
dotnet sonarscanner begin \
  -d:sonar.token=${SONAR_TOKEN} \
  $REGION_FLAG \
  -o:sonarsource \
  -d:sonar.projectBaseDir="$GITHUB_WORKSPACE/src" \
  -k:"SonarSource_omnisharp-roslyn" \
  -v:${VERSION}

# Build (ideally should also run .NET unit tests but they are failing)
powershell -File build.ps1 -target Build -configuration Release

# Finish SonarQube scan
dotnet sonarscanner end \
  -d:sonar.token=${SONAR_TOKEN}
