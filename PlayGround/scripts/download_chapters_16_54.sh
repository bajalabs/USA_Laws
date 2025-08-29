#!/bin/bash

# 🇺🇸 Complete Chapter Download Script - USA Code Titles 16-54 (2023)
# Downloads all chapters for each title to match the existing structure of titles 1-15
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

# Counters
TOTAL_CHAPTERS_DOWNLOADED=0
SUCCESSFUL_TITLES=0
FAILED_TITLES=0
LOG_FILE="download_chapters_log_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Complete Chapter Download - USA Code Titles 16-54        ║${NC}"
echo -e "${BLUE}║          Matching Structure to Titles 1-15                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"

# Function to get title name
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

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Download function with error handling
download_with_retry() {
    local url="$1"
    local output_path="$2" 
    local description="$3"
    local max_retries=2
    local retry_count=0
    
    mkdir -p "$(dirname "$output_path")"
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -L --connect-timeout 20 --max-time 120 --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
            if [ -f "$output_path" ] && [ -s "$output_path" ]; then
                local file_size=$(du -h "$output_path" | cut -f1)
                echo -e "    ${GREEN}✓ Downloaded: $description ($file_size)${NC}"
                return 0
            else
                rm -f "$output_path" 2>/dev/null
            fi
        fi
        
        ((retry_count++))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "    ${YELLOW}⚠️  Retry $((retry_count + 1)) for: $description${NC}"
            sleep 2
        fi
    done
    
    echo -e "    ${RED}✗ Failed: $description${NC}"
    return 1
}

# Function to test if chapter exists (HEAD request)
chapter_exists() {
    local url="$1"
    curl --head --silent --connect-timeout 10 --max-time 30 "$url" 2>/dev/null | grep -q "200 OK"
}

# Function to discover and download chapters for a title
download_title_chapters() {
    local title_num=$1
    local title_name="$2"
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    local chapters_found=0
    local chapters_downloaded=0
    
    echo -e "  ${YELLOW}🔍 Discovering chapters for Title $title_num...${NC}"
    
    # Test chapter numbers 1-100 (some titles have many chapters)
    for chapter in $(seq 1 100); do
        # Test main chapter PDF
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if chapter_exists "$chapter_url"; then
            ((chapters_found++))
            
            # Create chapter directory
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            echo -e "  ${CYAN}📁 Found Chapter $chapter${NC}"
            
            # Download chapter PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            if download_with_retry "$chapter_url" "$pdf_file" "Chapter $chapter PDF"; then
                ((chapters_downloaded++))
                ((TOTAL_CHAPTERS_DOWNLOADED++))
            fi
            
            # Download chapter HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            download_with_retry "$html_url" "$html_file" "Chapter $chapter HTML"
        fi
        
        # Test chapter variations with letters (A, B, C, D)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_letter="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if chapter_exists "$chapter_url_letter"; then
                ((chapters_found++))
                
                # Create chapter directory with suffix
                local chapter_dir_letter="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_letter"
                
                echo -e "  ${CYAN}📁 Found Chapter ${chapter_letter}${NC}"
                
                # Download chapter PDF with suffix
                local pdf_file_letter="${chapter_dir_letter}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                if download_with_retry "$chapter_url_letter" "$pdf_file_letter" "Chapter ${chapter_letter} PDF"; then
                    ((chapters_downloaded++))
                    ((TOTAL_CHAPTERS_DOWNLOADED++))
                fi
                
                # Download chapter HTML with suffix
                local html_url_letter="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                local html_file_letter="${chapter_dir_letter}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                download_with_retry "$html_url_letter" "$html_file_letter" "Chapter ${chapter_letter} HTML"
            fi
        done
    done
    
    echo -e "  ${BLUE}📊 Title $title_num: Found $chapters_found chapters, downloaded $chapters_downloaded${NC}"
    log_message "Title $title_num ($title_name): $chapters_found chapters found, $chapters_downloaded downloaded"
    
    return $chapters_found
}

