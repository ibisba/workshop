#!/bin/bash

# Building the book
jupyter-book build ibisba_workshops

# Ensure we're in the root directory of the book
BOOK_DIR=$(pwd)/ibisba_workshops/

echo $BOOK_DIR

# Define the output directory (where the compiled book is saved)
BUILD_DIR=$BOOK_DIR"/_build/html"

# Check if the Jupyter Book build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory '$BUILD_DIR' does not exist. Please build the book first."
    exit 1
fi

# Build the Jupyter Book (uncomment if you want the script to build it automatically)
# jupyter-book build $BOOK_DIR

# Create or switch to the gh-pages branch
git checkout --orphan gh-pages

# Remove all files from the current gh-pages branch
git rm -rf .

# Copy the contents of the built book to the gh-pages branch
cp -r $BUILD_DIR/* .

# Add the compiled files to git
git add .

# Commit the changes
git commit -m "Deploy Jupyter Book"

# Push to the gh-pages branch (force push to overwrite the history)
git push origin gh-pages --force

# Optionally, add the .nojekyll file to prevent GitHub Pages from using Jekyll
echo "Disabling Jekyll by adding .nojekyll"
touch .nojekyll
git add .nojekyll
git commit -m "Disable Jekyll"
git push origin gh-pages

echo "Deployment complete! Your Jupyter Book is live on GitHub Pages."

# Switch back to the main branch
git checkout main
