#!/bin/bash

# 🇺🇸 USA Code Comprehensive Download System V2
# Handles all US Code organizational patterns: Chapters, Letter-Chapters, and Subtitles
# Creates proper Title/Chapter folder hierarchy as requested

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="https://www.govinfo.gov/content/pkg"
YEAR="2024"
BASE_DIR="../data_v2"
MAX_TITLES=54

# Counters
TOTAL_DOWNLOADS=0
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_SIZE=0

echo -e "${CYAN}"
cat << "EOF"
🇺🇸 ═══════════════════════════════════════════════════════════════
   USA CODE COMPREHENSIVE DOWNLOAD SYSTEM V2
   
   ✅ Handles Chapter-based titles (e.g., Title 1, 15)
   ✅ Handles Letter-chapters (2A, 2B, 2B-1, 15A, etc.)
   ✅ Handles Subtitle-based titles (e.g., Title 10)
   ✅ Creates proper Title/Chapter folder hierarchy
   ✅ Downloads both PDF and HTML formats
   
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

# Create base directory
mkdir -p "$BASE_DIR"

# Function to sanitize folder names
sanitize_folder_name() {
    local name="$1"
    # Replace problematic characters with underscores
    echo "$name" | sed 's/[<>:"/\\|?*]/_/g' | sed 's/  */_/g' | sed 's/_*$//g'
}

# Function to get title info from Firecrawl results
get_title_structure() {
    local title_num=$1
    local title_url="https://www.govinfo.gov/app/collection/uscode/2024/title$title_num"
    
    echo -e "${BLUE}📋 Analyzing Title $title_num structure...${NC}"
    
    # Test if title exists first
    if ! curl -I --connect-timeout 10 --max-time 30 "$title_url" 2>/dev/null | head -1 | grep -q "200"; then
        echo -e "${RED}❌ Title $title_num not accessible${NC}"
        return 1
    fi
    
    # For now, we'll implement basic detection
    # In a full implementation, we'd use Firecrawl here
    echo "chapter-based"  # Default assumption
}

# Function to download a single file
download_file() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    
    echo -e "${YELLOW}📥 Downloading: $description${NC}"
    
    if curl -L --connect-timeout 30 --max-time 300 "$url" -o "$output_path" 2>/dev/null; then
        local file_size=$(stat -f%z "$output_path" 2>/dev/null || echo "0")
        if [ "$file_size" -gt 1000 ]; then  # At least 1KB
            echo -e "${GREEN}✅ Downloaded: $description ($(numfmt --to=iec $file_size))${NC}"
            SUCCESSFUL_DOWNLOADS=$((SUCCESSFUL_DOWNLOADS + 1))
            TOTAL_SIZE=$((TOTAL_SIZE + file_size))
            return 0
        else
            rm -f "$output_path"
            echo -e "${RED}❌ Failed: $description (file too small)${NC}"
            FAILED_DOWNLOADS=$((FAILED_DOWNLOADS + 1))
            return 1
        fi
    else
        echo -e "${RED}❌ Failed: $description (download error)${NC}"
        FAILED_DOWNLOADS=$((FAILED_DOWNLOADS + 1))
        return 1
    fi
}

# Function to process a chapter-based title
process_chapter_title() {
    local title_num=$1
    local title_name="$2"
    local title_dir="$3"
    
    echo -e "${PURPLE}📚 Processing Chapter-based Title $title_num: $title_name${NC}"
    
    # Create title directory
    mkdir -p "$title_dir"
    
    # Try to detect chapters by testing URLs
    local chapter_num=1
    local consecutive_failures=0
    local max_failures=5
    
    # Test basic numbered chapters (1, 2, 3, ...)
    while [ $consecutive_failures -lt $max_failures ] && [ $chapter_num -le 150 ]; do
        local chapter_id="$chapter_num"
        local chapter_dir="$title_dir/Chapter_$(printf '%02d' $chapter_num)"
        local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf"
        local html_url="$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_id.htm"
        
        # Test if chapter exists
        if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
            mkdir -p "$chapter_dir"
            
            TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 2))
            download_file "$pdf_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" "Title $title_num Chapter $chapter_id (PDF)"
            download_file "$html_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" "Title $title_num Chapter $chapter_id (HTML)"
            
            consecutive_failures=0
        else
            consecutive_failures=$((consecutive_failures + 1))
        fi
        
        chapter_num=$((chapter_num + 1))
    done
    
    # Test letter-numbered chapters (1A, 2A, 2B, etc.)
    for base_num in $(seq 1 50); do
        for letter in A B C D E; do
            local chapter_id="${base_num}${letter}"
            local chapter_dir="$title_dir/Chapter_${base_num}${letter}"
            local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf"
            local html_url="$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_id.htm"
            
            if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
                mkdir -p "$chapter_dir"
                
                TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 2))
                download_file "$pdf_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" "Title $title_num Chapter $chapter_id (PDF)"
                download_file "$html_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" "Title $title_num Chapter $chapter_id (HTML)"
            fi
        done
        
        # Test complex patterns like 2B-1
        for letter in A B C D E; do
            for suffix in 1 2 3; do
                local chapter_id="${base_num}${letter}-${suffix}"
                local chapter_dir="$title_dir/Chapter_${base_num}${letter}-${suffix}"
                local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf"
                local html_url="$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_id.htm"
                
                if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
                    mkdir -p "$chapter_dir"
                    
                    TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 2))
                    download_file "$pdf_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" "Title $title_num Chapter $chapter_id (PDF)"
                    download_file "$html_url" "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" "Title $title_num Chapter $chapter_id (HTML)"
                fi
            done
        done
    done
}

