#!/bin/bash

# 🇺🇸 Complete USA Code Download Script - Titles 16-54 (2023 Edition)
# Downloads remaining USA Code titles with comprehensive folder structure matching existing titles 1-15
# Creates proper folder structure: Title_XX_NAME/Chapter_XX/files

set -e

# Colors for output
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
END_TITLE=54
MAX_RETRIES=3
DELAY_BETWEEN_TITLES=2

# Counters and tracking
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_FILES_DOWNLOADED=0
LOG_FILE="download_log_complete_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Complete USA Code Download - Titles 16-54 (2023)       ║${NC}"
echo -e "${BLUE}║              Matching Folder Structure to 1-15               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}📋 Downloading titles 16-54 with matching folder structure${NC}\n"

# Function to get title name
get_title_name() {
    local title_num=$1
    case $title_num in
        16) echo "CONSERVATION" ;;
        17) echo "COPYRIGHTS" ;;
        18) echo "CRIMES AND CRIMINAL PROCEDURE" ;;
        19) echo "CUSTOMS DUTIES" ;;
        20) echo "EDUCATION" ;;
        21) echo "FOOD AND DRUGS" ;;
        22) echo "FOREIGN RELATIONS AND INTERCOURSE" ;;
        23) echo "HIGHWAYS" ;;
        24) echo "HOSPITALS AND ASYLUMS" ;;
        25) echo "INDIANS" ;;
        26) echo "INTERNAL REVENUE CODE" ;;
        27) echo "INTOXICATING LIQUORS" ;;
        28) echo "JUDICIARY AND JUDICIAL PROCEDURE" ;;
        29) echo "LABOR" ;;
        30) echo "MINERAL LANDS AND MINING" ;;
        31) echo "MONEY AND FINANCE" ;;
        32) echo "NATIONAL GUARD" ;;
        33) echo "NAVIGATION AND NAVIGABLE WATERS" ;;
        34) echo "CRIME CONTROL AND LAW ENFORCEMENT" ;;
        35) echo "PATENTS" ;;
        36) echo "PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS" ;;
        37) echo "PAY AND ALLOWANCES OF THE UNIFORMED SERVICES" ;;
        38) echo "VETERANS' BENEFITS" ;;
        39) echo "POSTAL SERVICE" ;;
        40) echo "PUBLIC BUILDINGS, PROPERTY, AND WORKS" ;;
        41) echo "PUBLIC CONTRACTS" ;;
        42) echo "THE PUBLIC HEALTH AND WELFARE" ;;
        43) echo "PUBLIC LANDS" ;;
        44) echo "PUBLIC PRINTING AND DOCUMENTS" ;;
        45) echo "RAILROADS" ;;
        46) echo "SHIPPING" ;;
        47) echo "TELECOMMUNICATIONS" ;;
        48) echo "TERRITORIES AND INSULAR POSSESSIONS" ;;
        49) echo "TRANSPORTATION" ;;
        50) echo "WAR AND NATIONAL DEFENSE" ;;
        51) echo "NATIONAL AND COMMERCIAL SPACE PROGRAMS" ;;
        52) echo "VOTING AND ELECTIONS" ;;
        53) echo "SMALL BUSINESS" ;;
        54) echo "NATIONAL PARK SERVICE AND RELATED PROGRAMS" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to download file with retries
download_with_retry() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    local retry_count=0
    
    # Create directory if needed
    mkdir -p "$(dirname "$output_path")"
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        echo -e "    ${YELLOW}Downloading: $description (try $((retry_count + 1)))${NC}"
        
        if curl -L --connect-timeout 30 --max-time 300 --retry 1 --retry-delay 2 --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
            if [ -f "$output_path" ] && [ -s "$output_path" ]; then
                local file_size=$(du -h "$output_path" | cut -f1)
                echo -e "    ${GREEN}✓ Downloaded: $description ($file_size)${NC}"
                ((TOTAL_FILES_DOWNLOADED++))
                return 0
            else
                echo -e "    ${RED}✗ Empty file: $description${NC}"
                rm -f "$output_path"
            fi
        fi
        
        ((retry_count++))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            echo -e "    ${RED}✗ Failed, retrying in 3 seconds...${NC}"
            sleep 3
        else
            echo -e "    ${RED}✗ Failed after $MAX_RETRIES attempts: $description${NC}"
            log_message "FAILED: $url"
            return 1
        fi
    done
}

# Function to discover and download chapters for a title
download_chapters() {
    local title_num=$1
    local title_dir="$2"
    local chapters_found=0
    
    echo -e "  ${YELLOW}🔍 Discovering chapters for Title $title_num...${NC}"
    
    # Try chapter numbers 1-50 and common letter variations
    for chapter in $(seq 1 50); do
        # Test if chapter exists (quick HEAD request)
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if curl --head --silent --connect-timeout 10 --max-time 30 "$chapter_url" 2>/dev/null | grep -q "200 OK"; then
            ((chapters_found++))
            
            # Create chapter directory
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            # Download chapter PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            download_with_retry "$chapter_url" "$pdf_file" "Chapter $chapter PDF"
            
            # Download chapter HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            download_with_retry "$html_url" "$html_file" "Chapter $chapter HTML"
        fi
        
        # Try chapter variations with letters (A, B, C, D)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_letter="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if curl --head --silent --connect-timeout 10 --max-time 30 "$chapter_url_letter" 2>/dev/null | grep -q "200 OK"; then
                ((chapters_found++))
                
                # Create chapter directory with suffix
                local chapter_dir_letter="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_letter"
                
                # Download chapter PDF with suffix
                local pdf_file_letter="${chapter_dir_letter}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                download_with_retry "$chapter_url_letter" "$pdf_file_letter" "Chapter ${chapter_letter} PDF"
                
                # Download chapter HTML with suffix
                local html_url_letter="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                local html_file_letter="${chapter_dir_letter}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                download_with_retry "$html_url_letter" "$html_file_letter" "Chapter ${chapter_letter} HTML"
            fi
        done
    done
    
    echo -e "  ${BLUE}📊 Found $chapters_found chapters for Title $title_num${NC}"
    return $chapters_found
}

