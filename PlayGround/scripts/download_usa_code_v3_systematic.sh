#!/bin/bash

# 🇺🇸 USA Code V3 - Systematic, Ordered Download
# Downloads complete USA Code in proper order with correct names
# Every title includes: Title PDF/HTML, Table of Contents, Front Matter, and all Chapters

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
BASE_DIR="../data_v3"

# Counters
TOTAL_DOWNLOADS=0
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0

echo -e "${CYAN}"
cat << "EOF"
🇺🇸 ═══════════════════════════════════════════════════════════════
   USA CODE V3 - SYSTEMATIC ORDERED DOWNLOAD
   
   ✅ Goes in order: Title 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15...
   ✅ Downloads complete title structure for each:
      - Complete Title (PDF + HTML)
      - Table of Contents (PDF + HTML) 
      - Front Matter (PDF + HTML)
      - All Chapters with correct names (PDF + HTML)
   ✅ Proper folder organization
   ✅ No chaos, pure order!
   
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

# Create base directory
mkdir -p "$BASE_DIR"

# Function to sanitize folder names for file system
sanitize_name() {
    echo "$1" | sed 's/[<>:"/\\|?*]/_/g' | sed 's/__*/_/g' | sed 's/^_//g' | sed 's/_$//g'
}

# Function to download a file
download_file() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    
    echo -e "${YELLOW}📥 $description${NC}"
    
    TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 1))
    
    if curl -L --connect-timeout 30 --max-time 300 "$url" -o "$output_path" 2>/dev/null; then
        local file_size=$(stat -f%z "$output_path" 2>/dev/null || echo "0")
        if [ "$file_size" -gt 1000 ]; then  # At least 1KB
            echo -e "${GREEN}✅ Downloaded: $description${NC}"
            SUCCESSFUL_DOWNLOADS=$((SUCCESSFUL_DOWNLOADS + 1))
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

# Function to get title name
get_title_name() {
    case $1 in
        1) echo "GENERAL PROVISIONS" ;;
        2) echo "THE CONGRESS" ;;
        3) echo "THE PRESIDENT" ;;
        4) echo "FLAG AND SEAL, SEAT OF GOVERNMENT, AND THE STATES" ;;
        5) echo "GOVERNMENT ORGANIZATION AND EMPLOYEES" ;;
        6) echo "DOMESTIC SECURITY" ;;
        7) echo "AGRICULTURE" ;;
        8) echo "ALIENS AND NATIONALITY" ;;
        9) echo "ARBITRATION" ;;
        10) echo "ARMED FORCES" ;;
        11) echo "BANKRUPTCY" ;;
        12) echo "BANKS AND BANKING" ;;
        13) echo "CENSUS" ;;
        14) echo "COAST GUARD" ;;
        15) echo "COMMERCE AND TRADE" ;;
        *) echo "UNKNOWN_TITLE" ;;
    esac
}

# Function to process a single title completely
process_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    
    if [ "$title_name" = "UNKNOWN_TITLE" ]; then
        echo -e "${RED}❌ Skipping unknown Title $title_num${NC}"
        return 1
    fi
    
    local safe_title_name=$(sanitize_name "$title_name")
    local title_dir="$BASE_DIR/Title_$(printf '%02d' $title_num)_$safe_title_name"
    
    echo -e "\n${CYAN}📖 ═══ PROCESSING TITLE $title_num: $title_name ═══${NC}"
    
    # Create title directory
    mkdir -p "$title_dir"
    
    # 1. Download Complete Title (PDF + HTML)
    echo -e "\n${PURPLE}📚 Downloading Complete Title $title_num${NC}"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num.pdf" \
                  "$title_dir/USCODE-$YEAR-title$title_num.pdf" \
                  "Title $title_num Complete (PDF)"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num.htm" \
                  "$title_dir/USCODE-$YEAR-title$title_num.htm" \
                  "Title $title_num Complete (HTML)"
    
    # 2. Download Table of Contents (PDF + HTML)
    echo -e "\n${PURPLE}📋 Downloading Table of Contents${NC}"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-toc.pdf" \
                  "$title_dir/USCODE-$YEAR-title$title_num-toc.pdf" \
                  "Title $title_num Table of Contents (PDF)"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-toc.htm" \
                  "$title_dir/USCODE-$YEAR-title$title_num-toc.htm" \
                  "Title $title_num Table of Contents (HTML)"
    
    # 3. Download Front Matter (PDF + HTML)
    echo -e "\n${PURPLE}📄 Downloading Front Matter${NC}"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-front.pdf" \
                  "$title_dir/USCODE-$YEAR-title$title_num-front.pdf" \
                  "Title $title_num Front Matter (PDF)"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-front.htm" \
                  "$title_dir/USCODE-$YEAR-title$title_num-front.htm" \
                  "Title $title_num Front Matter (HTML)"
    
    # 4. Download All Chapters
    echo -e "\n${PURPLE}📑 Discovering and downloading all chapters...${NC}"
    
    # For now, we'll use Firecrawl data we already have for Title 1
    # In a complete implementation, we'd analyze each title's structure
    case $title_num in
        1)
            # Title 1 chapters from our analysis
            download_chapter $title_num "1" "RULES OF CONSTRUCTION" "$title_dir"
            download_chapter $title_num "2" "ACTS AND RESOLUTIONS; FORMALITIES OF ENACTMENT; REPEALS; SEALING OF INSTRUMENTS" "$title_dir"
            download_chapter $title_num "3" "CODE OF LAWS OF UNITED STATES AND SUPPLEMENTS; DISTRICT OF COLUMBIA CODE AND SUPPLEMENTS" "$title_dir"
            ;;
        10)
            # Title 10 uses subtitles instead of chapters
            download_subtitle $title_num "A" "General Military Law" "$title_dir"
            download_subtitle $title_num "B" "Army" "$title_dir"
            download_subtitle $title_num "C" "Navy and Marine Corps" "$title_dir"
            download_subtitle $title_num "D" "Air Force and Space Force" "$title_dir"
            download_subtitle $title_num "E" "Reserve Components" "$title_dir"
            download_subtitle $title_num "F" "Alternative Military Personnel Systems" "$title_dir"
            ;;
        *)
            # For other titles, we'll discover chapters dynamically
            discover_and_download_chapters $title_num "$title_dir"
            ;;
    esac
    
    echo -e "\n${GREEN}✅ Completed Title $title_num: $title_name${NC}"
}

