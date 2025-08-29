#!/bin/bash

# 🇺🇸 Enhanced USA Code Download Script - Titles 16-54 (2023 Edition)
# Downloads remaining USA Code titles with comprehensive folder structure and chapter organization
# Matches existing folder structure pattern from titles 1-15

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
YEAR="2023"  # Using 2023 for titles 16-54
DOWNLOAD_DIR="../USA-Codes"
START_TITLE=16
END_TITLE=54
MAX_RETRIES=3

# Counters and tracking
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_SIZE=0
CHAPTERS_DOWNLOADED=0
LOG_FILE="download_log_titles_16_54_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Enhanced USA Code Download - Titles 16-54 (2023)        ║${NC}"
echo -e "${BLUE}║               Comprehensive Folder Structure                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}📋 Downloading titles 16-54 with matching folder structure${NC}\n"

# Complete US Code Title Information
declare -A TITLE_NAMES
TITLE_NAMES[16]="CONSERVATION"
TITLE_NAMES[17]="COPYRIGHTS"
TITLE_NAMES[18]="CRIMES AND CRIMINAL PROCEDURE"
TITLE_NAMES[19]="CUSTOMS DUTIES"
TITLE_NAMES[20]="EDUCATION"
TITLE_NAMES[21]="FOOD AND DRUGS"
TITLE_NAMES[22]="FOREIGN RELATIONS AND INTERCOURSE"
TITLE_NAMES[23]="HIGHWAYS"
TITLE_NAMES[24]="HOSPITALS AND ASYLUMS"
TITLE_NAMES[25]="INDIANS"
TITLE_NAMES[26]="INTERNAL REVENUE CODE"
TITLE_NAMES[27]="INTOXICATING LIQUORS"
TITLE_NAMES[28]="JUDICIARY AND JUDICIAL PROCEDURE"
TITLE_NAMES[29]="LABOR"
TITLE_NAMES[30]="MINERAL LANDS AND MINING"
TITLE_NAMES[31]="MONEY AND FINANCE"
TITLE_NAMES[32]="NATIONAL GUARD"
TITLE_NAMES[33]="NAVIGATION AND NAVIGABLE WATERS"
TITLE_NAMES[34]="CRIME CONTROL AND LAW ENFORCEMENT"
TITLE_NAMES[35]="PATENTS"
TITLE_NAMES[36]="PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS"
TITLE_NAMES[37]="PAY AND ALLOWANCES OF THE UNIFORMED SERVICES"
TITLE_NAMES[38]="VETERANS' BENEFITS"
TITLE_NAMES[39]="POSTAL SERVICE"
TITLE_NAMES[40]="PUBLIC BUILDINGS, PROPERTY, AND WORKS"
TITLE_NAMES[41]="PUBLIC CONTRACTS"
TITLE_NAMES[42]="THE PUBLIC HEALTH AND WELFARE"
TITLE_NAMES[43]="PUBLIC LANDS"
TITLE_NAMES[44]="PUBLIC PRINTING AND DOCUMENTS"
TITLE_NAMES[45]="RAILROADS"
TITLE_NAMES[46]="SHIPPING"
TITLE_NAMES[47]="TELECOMMUNICATIONS"
TITLE_NAMES[48]="TERRITORIES AND INSULAR POSSESSIONS"
TITLE_NAMES[49]="TRANSPORTATION"
TITLE_NAMES[50]="WAR AND NATIONAL DEFENSE"
TITLE_NAMES[51]="NATIONAL AND COMMERCIAL SPACE PROGRAMS"
TITLE_NAMES[52]="VOTING AND ELECTIONS"
TITLE_NAMES[53]="SMALL BUSINESS"
TITLE_NAMES[54]="NATIONAL PARK SERVICE AND RELATED PROGRAMS"

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to create directory structure
create_title_structure() {
    local title_num=$1
    local title_name="$2"
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    
    echo -e "${BLUE}📁 Creating structure for Title $title_num: $title_name${NC}"
    mkdir -p "$title_dir"
    echo "$title_dir"
}

# Function to download file with retries
download_with_retry() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        echo -e "    ${YELLOW}Attempting download: $description (try $((retry_count + 1)))${NC}"
        
        if curl -L --fail --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
            local file_size=$(du -h "$output_path" | cut -f1)
            echo -e "    ${GREEN}✓ Downloaded: $description ($file_size)${NC}"
            return 0
        else
            ((retry_count++))
            if [ $retry_count -lt $MAX_RETRIES ]; then
                echo -e "    ${RED}✗ Failed, retrying in 2 seconds...${NC}"
                sleep 2
            else
                echo -e "    ${RED}✗ Failed after $MAX_RETRIES attempts: $description${NC}"
                log_message "FAILED: $url"
                return 1
            fi
        fi
    done
}

