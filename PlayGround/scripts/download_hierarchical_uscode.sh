#!/bin/bash

# 🇺🇸 USA Code Hierarchical Download Script
# Requires bash 4+ for associative arrays - use /usr/local/bin/bash on macOS
# Downloads all available titles and chapters of the United States Code from GovInfo.gov
# Creates proper Title/Chapter folder structure as requested
# URL Pattern: https://www.govinfo.gov/content/pkg/USCODE-2024-title[X]/pdf/USCODE-2024-title[X]-chap[Y].pdf

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
BASE_DIR="../data"
MAX_TITLES=54

# Counters
TOTAL_DOWNLOADS=0
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_SIZE=0

echo -e "${CYAN}"
cat << "EOF"
🇺🇸 ═══════════════════════════════════════════════════════════════
   USA CODE HIERARCHICAL DOWNLOAD SYSTEM
   Creating Title/Chapter folder structure with individual files
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

# US Code Title Information (all 54 titles)
declare -A TITLE_NAMES
TITLE_NAMES[1]="General Provisions"
TITLE_NAMES[2]="The Congress"
TITLE_NAMES[3]="The President"
TITLE_NAMES[4]="Flag and Seal, Seat of Government, and the States"
TITLE_NAMES[5]="Government Organization and Employees"
TITLE_NAMES[6]="Domestic Security"
TITLE_NAMES[7]="Agriculture"
TITLE_NAMES[8]="Aliens and Nationality"
TITLE_NAMES[9]="Arbitration"
TITLE_NAMES[10]="Armed Forces"
TITLE_NAMES[11]="Bankruptcy"
TITLE_NAMES[12]="Banks and Banking"
TITLE_NAMES[13]="Census"
TITLE_NAMES[14]="Coast Guard"
TITLE_NAMES[15]="Commerce and Trade"
TITLE_NAMES[16]="Conservation"
TITLE_NAMES[17]="Copyrights"
TITLE_NAMES[18]="Crimes and Criminal Procedure"
TITLE_NAMES[19]="Customs Duties"
TITLE_NAMES[20]="Education"
TITLE_NAMES[21]="Food and Drugs"
TITLE_NAMES[22]="Foreign Relations and Intercourse"
TITLE_NAMES[23]="Highways"
TITLE_NAMES[24]="Hospitals and Asylums"
TITLE_NAMES[25]="Indians"
TITLE_NAMES[26]="Internal Revenue Code"
TITLE_NAMES[27]="Intoxicating Liquors"
TITLE_NAMES[28]="Judiciary and Judicial Procedure"
TITLE_NAMES[29]="Labor"
TITLE_NAMES[30]="Mineral Lands and Mining"
TITLE_NAMES[31]="Money and Finance"
TITLE_NAMES[32]="National Guard"
TITLE_NAMES[33]="Navigation and Navigable Waters"
TITLE_NAMES[34]="Navy"
TITLE_NAMES[35]="Patents"
TITLE_NAMES[36]="Patriotic and National Observances"
TITLE_NAMES[37]="Pay and Allowances of the Uniformed Services"
TITLE_NAMES[38]="Veterans' Benefits"
TITLE_NAMES[39]="Postal Service"
TITLE_NAMES[40]="Public Buildings, Property, and Works"
TITLE_NAMES[41]="Public Contracts"
TITLE_NAMES[42]="The Public Health and Welfare"
TITLE_NAMES[43]="Public Lands"
TITLE_NAMES[44]="Public Printing and Documents"
TITLE_NAMES[45]="Railroads"
TITLE_NAMES[46]="Shipping"
TITLE_NAMES[47]="Telecommunications"
TITLE_NAMES[48]="Territories and Insular Possessions"
TITLE_NAMES[49]="Transportation"
TITLE_NAMES[50]="War and National Defense"
TITLE_NAMES[51]="National and Commercial Space Programs"
TITLE_NAMES[52]="Voting and Elections"
TITLE_NAMES[53]="Small Business"
TITLE_NAMES[54]="National Park Service and Related Programs"

