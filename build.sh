#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
echo "Starting Jupyter Book deployment process..."

# Go to this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# Define the output directory (where the compiled book is saved)
BUILD_DIR="$HOME/ibisba_workshops/_build/html"

# Building the book
echo "Building Jupyter Book..."
jupyter-book build --path-output ~/ibisba_workshops $DIR/ibisba_workshops || { echo "Jupyter Book build failed"; exit 1; }

# Define the output directory (where the compiled book is saved)
BUILD_DIR=$HOME"/ibisba_workshops/_build/html"
echo "Build directory: $BUILD_DIR"

# Check if the Jupyter Book build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory '$BUILD_DIR' does not exist. Book build may have failed."
    exit 1
fi

echo "Build directory exists: $BUILD_DIR"

# Check if gh-pages branch exists and handle accordingly
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "gh-pages branch already exists, switching to it..."
    git checkout gh-pages || { echo "Failed to switch to existing gh-pages branch"; exit 1; }
    # Remove all files except .git
    echo "Cleaning existing gh-pages branch..."
    find . -maxdepth 1 -not -path "./.git*" -not -path "." -exec rm -rf {} \;
else
    echo "Creating new gh-pages branch..."
    git checkout --orphan gh-pages || { echo "Failed to create gh-pages branch"; exit 1; }
    # Remove all files (standard for new orphan branch)
    git rm -rf . || { echo "Failed to clean new gh-pages branch"; exit 1; }
fi

# Copy the contents of the built book to the gh-pages branch
echo "Copying built book content..."
cp -r $BUILD_DIR/* . || { echo "Failed to copy book content"; exit 1; }

# Add the compiled files to git
echo "Adding files to git..."
git add . || { echo "Failed to add files to git"; exit 1; }

# Commit the changes
echo "Committing changes..."
git commit -m "Deploy Jupyter Book" || { echo "Failed to commit changes"; exit 1; }

# Push to the gh-pages branch (force push to overwrite the history)
echo "Pushing to gh-pages branch..."
git push origin gh-pages --force || { echo "Failed to push to gh-pages branch"; exit 1; }

# Add the .nojekyll file to prevent GitHub Pages from using Jekyll
echo "Disabling Jekyll by adding .nojekyll..."
touch .nojekyll || { echo "Failed to create .nojekyll file"; exit 1; }
git add .nojekyll || { echo "Failed to add .nojekyll to git"; exit 1; }
git commit -m "Disable Jekyll" || { echo "Failed to commit .nojekyll"; exit 1; }
git push origin gh-pages || { echo "Failed to push .nojekyll"; exit 1; }

echo "Deployment complete! Your Jupyter Book is live on GitHub Pages."

# Switch back to the main branch
echo "Switching back to main branch..."
# Save the original branch name to return to it later
ORIGINAL_BRANCH=main
git checkout $ORIGINAL_BRANCH || { echo "Failed to switch back to original branch ($ORIGINAL_BRANCH)"; exit 1; }

echo "Script completed successfully!"