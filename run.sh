#!/usr/bin/env bash
set -e

echo "Creating virtual environment..."
python3 -m venv .venv

echo "Activating virtual environment..."
source .venv/bin/activate

echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Scraping procedure pages..."
python src/scrape.py

echo "Chunking content..."
python src/chunk.py

echo "Starting Q&A CLI..."
python src/main.py 