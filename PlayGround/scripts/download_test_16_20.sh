#!/bin/bash

# Simple test script to download titles 16-20 and debug folder creation
set -e

BASE_URL="https://www.govinfo.gov/content/pkg"
YEAR="2023"
DOWNLOAD_DIR="../USA-Codes"

echo "🔧 Testing download for titles 16-20..."
echo "📁 Working directory: $(pwd)"
echo "📂 Target directory: $DOWNLOAD_DIR"

# Change to correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
echo "📁 Changed to: $(pwd)"

# Function to get title name
get_title_name() {
    case $1 in
        16) echo "CONSERVATION" ;;
        17) echo "COPYRIGHTS" ;;
        18) echo "CRIMES AND CRIMINAL PROCEDURE" ;;
        19) echo "CUSTOMS DUTIES" ;;
        20) echo "EDUCATION" ;;
    esac
}

for title_num in 16 17 18 19 20; do
    title_name=$(get_title_name $title_num)
    title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    
    echo ""
    echo "🔄 Processing Title $title_num: $title_name"
    echo "📁 Creating directory: $title_dir"
    
    # Create directory
    mkdir -p "$title_dir"
    
    # Verify directory was created
    if [ -d "$title_dir" ]; then
        echo "✅ Directory created successfully: $title_dir"
        
        # Download main PDF
        pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
        pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
        
        echo "⬇️  Downloading: $pdf_url"
        if curl -L --connect-timeout 30 --max-time 120 --silent "$pdf_url" -o "$pdf_file"; then
            if [ -f "$pdf_file" ] && [ -s "$pdf_file" ]; then
                file_size=$(du -h "$pdf_file" | cut -f1)
                echo "✅ Downloaded: $(basename "$pdf_file") ($file_size)"
            else
                echo "❌ Download failed: Empty file"
                rm -f "$pdf_file"
            fi
        else
            echo "❌ Download failed: Curl error"
        fi
    else
        echo "❌ Failed to create directory: $title_dir"
    fi
    
    sleep 1
done

echo ""
echo "📊 Final verification..."
echo "📁 Listing all Title directories:"
ls -la "$DOWNLOAD_DIR" | grep "Title_" | wc -l
echo ""
echo "🎯 New titles created:"
ls "$DOWNLOAD_DIR" | grep -E "Title_(1[6-9]|20)" || echo "None found"

echo "✅ Test complete!"