# Function to process a subtitle-based title (like Title 10)
process_subtitle_title() {
    local title_num=$1
    local title_name="$2"
    local title_dir="$3"
    
    echo -e "${PURPLE}📚 Processing Subtitle-based Title $title_num: $title_name${NC}"
    
    # Create title directory
    mkdir -p "$title_dir"
    
    # Test subtitles A through F
    for subtitle in A B C D E F; do
        local subtitle_dir="$title_dir/Subtitle_${subtitle}"
        local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-subtitle$subtitle.pdf"
        local html_url="$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-subtitle$subtitle.htm"
        
        if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
            mkdir -p "$subtitle_dir"
            
            TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 2))
            download_file "$pdf_url" "$subtitle_dir/USCODE-$YEAR-title$title_num-subtitle$subtitle.pdf" "Title $title_num Subtitle $subtitle (PDF)"
            download_file "$html_url" "$subtitle_dir/USCODE-$YEAR-title$title_num-subtitle$subtitle.htm" "Title $title_num Subtitle $subtitle (HTML)"
        fi
    done
}

# Main download loop
echo -e "${BLUE}🚀 Starting USA Code download...${NC}"

# Function to get title name
get_title_name() {
    case $1 in
        1) echo "General Provisions" ;;
        2) echo "The Congress" ;;
        3) echo "The President" ;;
        4) echo "Flag and Seal, Seat of Government, and the States" ;;
        5) echo "Government Organization and Employees" ;;
        6) echo "Domestic Security" ;;
        7) echo "Agriculture" ;;
        8) echo "Aliens and Nationality" ;;
        9) echo "Arbitration" ;;
        10) echo "Armed Forces" ;;
        11) echo "Bankruptcy" ;;
        12) echo "Banks and Banking" ;;
        13) echo "Census" ;;
        14) echo "Coast Guard" ;;
        15) echo "Commerce and Trade" ;;
        *) echo "Unknown Title" ;;
    esac
}

# Process first 15 titles for testing
for title_num in $(seq 1 15); do
    title_name=$(get_title_name $title_num)
    if [ "$title_name" != "Unknown Title" ]; then
        safe_title_name=$(sanitize_folder_name "$title_name")
        title_dir="$BASE_DIR/Title_$(printf '%02d' $title_num)_$safe_title_name"
        
        echo -e "\n${CYAN}📖 Processing Title $title_num: $title_name${NC}"
        
        # Determine title structure
        if [ "$title_num" -eq 10 ]; then
            # Special case: Title 10 uses subtitles
            process_subtitle_title "$title_num" "$title_name" "$title_dir"
        else
            # Default: Chapter-based
            process_chapter_title "$title_num" "$title_name" "$title_dir"
        fi
        
        # Add delay between titles to be respectful
        sleep 2
    fi
done

# Final summary
echo -e "\n${CYAN}📊 DOWNLOAD SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Successful downloads: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed downloads: $FAILED_DOWNLOADS${NC}"
echo -e "${YELLOW}📦 Total attempted: $TOTAL_DOWNLOADS${NC}"
echo -e "${PURPLE}💾 Total size: $(numfmt --to=iec $TOTAL_SIZE)${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 USA Code download completed successfully!${NC}"
    echo -e "${BLUE}📁 Files saved to: $BASE_DIR${NC}"
else
    echo -e "\n${RED}❌ No files were downloaded successfully.${NC}"
    exit 1
fi
