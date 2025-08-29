#!/bin/bash

# 🇺🇸 USA Code Batch Download - Final Optimized Version
# Downloads USA Code titles 16-54 with robust error handling and rate limiting

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
DOWNLOAD_DIR="../USA-Codes"
START_TITLE=16
END_TITLE=20  # Start with just 5 titles to test
DELAY_BETWEEN_DOWNLOADS=3  # Longer delays to avoid rate limiting

# Counters
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_FILES=0
LOG_FILE="download_log_batch_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         USA Code Batch Download - Final Version              ║${NC}"
echo -e "${BLUE}║            Testing with Titles 16-20 First                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"

# Function to get title name
get_title_name() {
    case $1 in
        16) echo "CONSERVATION" ;;
        17) echo "COPYRIGHTS" ;;
        18) echo "CRIMES AND CRIMINAL PROCEDURE" ;;
        19) echo "CUSTOMS DUTIES" ;;
        20) echo "EDUCATION" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Simple download function with minimal error handling
simple_download() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    
    echo -e "    ${YELLOW}Downloading: $description${NC}"
    echo -e "    ${BLUE}URL: $url${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output_path")"
    
    # Use curl with minimal flags and verbose output for debugging
    if curl -L --connect-timeout 60 --max-time 600 --retry 2 --retry-delay 5 \
            "$url" -o "$output_path"; then
        
        if [ -f "$output_path" ] && [ -s "$output_path" ]; then
            local file_size=$(du -h "$output_path" | cut -f1)
            echo -e "    ${GREEN}✓ Success: $description ($file_size)${NC}"
            ((TOTAL_FILES++))
            return 0
        else
            echo -e "    ${RED}✗ Failed: Empty file${NC}"
            rm -f "$output_path"
            return 1
        fi
    else
        echo -e "    ${RED}✗ Failed: Download error${NC}"
        rm -f "$output_path"
        return 1
    fi
}

# Process single title
process_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    local downloads_for_title=0
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ Processing Title $title_num: $title_name${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    mkdir -p "$title_dir"
    
    # Try to download main title PDF (most important)
    local main_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local main_file="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
    
    if simple_download "$main_url" "$main_file" "Main Title PDF"; then
        ((downloads_for_title++))
    fi
    
    # Add delay between downloads
    sleep $DELAY_BETWEEN_DOWNLOADS
    
    # Try to download main title HTML
    local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}.htm"
    local html_file="${title_dir}/USCODE-${YEAR}-title${title_num}.htm"
    
    if simple_download "$html_url" "$html_file" "Main Title HTML"; then
        ((downloads_for_title++))
    fi
    
    # Add delay
    sleep $DELAY_BETWEEN_DOWNLOADS
    
    if [ $downloads_for_title -gt 0 ]; then
        ((SUCCESSFUL_DOWNLOADS++))
        echo -e "  ${GREEN}✅ Title $title_num: $downloads_for_title files downloaded${NC}"
        echo "[$(date)] SUCCESS: Title $title_num - $downloads_for_title files" >> "$LOG_FILE"
    else
        ((FAILED_DOWNLOADS++))
        echo -e "  ${RED}❌ Title $title_num: No files downloaded${NC}"
        echo "[$(date)] FAILED: Title $title_num - No files" >> "$LOG_FILE"
    fi
}

# Main execution
echo -e "${BLUE}🚀 Starting batch download...${NC}"
echo -e "${PURPLE}📁 Directory: $DOWNLOAD_DIR${NC}"
echo -e "${PURPLE}⏱️  Delay between downloads: ${DELAY_BETWEEN_DOWNLOADS}s${NC}\n"

# Change to correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
mkdir -p "$DOWNLOAD_DIR"

# Start log
echo "[$(date)] Starting USA Code batch download - Titles $START_TITLE-$END_TITLE" > "$LOG_FILE"

# Process titles
for title_num in $(seq $START_TITLE $END_TITLE); do
    process_title $title_num
    
    # Longer delay between titles
    echo -e "  ${BLUE}⏳ Waiting ${DELAY_BETWEEN_DOWNLOADS} seconds before next title...${NC}"
    sleep $DELAY_BETWEEN_DOWNLOADS
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  BATCH DOWNLOAD COMPLETE                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful titles: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed titles: $FAILED_DOWNLOADS${NC}"
echo -e "${BLUE}📄 Total files downloaded: $TOTAL_FILES${NC}"

total_titles=$((END_TITLE - START_TITLE + 1))
success_rate=$(( SUCCESSFUL_DOWNLOADS * 100 / total_titles ))
echo -e "${CYAN}📈 Success rate: ${success_rate}%${NC}"

if [ $TOTAL_FILES -gt 0 ]; then
    total_size=$(find "$DOWNLOAD_DIR" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "Unknown")
    echo -e "${BLUE}💾 Total size: $total_size${NC}"
fi

echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 Batch download completed with $SUCCESSFUL_DOWNLOADS successful titles!${NC}"
    echo -e "${YELLOW}✨ Ready to extend to all remaining titles 16-54${NC}"
else
    echo -e "\n${RED}⚠️  No successful downloads${NC}"
    echo -e "${YELLOW}Please check connectivity and server status${NC}"
fi

echo "[$(date)] Batch download completed. Success rate: ${success_rate}%" >> "$LOG_FILE"

exit 0