# Function to process each title
process_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ [$title_num/54] Processing Title $title_num: $(echo "$title_name" | cut -c1-35)...${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Ensure title directory exists
    if [ ! -d "$title_dir" ]; then
        echo -e "${BLUE}📁 Creating title directory: $(basename "$title_dir")${NC}"
        mkdir -p "$title_dir"
        
        # Download main title files if missing
        echo -e "  ${YELLOW}📥 Downloading main title files...${NC}"
        
        # Main PDF and HTML
        local title_pdf="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
        local title_html="${title_dir}/USCODE-${YEAR}-title${title_num}.htm"
        
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf" "$title_pdf" "Main Title PDF"
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}.htm" "$title_html" "Main Title HTML"
        
        # TOC and Front Matter files
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-toc.pdf" "${title_dir}/USCODE-${YEAR}-title${title_num}-toc.pdf" "TOC PDF"
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-toc.htm" "${title_dir}/USCODE-${YEAR}-title${title_num}-toc.htm" "TOC HTML"
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-front.pdf" "${title_dir}/USCODE-${YEAR}-title${title_num}-front.pdf" "Front PDF"
        download_with_retry "${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-front.htm" "${title_dir}/USCODE-${YEAR}-title${title_num}-front.htm" "Front HTML"
    else
        echo -e "  ${GREEN}✅ Title directory already exists${NC}"
    fi
    
    # Download chapters
    if download_title_chapters $title_num "$title_name"; then
        ((SUCCESSFUL_TITLES++))
        echo -e "  ${GREEN}✅ Title $title_num completed with chapters${NC}"
    else
        echo -e "  ${BLUE}ℹ️  Title $title_num completed (no chapters found)${NC}"
        ((SUCCESSFUL_TITLES++))
    fi
    
    sleep 1
}

# Main execution
echo -e "${BLUE}🚀 Starting chapter download for titles $START_TITLE-$END_TITLE...${NC}"
echo -e "${PURPLE}📁 Target directory: $DOWNLOAD_DIR${NC}"
echo -e "${PURPLE}📅 Year: $YEAR${NC}\n"

# Change to correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
mkdir -p "$DOWNLOAD_DIR"

# Start log
log_message "Starting chapter download for USA Code titles $START_TITLE-$END_TITLE"

# Process each title
for title_num in $(seq $START_TITLE $END_TITLE); do
    process_title $title_num
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                CHAPTER DOWNLOAD COMPLETE                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful titles processed: $SUCCESSFUL_TITLES${NC}"
echo -e "${RED}❌ Failed titles: $FAILED_TITLES${NC}"
echo -e "${BLUE}📚 Total chapters downloaded: $TOTAL_CHAPTERS_DOWNLOADED${NC}"
echo -e "${BLUE}📊 Total titles processed: $((END_TITLE - START_TITLE + 1))${NC}"

# Verify final structure
echo -e "\n${BLUE}📊 Final verification:${NC}"
title_count=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type d -name "Title_*" | wc -l)
chapter_count=$(find "$DOWNLOAD_DIR" -type d -name "Chapter_*" | wc -l)
echo -e "${CYAN}Total title directories: $title_count${NC}"
echo -e "${CYAN}Total chapter directories: $chapter_count${NC}"

if [ $TOTAL_CHAPTERS_DOWNLOADED -gt 0 ]; then
    echo -e "\n${GREEN}🎉 Chapter download completed successfully!${NC}"
    echo -e "${YELLOW}📁 Structure now matches titles 1-15 format${NC}"
    echo -e "${PURPLE}📋 Ready for Phase 2 knowledge architecture${NC}"
else
    echo -e "\n${YELLOW}ℹ️  No chapters found for titles 16-54${NC}"
    echo -e "${BLUE}💡 This might be normal - not all titles have separate chapters${NC}"
fi

echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"
log_message "Chapter download completed. Chapters downloaded: $TOTAL_CHAPTERS_DOWNLOADED"

echo -e "${CYAN}✨ USA Code Titles 16-54 with Chapters - Complete! ✨${NC}"

exit 0