# Function to discover and download chapters for a title
download_chapters() {
    local title_num=$1
    local title_dir="$2"
    local chapters_found=0
    
    echo -e "  ${YELLOW}🔍 Discovering chapters for Title $title_num...${NC}"
    
    # Try common chapter numbers (1-50, some titles have many chapters)
    for chapter in {1..50}; do
        # Test if chapter exists
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if curl --head --silent --fail "$chapter_url" >/dev/null 2>&1; then
            ((chapters_found++))
            
            # Create chapter directory
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            # Download chapter PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            if download_with_retry "$chapter_url" "$pdf_file" "Chapter $chapter PDF"; then
                ((CHAPTERS_DOWNLOADED++))
            fi
            
            # Download chapter HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            download_with_retry "$html_url" "$html_file" "Chapter $chapter HTML"
        fi
        
        # Also try chapter names with letters (like 10A, 15A, etc.)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_letter="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if curl --head --silent --fail "$chapter_url_letter" >/dev/null 2>&1; then
                ((chapters_found++))
                
                # Create chapter directory with suffix
                local chapter_dir_letter="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_letter"
                
                # Download chapter PDF with suffix
                local pdf_file_letter="${chapter_dir_letter}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                if download_with_retry "$chapter_url_letter" "$pdf_file_letter" "Chapter ${chapter_letter} PDF"; then
                    ((CHAPTERS_DOWNLOADED++))
                fi
                
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
    local title_name="${TITLE_NAMES[$title_num]}"
    
    if [ -z "$title_name" ]; then
        echo -e "${RED}✗ Unknown title number: $title_num${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ [$title_num/54] Processing Title $title_num: $(echo "$title_name" | cut -c1-40)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Create title directory structure
    local title_dir=$(create_title_structure $title_num "$title_name")
    
    log_message "Processing Title $title_num: $title_name"
    
    # Download main title files (PDF, HTML, TOC, Front matter)
    local title_files=(
        "USCODE-${YEAR}-title${title_num}.pdf:Title PDF"
        "USCODE-${YEAR}-title${title_num}.htm:Title HTML"
        "USCODE-${YEAR}-title${title_num}-toc.pdf:Table of Contents PDF"
        "USCODE-${YEAR}-title${title_num}-toc.htm:Table of Contents HTML"
        "USCODE-${YEAR}-title${title_num}-front.pdf:Front Matter PDF"
        "USCODE-${YEAR}-title${title_num}-front.htm:Front Matter HTML"
    )
    
    local title_downloads=0
    for file_info in "${title_files[@]}"; do
        local file_name=$(echo "$file_info" | cut -d: -f1)
        local description=$(echo "$file_info" | cut -d: -f2)
        local file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/${file_name}"
        local output_file="${title_dir}/${file_name}"
        
        # Adjust URL for HTML files
        if [[ "$file_name" == *.htm ]]; then
            file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/${file_name}"
        fi
        
        if download_with_retry "$file_url" "$output_file" "$description"; then
            ((title_downloads++))
        fi
    done
    
    # Download chapters
    download_chapters $title_num "$title_dir"
    
    if [ $title_downloads -gt 0 ]; then
        ((SUCCESSFUL_DOWNLOADS++))
        echo -e "  ${GREEN}✅ Title $title_num completed successfully${NC}"
        log_message "SUCCESS: Title $title_num - $title_downloads main files downloaded"
    else
        ((FAILED_DOWNLOADS++))
        echo -e "  ${RED}❌ Title $title_num failed${NC}"
        log_message "FAILED: Title $title_num - No files downloaded"
    fi
}

# Main execution
echo -e "${BLUE}🚀 Starting USA Code download (Titles $START_TITLE-$END_TITLE)...${NC}"
echo -e "${PURPLE}📁 Download directory: $DOWNLOAD_DIR${NC}"
echo -e "${PURPLE}📅 Year: $YEAR${NC}\n"

# Change to the correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
mkdir -p "$DOWNLOAD_DIR"

# Process each title
for title_num in $(seq $START_TITLE $END_TITLE); do
    process_title $title_num
    
    # Brief pause between titles to be respectful to the server
    sleep 1
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DOWNLOAD COMPLETE                        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful title downloads: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed title downloads: $FAILED_DOWNLOADS${NC}"
echo -e "${BLUE}📚 Total chapters downloaded: $CHAPTERS_DOWNLOADED${NC}"
echo -e "${BLUE}📊 Total titles processed: $((END_TITLE - START_TITLE + 1))${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    completion_rate=$(( SUCCESSFUL_DOWNLOADS * 100 / (END_TITLE - START_TITLE + 1) ))
    echo -e "${CYAN}📈 Completion rate: ${completion_rate}%${NC}"
    
    # Calculate total downloaded size
    total_size=$(find "$DOWNLOAD_DIR" -name "*" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "Unknown")
    echo -e "${BLUE}💾 Total download size: $total_size${NC}"
fi

echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"
echo -e "${PURPLE}📂 Files organized in: $DOWNLOAD_DIR/Title_XX_NAME/Chapter_XX/${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 USA Code titles 16-54 download completed!${NC}"
    echo -e "${CYAN}📁 Folder structure matches existing titles 1-15${NC}"
else
    echo -e "\n${RED}⚠️  No successful downloads completed${NC}"
    echo -e "${YELLOW}Please check the log file: $LOG_FILE${NC}"
fi

echo -e "${YELLOW}📋 Next step: Verify folder structure and begin processing pipeline${NC}"

exit 0