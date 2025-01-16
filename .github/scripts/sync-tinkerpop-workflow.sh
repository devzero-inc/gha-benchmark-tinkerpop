#!/bin/bash

# Clone tinkerpop repo
git clone https://github.com/apache/tinkerpop.git temp-tinkerpop --depth=1

# Create workflows directory if it doesn't exist
mkdir -p .github/workflows/

# Copy workflow file
cp temp-tinkerpop/.github/workflows/build-test.yml .github/workflows/benchmark.yml

# Modify with yq
yq -P -i '.on = {"workflow_dispatch": {}, "schedule": [{"cron": "15 */12 * * *"}]}' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy == null)).strategy.matrix.os = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy != null)).strategy.matrix.os = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '.jobs.*.runs-on = "${{ matrix.os }}"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.repository) = "apache/tinkerpop"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.ref) = "main"' .github/workflows/benchmark.yml

# Clean up
rm -rf temp-tinkerpop

# Configure git and commit
git config --local user.email "$1"
git config --local user.name "$2"
git remote set-url origin https://$GHA_BENCHMARK@github.com/devzero-inc/gha-benchmark-tinkerpop.git
git add .github/workflows/benchmark.yml
git commit -m "Setup tinkerpop runtime tests workflow" || echo "No changes to commit"
git push origin main