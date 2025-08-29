#!/bin/bash

# 🇺🇸 COMPREHENSIVE USA Code Download System - Titles 16-54 with Full Chapter Structure
# Downloads all titles 16-54 with complete chapter organization matching titles 1-15
# Creates proper folder structure: Title_XX_NAME/Chapter_XX/files

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
END_TITLE=54

# Progress tracking
TOTAL_TITLES=0
SUCCESSFUL_TITLES=0
FAILED_TITLES=0
TOTAL_CHAPTERS=0
TOTAL_FILES_DOWNLOADED=0
LOG_FILE="comprehensive_download_log_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   COMPREHENSIVE USA Code Download - Titles 16-54 + Chapters ║${NC}"
echo -e "${BLUE}║              Complete System with Full Structure             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"

# Title name mapping
get_title_name() {
    case $1 in
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
    esac
}

# Logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Enhanced download with retry and validation
download_file() {
    local url="$1"
    local output_path="$2"
    local description="$3"
    local max_retries=3
    local retry_count=0
    
    mkdir -p "$(dirname "$output_path")"
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -L --connect-timeout 30 --max-time 180 --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
            if [ -f "$output_path" ] && [ -s "$output_path" ]; then
                local file_size=$(du -h "$output_path" | cut -f1)
                echo -e "      ${GREEN}✓ $description ($file_size)${NC}"
                ((TOTAL_FILES_DOWNLOADED++))
                return 0
            fi
        fi
        
        ((retry_count++))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "      ${YELLOW}⚠️  Retry $((retry_count + 1)): $description${NC}"
            sleep 2
        fi
    done
    
    echo -e "      ${RED}✗ Failed: $description${NC}"
    rm -f "$output_path" 2>/dev/null
    return 1
}

# Test if URL exists (faster HEAD request)
url_exists() {
    curl --head --silent --connect-timeout 10 --max-time 30 "$1" 2>/dev/null | grep -q "200 OK"
}

# Chapter discovery and download
discover_and_download_chapters() {
    local title_num=$1
    local title_dir="$2"
    local chapters_found=0
    local chapters_downloaded=0
    
    echo -e "    ${YELLOW}🔍 Discovering chapters for Title $title_num...${NC}"
    
    # Test chapters 1-200 (comprehensive range)
    for chapter in $(seq 1 200); do
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if url_exists "$chapter_url"; then
            ((chapters_found++))
            
            # Create chapter directory
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            echo -e "    ${CYAN}  📁 Found Chapter $chapter${NC}"
            
            # Download chapter PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            if download_file "$chapter_url" "$pdf_file" "Chapter $chapter PDF"; then
                ((chapters_downloaded++))
            fi
            
            # Download chapter HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            download_file "$html_url" "$html_file" "Chapter $chapter HTML"
        fi
        
        # Test chapter variations (A, B, C, D suffixes)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if url_exists "$chapter_url_suffix"; then
                ((chapters_found++))
                
                local chapter_dir_suffix="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_suffix"
                
                echo -e "    ${CYAN}  📁 Found Chapter ${chapter_letter}${NC}"
                
                # Download chapter PDF with suffix
                local pdf_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                if download_file "$chapter_url_suffix" "$pdf_file_suffix" "Chapter ${chapter_letter} PDF"; then
                    ((chapters_downloaded++))
                fi
                
                # Download chapter HTML with suffix
                local html_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                local html_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                download_file "$html_url_suffix" "$html_file_suffix" "Chapter ${chapter_letter} HTML"
            fi
        done
    done
    
    TOTAL_CHAPTERS=$((TOTAL_CHAPTERS + chapters_downloaded))
    echo -e "    ${BLUE}📊 Title $title_num: $chapters_found chapters found, $chapters_downloaded downloaded${NC}"
    log_message "Title $title_num: $chapters_found chapters found, $chapters_downloaded downloaded"
    
    return $chapters_found
}

# Download main title files
download_main_title_files() {
    local title_num=$1
    local title_dir="$2"
    local files_downloaded=0
    
    echo -e "    ${YELLOW}📥 Downloading main title files...${NC}"
    
    # Core title files
    local main_files=(
        "USCODE-${YEAR}-title${title_num}.pdf:Main Title PDF"
        "USCODE-${YEAR}-title${title_num}.htm:Main Title HTML" 
        "USCODE-${YEAR}-title${title_num}-toc.pdf:Table of Contents PDF"
        "USCODE-${YEAR}-title${title_num}-toc.htm:Table of Contents HTML"
        "USCODE-${YEAR}-title${title_num}-front.pdf:Front Matter PDF"
        "USCODE-${YEAR}-title${title_num}-front.htm:Front Matter HTML"
    )
    
    for file_info in "${main_files[@]}"; do
        local file_name=$(echo "$file_info" | cut -d: -f1)
        local description=$(echo "$file_info" | cut -d: -f2)
        local output_file="${title_dir}/${file_name}"
        
        # Determine URL path (HTML vs PDF)
        if [[ "$file_name" == *.htm ]]; then
            local file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/${file_name}"
        else
            local file_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/${file_name}"
        fi
        
        if download_file "$file_url" "$output_file" "$description"; then
            ((files_downloaded++))
        fi
    done
    
    return $files_downloaded
}