# Function to process single title
process_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    
    if [ "$title_name" = "UNKNOWN" ]; then
        echo -e "${RED}✗ Unknown title number: $title_num${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ [$title_num/54] Processing Title $title_num: $(echo "$title_name" | cut -c1-35)...${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Create title directory structure
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    echo -e "${BLUE}📁 Creating structure: $(basename "$title_dir")${NC}"
    mkdir -p "$title_dir"
    
    log_message "Processing Title $title_num: $title_name"
    
    # Download main title files
    local title_files_downloaded=0
    
    # Main title PDF
    local title_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local title_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
    if download_with_retry "$title_pdf_url" "$title_pdf_file" "Main Title PDF"; then
        ((title_files_downloaded++))
    fi
    
    # Main title HTML
    local title_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}.htm"
    local title_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}.htm"
    if download_with_retry "$title_html_url" "$title_html_file" "Main Title HTML"; then
        ((title_files_downloaded++))
    fi
    
    # Additional files (TOC, Front matter)
    local additional_files=(
        "toc.pdf:Table of Contents PDF"
        "toc.htm:Table of Contents HTML"
        "front.pdf:Front Matter PDF"
        "front.htm:Front Matter HTML"
    )
    
    for file_info in "${additional_files[@]}"; do
        local file_suffix=$(echo "$file_info" | cut -d: -f1)
        local description=$(echo "$file_info" | cut -d: -f2)
        local file_name="USCODE-${YEAR}-title${title_num}-${file_suffix}"
        local output_file="${title_dir}/${file_name}"
        
        # Determine URL based on file type
        if [[ "$file_suffix" == *.htm ]]; then
            local file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/${file_name}"
        else
            local file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/${file_name}"
        fi
        
        download_with_retry "$file_url" "$output_file" "$description"
    done
    
    # Download chapters
    download_chapters $title_num "$title_dir"
    
    if [ $title_files_downloaded -gt 0 ]; then
        ((SUCCESSFUL_DOWNLOADS++))
        echo -e "  ${GREEN}✅ Title $title_num completed successfully${NC}"
        log_message "SUCCESS: Title $title_num - $title_files_downloaded main files downloaded"
    else
        ((FAILED_DOWNLOADS++))
        echo -e "  ${RED}❌ Title $title_num failed${NC}"
        log_message "FAILED: Title $title_num - No files downloaded"
    fi
    
    # Brief pause between titles
    sleep $DELAY_BETWEEN_TITLES
}

# Main execution
echo -e "${BLUE}🚀 Starting USA Code download (Titles $START_TITLE-$END_TITLE)...${NC}"
echo -e "${PURPLE}📁 Download directory: $DOWNLOAD_DIR${NC}"
echo -e "${PURPLE}📅 Year: $YEAR${NC}"
echo -e "${PURPLE}⏱️  Delay between titles: ${DELAY_BETWEEN_TITLES}s${NC}\n"

# Change to the correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
mkdir -p "$DOWNLOAD_DIR"

# Start log
echo "[$(date)] Starting USA Code download - Titles $START_TITLE-$END_TITLE" > "$LOG_FILE"

# Process each title
for title_num in $(seq $START_TITLE $END_TITLE); do
    process_title $title_num
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DOWNLOAD COMPLETE                        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful title downloads: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed title downloads: $FAILED_DOWNLOADS${NC}"
echo -e "${BLUE}📄 Total files downloaded: $TOTAL_FILES_DOWNLOADED${NC}"
echo -e "${BLUE}📊 Total titles processed: $((END_TITLE - START_TITLE + 1))${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    completion_rate=$(( SUCCESSFUL_DOWNLOADS * 100 / (END_TITLE - START_TITLE + 1) ))
    echo -e "${CYAN}📈 Completion rate: ${completion_rate}%${NC}"
    
    # Calculate total downloaded size
    total_size=$(find "$DOWNLOAD_DIR" -name "*2023*" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "Unknown")
    echo -e "${BLUE}💾 Total download size: $total_size${NC}"
fi

echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"
echo -e "${PURPLE}📂 Files organized in: $DOWNLOAD_DIR/Title_XX_NAME/Chapter_XX/${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 USA Code titles 16-54 download completed!${NC}"
    echo -e "${CYAN}📁 Folder structure matches existing titles 1-15${NC}"
    echo -e "${YELLOW}📋 Ready for Phase 2 knowledge architecture implementation${NC}"
else
    echo -e "\n${RED}⚠️  No successful downloads completed${NC}"
    echo -e "${YELLOW}Please check the log file: $LOG_FILE${NC}"
fi

log_message "Download completed. Success rate: $(( SUCCESSFUL_DOWNLOADS * 100 / (END_TITLE - START_TITLE + 1) ))%"

exit 0