# Function to download a specific chapter
download_chapter() {
    local title_num=$1
    local chapter_id="$2"
    local chapter_name="$3"
    local title_dir="$4"
    
    local safe_chapter_name=$(sanitize_name "$chapter_name")
    local chapter_dir="$title_dir/Chapter_${chapter_id}_$safe_chapter_name"
    
    mkdir -p "$chapter_dir"
    
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" \
                  "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" \
                  "Chapter $chapter_id (PDF)"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" \
                  "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" \
                  "Chapter $chapter_id (HTML)"
}

# Function to download a specific subtitle (for Title 10)
download_subtitle() {
    local title_num=$1
    local subtitle_id="$2"
    local subtitle_name="$3"
    local title_dir="$4"
    
    local safe_subtitle_name=$(sanitize_name "$subtitle_name")
    local subtitle_dir="$title_dir/Subtitle_${subtitle_id}_$safe_subtitle_name"
    
    mkdir -p "$subtitle_dir"
    
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-subtitle$subtitle_id.pdf" \
                  "$subtitle_dir/USCODE-$YEAR-title$title_num-subtitle$subtitle_id.pdf" \
                  "Subtitle $subtitle_id (PDF)"
    download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-subtitle$subtitle_id.htm" \
                  "$subtitle_dir/USCODE-$YEAR-title$title_num-subtitle$subtitle_id.htm" \
                  "Subtitle $subtitle_id (HTML)"
}

# Function to discover chapters dynamically (basic implementation)
discover_and_download_chapters() {
    local title_num=$1
    local title_dir="$2"
    
    echo -e "${BLUE}🔍 Discovering chapters for Title $title_num...${NC}"
    
    # Test numbered chapters 1-50
    for chapter_num in $(seq 1 50); do
        local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_num.pdf"
        
        if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
            local chapter_dir="$title_dir/Chapter_$(printf '%02d' $chapter_num)"
            mkdir -p "$chapter_dir"
            
            download_file "$pdf_url" \
                          "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_num.pdf" \
                          "Chapter $chapter_num (PDF)"
            download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_num.htm" \
                          "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_num.htm" \
                          "Chapter $chapter_num (HTML)"
        fi
    done
    
    # Test letter-numbered chapters (basic patterns)
    for base_num in $(seq 1 20); do
        for letter in A B C D E; do
            local chapter_id="${base_num}${letter}"
            local pdf_url="$BASE_URL/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf"
            
            if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
                local chapter_dir="$title_dir/Chapter_$chapter_id"
                mkdir -p "$chapter_dir"
                
                download_file "$pdf_url" \
                              "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.pdf" \
                              "Chapter $chapter_id (PDF)"
                download_file "$BASE_URL/USCODE-$YEAR-title$title_num/html/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" \
                              "$chapter_dir/USCODE-$YEAR-title$title_num-chap$chapter_id.htm" \
                              "Chapter $chapter_id (HTML)"
            fi
        done
    done
}

# Main execution - Process titles IN ORDER
echo -e "${BLUE}🚀 Starting systematic USA Code download...${NC}"

# Process titles 1-15 in order
for title_num in $(seq 1 15); do
    process_title $title_num
    
    # Add respectful delay between titles
    echo -e "${BLUE}⏱️  Waiting 3 seconds before next title...${NC}"
    sleep 3
done

# Final summary
echo -e "\n${CYAN}📊 FINAL SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Successful downloads: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed downloads: $FAILED_DOWNLOADS${NC}"
echo -e "${YELLOW}📦 Total attempted: $TOTAL_DOWNLOADS${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 USA Code systematic download completed!${NC}"
    echo -e "${BLUE}📁 Files organized in: $BASE_DIR${NC}"
    echo -e "${PURPLE}📋 Structure: Title → TOC, Front Matter, Chapters${NC}"
else
    echo -e "\n${RED}❌ No files were downloaded successfully.${NC}"
    exit 1
fi