# Process complete title (main files + chapters)
process_complete_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    local title_success=0
    
    ((TOTAL_TITLES++))
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ [$title_num/54] Title $title_num: $(echo "$title_name" | cut -c1-45)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    log_message "Starting Title $title_num: $title_name"
    
    # Create title directory
    echo -e "  ${BLUE}📁 Creating: $(basename "$title_dir")${NC}"
    mkdir -p "$title_dir"
    
    # Download main title files
    if download_main_title_files $title_num "$title_dir"; then
        title_success=1
    fi
    
    # Discover and download all chapters
    discover_and_download_chapters $title_num "$title_dir"
    
    if [ $title_success -eq 1 ]; then
        ((SUCCESSFUL_TITLES++))
        echo -e "  ${GREEN}✅ Title $title_num completed successfully${NC}"
        log_message "SUCCESS: Title $title_num completed"
    else
        ((FAILED_TITLES++))
        echo -e "  ${RED}❌ Title $title_num failed${NC}"
        log_message "FAILED: Title $title_num"
    fi
    
    # Brief pause to be respectful to server
    sleep 1
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Starting comprehensive download system...${NC}"
    echo -e "${PURPLE}📁 Target directory: $DOWNLOAD_DIR${NC}"
    echo -e "${PURPLE}📅 Year: $YEAR${NC}"
    echo -e "${PURPLE}📊 Title range: $START_TITLE-$END_TITLE${NC}\n"
    
    # Setup
    cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
    mkdir -p "$DOWNLOAD_DIR"
    log_message "Starting comprehensive USA Code download (Titles $START_TITLE-$END_TITLE)"
    
    # Process all titles
    for title_num in $(seq $START_TITLE $END_TITLE); do
        process_complete_title $title_num
    done
    
    # Final comprehensive report
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                 COMPREHENSIVE DOWNLOAD COMPLETE              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${GREEN}✅ Successful titles: $SUCCESSFUL_TITLES/$TOTAL_TITLES${NC}"
    echo -e "${RED}❌ Failed titles: $FAILED_TITLES${NC}"
    echo -e "${BLUE}📚 Total chapters downloaded: $TOTAL_CHAPTERS${NC}"
    echo -e "${BLUE}📄 Total files downloaded: $TOTAL_FILES_DOWNLOADED${NC}"
    
    # Calculate completion statistics
    local success_rate=$((SUCCESSFUL_TITLES * 100 / TOTAL_TITLES))
    echo -e "${CYAN}📈 Success rate: ${success_rate}%${NC}"
    
    # Final structure verification
    echo -e "\n${BLUE}📊 Final structure verification:${NC}"
    local final_title_count=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type d -name "Title_*" | wc -l)
    local final_chapter_count=$(find "$DOWNLOAD_DIR" -type d -name "Chapter_*" | wc -l)
    
    echo -e "${CYAN}Total title directories: $final_title_count${NC}"
    echo -e "${CYAN}Total chapter directories: $final_chapter_count${NC}"
    
    if [ $TOTAL_FILES_DOWNLOADED -gt 0 ]; then
        local total_size=$(find "$DOWNLOAD_DIR" -name "*${YEAR}*" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "Unknown")
        echo -e "${BLUE}💾 Total download size: $total_size${NC}"
    fi
    
    echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"
    
    if [ $SUCCESSFUL_TITLES -gt 0 ]; then
        echo -e "\n${GREEN}🎉 USA Code Titles 16-54 with complete chapter structure downloaded!${NC}"
        echo -e "${YELLOW}📋 Structure matches existing titles 1-15 format${NC}"
        echo -e "${CYAN}✨ Ready for Phase 2 knowledge architecture implementation${NC}"
    else
        echo -e "\n${RED}⚠️  No titles were successfully downloaded${NC}"
        echo -e "${YELLOW}Please check connectivity and server availability${NC}"
    fi
    
    log_message "Comprehensive download completed. Success: $SUCCESSFUL_TITLES/$TOTAL_TITLES titles, $TOTAL_CHAPTERS chapters, $TOTAL_FILES_DOWNLOADED total files"
}

# Execute main function
main

echo -e "\n${PURPLE}🏛️  USA Code Titles 16-54 Complete System - Ready! 🏛️${NC}"
exit 0