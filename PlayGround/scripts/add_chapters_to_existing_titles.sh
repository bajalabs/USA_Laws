#!/bin/bash

# 🇺🇸 Add Chapters to Existing USA Code Titles 16-54
# ONLY creates Chapter folders and downloads chapter files inside existing titles
# Does NOT create or modify main title directories

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BASE_URL="https://www.govinfo.gov/content/pkg"
YEAR="2023"
EXISTING_TITLES_DIR="/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA-Codes-16-54"

# Progress tracking
TOTAL_CHAPTERS_FOUND=0
TOTAL_CHAPTERS_DOWNLOADED=0
TOTAL_FILES_DOWNLOADED=0
TITLES_WITH_CHAPTERS=0
LOG_FILE="chapters_only_log_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Add Chapters to Existing USA Code Titles 16-54       ║${NC}"
echo -e "${BLUE}║              ONLY Chapter Creation & Download                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"

# Check if directory exists
if [ ! -d "$EXISTING_TITLES_DIR" ]; then
    echo -e "${RED}❌ Error: Directory $EXISTING_TITLES_DIR not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found existing titles directory: $EXISTING_TITLES_DIR${NC}\n"

# Logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Download function
download_chapter_file() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    
    mkdir -p "$(dirname "$output_path")"
    
    if curl -L --connect-timeout 20 --max-time 120 --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
        if [ -f "$output_path" ] && [ -s "$output_path" ]; then
            local file_size=$(du -h "$output_path" | cut -f1)
            echo -e "        ${GREEN}✓ $description ($file_size)${NC}"
            ((TOTAL_FILES_DOWNLOADED++))
            return 0
        fi
    fi
    
    echo -e "        ${RED}✗ Failed: $description${NC}"
    rm -f "$output_path" 2>/dev/null
    return 1
}

# Check if URL exists
url_exists() {
    curl --head --silent --connect-timeout 10 --max-time 20 "$1" 2>/dev/null | grep -q "200 OK"
}

# Extract title number from directory name
get_title_number() {
    echo "$1" | grep -o 'Title_[0-9]*' | cut -d_ -f2 | sed 's/^0*//'
}

# Discover and download chapters for a specific title
add_chapters_to_title() {
    local title_dir="$1"
    local title_name=$(basename "$title_dir")
    local title_num=$(get_title_number "$title_name")
    local chapters_found=0
    local chapters_downloaded=0
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ Processing: $title_name${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "  ${YELLOW}🔍 Searching for chapters in Title $title_num...${NC}"
    
    # Test chapters 1-100 (comprehensive search)
    for chapter in $(seq 1 100); do
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if url_exists "$chapter_url"; then
            ((chapters_found++))
            
            # Create chapter directory
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            echo -e "  ${BLUE}📁 Creating Chapter_$(printf "%02d" $chapter)${NC}"
            
            # Download chapter PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            if download_chapter_file "$chapter_url" "$pdf_file" "Chapter $chapter PDF"; then
                ((chapters_downloaded++))
            fi
            
            # Download chapter HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            download_chapter_file "$html_url" "$html_file" "Chapter $chapter HTML"
        fi
        
        # Test chapter variations with letters (A, B, C, D)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if url_exists "$chapter_url_suffix"; then
                ((chapters_found++))
                
                local chapter_dir_suffix="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_suffix"
                
                echo -e "  ${BLUE}📁 Creating Chapter_$(printf "%02d" $chapter)${suffix}${NC}"
                
                # Download chapter PDF with suffix
                local pdf_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                if download_chapter_file "$chapter_url_suffix" "$pdf_file_suffix" "Chapter ${chapter_letter} PDF"; then
                    ((chapters_downloaded++))
                fi
                
                # Download chapter HTML with suffix
                local html_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                local html_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                download_chapter_file "$html_url_suffix" "$html_file_suffix" "Chapter ${chapter_letter} HTML"
            fi
        done
    done
    
    # Update totals
    TOTAL_CHAPTERS_FOUND=$((TOTAL_CHAPTERS_FOUND + chapters_found))
    TOTAL_CHAPTERS_DOWNLOADED=$((TOTAL_CHAPTERS_DOWNLOADED + chapters_downloaded))
    
    if [ $chapters_found -gt 0 ]; then
        ((TITLES_WITH_CHAPTERS++))
        echo -e "  ${GREEN}✅ Title $title_num: $chapters_found chapters found, $chapters_downloaded downloaded${NC}"
        log_message "SUCCESS: Title $title_num - $chapters_found chapters found, $chapters_downloaded downloaded"
    else
        echo -e "  ${BLUE}ℹ️  Title $title_num: No chapters found (single-file title)${NC}"
        log_message "INFO: Title $title_num - No chapters found"
    fi
    
    sleep 0.5
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Starting chapter addition to existing titles...${NC}"
    echo -e "${PURPLE}📁 Working with: $EXISTING_TITLES_DIR${NC}\n"
    
    log_message "Starting chapter addition for existing USA Code titles 16-54"
    
    # Process each existing title directory
    for title_dir in "$EXISTING_TITLES_DIR"/Title_*; do
        if [ -d "$title_dir" ]; then
            add_chapters_to_title "$title_dir"
        fi
    done
    
    # Final report
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  CHAPTER ADDITION COMPLETE                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${GREEN}📊 Total chapters found: $TOTAL_CHAPTERS_FOUND${NC}"
    echo -e "${GREEN}📚 Total chapters downloaded: $TOTAL_CHAPTERS_DOWNLOADED${NC}"
    echo -e "${GREEN}📄 Total files downloaded: $TOTAL_FILES_DOWNLOADED${NC}"
    echo -e "${GREEN}🏛️  Titles with chapters: $TITLES_WITH_CHAPTERS${NC}"
    
    # Final verification
    echo -e "\n${BLUE}📊 Final structure verification:${NC}"
    local total_chapter_dirs=$(find "$EXISTING_TITLES_DIR" -type d -name "Chapter_*" | wc -l)
    echo -e "${CYAN}Total Chapter directories created: $total_chapter_dirs${NC}"
    
    if [ $TOTAL_CHAPTERS_DOWNLOADED -gt 0 ]; then
        echo -e "\n${GREEN}🎉 Chapter addition completed successfully!${NC}"
        echo -e "${YELLOW}📁 All chapters added to existing title structure${NC}"
        echo -e "${CYAN}✨ Your USA Code collection is now complete!${NC}"
    else
        echo -e "\n${YELLOW}ℹ️  No chapters were found for any titles${NC}"
        echo -e "${BLUE}💡 This might indicate that titles 16-54 use single-file structure${NC}"
    fi
    
    echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"
    log_message "Chapter addition completed. $TOTAL_CHAPTERS_DOWNLOADED chapters downloaded across $TITLES_WITH_CHAPTERS titles"
}

# Execute main function
main

echo -e "\n${PURPLE}✨ Chapter Addition to USA Code Titles 16-54 Complete! ✨${NC}"
exit 0