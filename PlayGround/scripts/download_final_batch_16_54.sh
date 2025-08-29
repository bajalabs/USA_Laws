#!/bin/bash

# 🇺🇸 Final Batch USA Code Download - Titles 16-54 (2023 Edition) 
# This script will download all remaining titles with proper folder structure
# Uses optimized approach based on successful test run

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

# Counters
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_FILES=0

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Final Batch Download - USA Code Titles 16-54         ║${NC}"
echo -e "${BLUE}║                    2023 Edition                              ║${NC}"  
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
        *) echo "UNKNOWN" ;;
    esac
}

# Simple download function
download_file() {
    local url="$1" 
    local output_path="$2"
    local description="$3"
    
    mkdir -p "$(dirname "$output_path")"
    
    if curl -L --connect-timeout 30 --max-time 180 --silent --show-error "$url" -o "$output_path" 2>/dev/null; then
        if [ -f "$output_path" ] && [ -s "$output_path" ]; then
            local file_size=$(du -h "$output_path" | cut -f1)
            echo -e "    ${GREEN}✓ Downloaded: $description ($file_size)${NC}"
            ((TOTAL_FILES++))
            return 0
        else
            rm -f "$output_path" 2>/dev/null
            return 1
        fi
    fi
    return 1
}

# Process title
process_title() {
    local title_num=$1
    local title_name=$(get_title_name $title_num)
    local title_dir="${DOWNLOAD_DIR}/Title_$(printf "%02d" $title_num)_${title_name}"
    local title_files=0
    
    echo -e "\n${CYAN}[$title_num/54] Processing Title $title_num: $title_name${NC}"
    
    # Create directory
    mkdir -p "$title_dir"
    
    # Download main PDF
    local pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}.pdf"
    if download_file "$pdf_url" "$pdf_file" "Main PDF"; then
        ((title_files++))
    fi
    
    # Download main HTML
    local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}.htm"
    local html_file="${title_dir}/USCODE-${YEAR}-title${title_num}.htm"
    if download_file "$html_url" "$html_file" "Main HTML"; then
        ((title_files++))
    fi
    
    # Download TOC files
    local toc_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-toc.pdf"
    local toc_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}-toc.pdf"
    download_file "$toc_pdf_url" "$toc_pdf_file" "TOC PDF"
    
    local toc_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-toc.htm"
    local toc_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}-toc.htm"
    download_file "$toc_html_url" "$toc_html_file" "TOC HTML"
    
    # Download Front Matter files
    local front_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-front.pdf"
    local front_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}-front.pdf"
    download_file "$front_pdf_url" "$front_pdf_file" "Front PDF"
    
    local front_html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-front.htm"
    local front_html_file="${title_dir}/USCODE-${YEAR}-title${title_num}-front.htm"
    download_file "$front_html_url" "$front_html_file" "Front HTML"
    
    if [ $title_files -gt 0 ]; then
        ((SUCCESSFUL_DOWNLOADS++))
        echo -e "  ${GREEN}✅ Title $title_num completed${NC}"
    else
        ((FAILED_DOWNLOADS++))
        echo -e "  ${RED}❌ Title $title_num failed${NC}"
    fi
    
    sleep 1
}

# Main execution
echo -e "${BLUE}🚀 Starting final batch download...${NC}"
echo -e "${PURPLE}📁 Target directory: $DOWNLOAD_DIR${NC}"
echo -e "${PURPLE}📅 Year: $YEAR${NC}"
echo -e "${PURPLE}📊 Titles: $START_TITLE-$END_TITLE${NC}\n"

# Change directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA_Laws"
mkdir -p "$DOWNLOAD_DIR"

# Process all titles
for title_num in $(seq $START_TITLE $END_TITLE); do
    process_title $title_num
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   BATCH DOWNLOAD COMPLETE                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful titles: $SUCCESSFUL_DOWNLOADS${NC}"
echo -e "${RED}❌ Failed titles: $FAILED_DOWNLOADS${NC}"
echo -e "${BLUE}📄 Total files downloaded: $TOTAL_FILES${NC}"

total_titles=$((END_TITLE - START_TITLE + 1))
success_rate=$(( SUCCESSFUL_DOWNLOADS * 100 / total_titles ))
echo -e "${CYAN}📈 Success rate: ${success_rate}%${NC}"

# Verify final structure
echo -e "\n${BLUE}📊 Final verification:${NC}"
title_count=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type d -name "Title_*" | wc -l)
echo -e "${CYAN}Total title directories: $title_count${NC}"

if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
    echo -e "\n${GREEN}🎉 USA Code titles 16-54 download completed successfully!${NC}"
    echo -e "${YELLOW}📋 Ready for Phase 2 implementation${NC}"
else
    echo -e "\n${RED}⚠️  Download encountered issues${NC}"
fi

echo -e "${PURPLE}✨ Phase 1 Data Collection Complete! ✨${NC}"