# Chapter count mapping (based on analysis - we'll discover actual chapters dynamically)
declare -A TITLE_MAX_CHAPTERS
# These are estimates - we'll discover actual chapters during download
TITLE_MAX_CHAPTERS[1]=5
TITLE_MAX_CHAPTERS[2]=30
TITLE_MAX_CHAPTERS[3]=5
TITLE_MAX_CHAPTERS[4]=5
TITLE_MAX_CHAPTERS[5]=90
TITLE_MAX_CHAPTERS[6]=10
TITLE_MAX_CHAPTERS[7]=110
TITLE_MAX_CHAPTERS[8]=15
TITLE_MAX_CHAPTERS[9]=5
TITLE_MAX_CHAPTERS[10]=280
TITLE_MAX_CHAPTERS[11]=15
TITLE_MAX_CHAPTERS[12]=55
TITLE_MAX_CHAPTERS[13]=10
TITLE_MAX_CHAPTERS[14]=55
TITLE_MAX_CHAPTERS[15]=123  # We know this one exactly from analysis
TITLE_MAX_CHAPTERS[16]=60
TITLE_MAX_CHAPTERS[17]=15
TITLE_MAX_CHAPTERS[18]=230
TITLE_MAX_CHAPTERS[19]=30
TITLE_MAX_CHAPTERS[20]=80
TITLE_MAX_CHAPTERS[21]=25
TITLE_MAX_CHAPTERS[22]=100
TITLE_MAX_CHAPTERS[23]=6
TITLE_MAX_CHAPTERS[24]=10
TITLE_MAX_CHAPTERS[25]=50
TITLE_MAX_CHAPTERS[26]=100
TITLE_MAX_CHAPTERS[27]=10
TITLE_MAX_CHAPTERS[28]=190
TITLE_MAX_CHAPTERS[29]=30
TITLE_MAX_CHAPTERS[30]=30
TITLE_MAX_CHAPTERS[31]=100
TITLE_MAX_CHAPTERS[32]=10
TITLE_MAX_CHAPTERS[33]=60
TITLE_MAX_CHAPTERS[34]=90
TITLE_MAX_CHAPTERS[35]=40
TITLE_MAX_CHAPTERS[36]=30
TITLE_MAX_CHAPTERS[37]=20
TITLE_MAX_CHAPTERS[38]=80
TITLE_MAX_CHAPTERS[39]=40
TITLE_MAX_CHAPTERS[40]=90
TITLE_MAX_CHAPTERS[41]=90
TITLE_MAX_CHAPTERS[42]=160
TITLE_MAX_CHAPTERS[43]=50
TITLE_MAX_CHAPTERS[44]=40
TITLE_MAX_CHAPTERS[45]=25
TITLE_MAX_CHAPTERS[46]=200
TITLE_MAX_CHAPTERS[47]=20
TITLE_MAX_CHAPTERS[48]=20
TITLE_MAX_CHAPTERS[49]=600
TITLE_MAX_CHAPTERS[50]=60
TITLE_MAX_CHAPTERS[51]=60
TITLE_MAX_CHAPTERS[52]=30
TITLE_MAX_CHAPTERS[53]=50
TITLE_MAX_CHAPTERS[54]=100

