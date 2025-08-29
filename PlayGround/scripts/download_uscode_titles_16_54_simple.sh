#!/bin/bash

# 🇺🇸 USA Code Download Script - Titles 16-54 (2023 Edition)
# Downloads remaining USA Code titles with comprehensive folder structure
# Compatible with standard shell without associative arrays

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
CHAPTERS_DOWNLOADED=0
LOG_FILE="download_log_titles_16_54_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     USA Code Download - Titles 16-54 (2023 Edition)        ║${NC}"
echo -e "${BLUE}║               Comprehensive Folder Structure                 ║${NC}"
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
        36) echo "PATRIOTIC AND NATIONAL OBSERVANCES" ;;
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
        echo -e "    ${YELLOW}Downloading: $description (try $((retry_count + 1)))${NC}"
        
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
                rm -f "$output_path" 2>/dev/null
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
    for chapter in $(seq 1 50); do
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
    local title_name=$(get_title_name $title_num)
    
    if [ "$title_name" = "UNKNOWN" ]; then
        echo -e "${RED}✗ Unknown title number: $title_num${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ [$title_num/54] Processing Title $title_num: $(echo "$title_name" | cut -c1-30)...${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Create title directory structure
    local title_dir=$(create_title_structure $title_num "$title_name")
    
    log_message "Processing Title $title_num: $title_name"
    
    # Download main title files (PDF, HTML, TOC, Front matter)
    local title_downloads=0
    
    # Main title PDF
    local title_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local title_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
    if download_with_retry "$title_pdf_url" "$title_pdf_file" "Main Title PDF"; then
        ((title_downloads++))
    fi
    
    # Main title HTML
    local title_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}.htm"
    local title_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}.htm"
    if download_with_retry "$title_html_url" "$title_html_file" "Main Title HTML"; then
        ((title_downloads++))
    fi
    
    # Table of Contents PDF
    local toc_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-toc.pdf"
    local toc_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}-toc.pdf"
    download_with_retry "$toc_pdf_url" "$toc_pdf_file" "TOC PDF"
    
    # Table of Contents HTML
    local toc_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-toc.htm"
    local toc_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}-toc.htm"
    download_with_retry "$toc_html_url" "$toc_html_file" "TOC HTML"
    
    # Front Matter PDF
    local front_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-front.pdf"
    local front_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}-front.pdf"
    download_with_retry "$front_pdf_url" "$front_pdf_file" "Front Matter PDF"
    
    # Front Matter HTML
    local front_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-front.htm"
    local front_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}-front.htm"
    download_with_retry "$front_html_url" "$front_html_file" "Front Matter HTML"
    
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
    sleep 2
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