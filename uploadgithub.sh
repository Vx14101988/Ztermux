#!/bin/bash

# Prompt for user input
read -p "Masukkan nama pengguna GitHub Anda: " git_username
read -p "Masukkan email Anda: " git_email
read -sp "Masukkan token akses personal GitHub Anda: " git_token
echo
read -p "Masukkan nama repository GitHub (contoh: username/nama-repo): " repo_name
read -p "Masukkan nama file yang ingin diupload: " file_name

# Define search path (search from root directory)
search_path="/"

# Search for the file
file_path=$(find "$search_path" -name "$file_name" 2>/dev/null)

# Check if file exists
if [ -z "$file_path" ]; then
    echo "File tidak ditemukan: $file_name"
    exit 1
fi

# Install Git if not already installed
if ! command -v git &> /dev/null; then
    echo "Git belum terpasang, memasang Git..."
    pkg install git -y
fi

# Configure Git user
git config --global user.name "$git_username"
git config --global user.email "$git_email"

# Create .netrc file for authentication
echo "machine github.com" > ~/.netrc
echo "login $git_username" >> ~/.netrc
echo "password $git_token" >> ~/.netrc

# Set permissions for .netrc to be readable only by the user
chmod 600 ~/.netrc

# Clone the repository if it does not exist
repo_dir=$(basename "$repo_name")
if [ ! -d "$repo_dir" ]; then
    echo "Meng-clone repository..."
    git clone https://github.com/$repo_name.git
fi

# Change directory to the repository
cd "$repo_dir" || { echo "Gagal masuk ke direktori repository"; exit 1; }

# Copy the file to the repository
cp "$file_path" .

# Add the file to the staging area
git add "$(basename "$file_path")"

# Commit the changes
git commit -m "Menambahkan $(basename "$file_path")"

# Push the changes to GitHub
git push origin main

echo "File berhasil diupload ke GitHub."