# Function to check if title exists
check_title_exists() {
    local title_num=$1
    local check_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    
    if curl -I "$check_url" 2>/dev/null | head -1 | grep -q "200 OK"; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Function to download chapter file
download_chapter() {
    local title_num=$1
    local chapter_num=$2
    local title_dir=$3
    
    # Create chapter directory
    local chapter_dir="${title_dir}/Chapter_$(printf "%03d" $chapter_num)"
    mkdir -p "$chapter_dir"
    
    # Try different chapter number formats
    local formats=("$chapter_num" "$(printf "%d" $chapter_num)")
    
    for format in "${formats[@]}"; do
        # Try PDF first
        local pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${format}.pdf"
        local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${format}.pdf"
        
        echo -e "    ${BLUE}Trying Chapter ${chapter_num} PDF...${NC}"
        
        if curl -I "$pdf_url" 2>/dev/null | head -1 | grep -q "200 OK"; then
            echo -e "    ${GREEN}✓ Found Chapter ${chapter_num} PDF${NC}"
            
            # Download with progress bar
            if curl -L -o "$pdf_file" "$pdf_url" --progress-bar; then
                # Get file size
                local file_size=$(stat -f%z "$pdf_file" 2>/dev/null || stat -c%s "$pdf_file" 2>/dev/null || echo "0")
                local size_mb=$(echo "scale=2; $file_size/1024/1024" | bc 2>/dev/null || echo "0")
                
                echo -e "    ${GREEN}✓ Downloaded: $(basename "$pdf_file") (${size_mb}MB)${NC}"
                
                SUCCESSFUL_DOWNLOADS=$((SUCCESSFUL_DOWNLOADS + 1))
                TOTAL_SIZE=$((TOTAL_SIZE + file_size))
                
                # Try to get HTML version too
                local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${format}.htm"
                local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${format}.htm"
                
                if curl -I "$html_url" 2>/dev/null | head -1 | grep -q "200 OK"; then
                    echo -e "    ${BLUE}Found HTML version, downloading...${NC}"
                    if curl -L -o "$html_file" "$html_url" --progress-bar; then
                        echo -e "    ${GREEN}✓ Downloaded: $(basename "$html_file")${NC}"
                        SUCCESSFUL_DOWNLOADS=$((SUCCESSFUL_DOWNLOADS + 1))
                    fi
                fi
                
                return 0
            else
                echo -e "    ${RED}✗ Failed to download PDF${NC}"
                rm -f "$pdf_file"
                FAILED_DOWNLOADS=$((FAILED_DOWNLOADS + 1))
                return 1
            fi
        fi
    done
    
    return 1  # Chapter not found
}

# Function to process a title
process_title() {
    local title_num=$1
    local title_name="${TITLE_NAMES[$title_num]}"
    local max_chapters="${TITLE_MAX_CHAPTERS[$title_num]}"
    
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}📖 TITLE $title_num: $title_name${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if title exists
    if ! check_title_exists "$title_num"; then
        echo -e "${YELLOW}⚠ Title $title_num not available, skipping...${NC}"
        return
    fi
    
    # Create title directory
    local title_dir="${BASE_DIR}/Title_$(printf "%02d" $title_num)_$(echo "$title_name" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/__*/_/g' | sed 's/_$//')"
    mkdir -p "$title_dir"
    
    echo -e "${CYAN}📁 Created directory: $title_dir${NC}"
    
    # Download title overview (full title PDF)
    local title_pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local title_pdf_file="${title_dir}/USCODE-${YEAR}-title${title_num}-COMPLETE.pdf"
    
    echo -e "${BLUE}📥 Downloading complete title PDF...${NC}"
    if curl -L -o "$title_pdf_file" "$title_pdf_url" --progress-bar; then
        local file_size=$(stat -f%z "$title_pdf_file" 2>/dev/null || stat -c%s "$title_pdf_file" 2>/dev/null || echo "0")
        local size_mb=$(echo "scale=2; $file_size/1024/1024" | bc 2>/dev/null || echo "0")
        echo -e "${GREEN}✓ Downloaded complete title: ${size_mb}MB${NC}"
        SUCCESSFUL_DOWNLOADS=$((SUCCESSFUL_DOWNLOADS + 1))
        TOTAL_SIZE=$((TOTAL_SIZE + file_size))
    else
        echo -e "${RED}✗ Failed to download complete title PDF${NC}"
        FAILED_DOWNLOADS=$((FAILED_DOWNLOADS + 1))
    fi
    
    # Download individual chapters
    echo -e "${CYAN}📚 Downloading individual chapters (up to $max_chapters)...${NC}"
    local chapters_found=0
    local consecutive_failures=0
    
    for ((chapter=1; chapter<=max_chapters; chapter++)); do
        TOTAL_DOWNLOADS=$((TOTAL_DOWNLOADS + 1))
        
        if download_chapter "$title_num" "$chapter" "$title_dir"; then
            chapters_found=$((chapters_found + 1))
            consecutive_failures=0
        else
            consecutive_failures=$((consecutive_failures + 1))
            
            # If we have 10 consecutive failures, assume no more chapters
            if [ $consecutive_failures -ge 10 ] && [ $chapters_found -gt 0 ]; then
                echo -e "${YELLOW}⚠ No more chapters found after 10 consecutive failures, stopping search for Title $title_num${NC}"
                break
            fi
        fi
        
        # Small delay to be respectful to the server
        sleep 0.5
    done
    
    echo -e "${GREEN}✓ Title $title_num complete: $chapters_found chapters found${NC}"
    
    # Create metadata file
    cat > "${title_dir}/METADATA.txt" << EOF
USA CODE TITLE $title_num METADATA
====================================
Title: $title_name
Download Date: $(date)
Source: GovInfo.gov
URL Pattern: ${BASE_URL}/USCODE-${YEAR}-title${title_num}/
Chapters Found: $chapters_found
Total Files: $((chapters_found * 2 + 1))  # PDF + HTML per chapter + complete title PDF

Files:
- USCODE-${YEAR}-title${title_num}-COMPLETE.pdf (Complete title)
$(for ((i=1; i<=chapters_found; i++)); do echo "- Chapter_$(printf "%03d" $i)/ (Individual chapter files)"; done)
EOF
}

# Main execution
main() {
    echo -e "${CYAN}🚀 Starting USA Code hierarchical download...${NC}"
    echo -e "${CYAN}📅 Year: $YEAR${NC}"
    echo -e "${CYAN}🎯 Target: All 54 titles with chapter breakdown${NC}"
    echo -e "${CYAN}💾 Output: $BASE_DIR${NC}"
    echo ""
    
    # Create base directory
    mkdir -p "$BASE_DIR"
    
    # Process titles (start with a few for testing, then expand)
    local test_titles=(1 2 3 15)  # Start with these for testing
    
    echo -e "${YELLOW}🧪 Testing with titles: ${test_titles[*]}${NC}"
    echo -e "${YELLOW}📝 After successful test, modify script to process all 54 titles${NC}"
    echo ""
    
    for title in "${test_titles[@]}"; do
        process_title "$title"
        echo ""
    done
    
    # Final summary
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}📊 DOWNLOAD SUMMARY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Successful downloads: $SUCCESSFUL_DOWNLOADS${NC}"
    echo -e "${RED}✗ Failed downloads: $FAILED_DOWNLOADS${NC}"
    echo -e "${BLUE}📁 Total attempts: $TOTAL_DOWNLOADS${NC}"
    
    if [ $TOTAL_SIZE -gt 0 ]; then
        local total_size_mb=$(echo "scale=2; $TOTAL_SIZE/1024/1024" | bc 2>/dev/null || echo "0")
        echo -e "${PURPLE}💾 Total downloaded: ${total_size_mb}MB${NC}"
    fi
    
    echo -e "${CYAN}🎯 Folder structure created with Title/Chapter hierarchy${NC}"
    echo -e "${CYAN}📝 Each chapter folder contains PDF and HTML files${NC}"
    echo -e "${CYAN}✨ Download complete!${NC}"
}

# Run main function
main "$@"
