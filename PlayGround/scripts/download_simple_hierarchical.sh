#!/bin/bash

# 🇺🇸 USA Code Simple Hierarchical Download Script
# Downloads USA Code with Title/Chapter folder structure
# Compatible with macOS default bash (no associative arrays needed)

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

# Function to get title name
get_title_name() {
    case $1 in
        1) echo "General Provisions" ;;
        2) echo "The Congress" ;;
        3) echo "The President" ;;
        4) echo "Flag and Seal, Seat of Government, and the States" ;;
        5) echo "Government Organization and Employees" ;;
        15) echo "Commerce and Trade" ;;
        *) echo "Title $1" ;;
    esac
}

# Function to check if title exists
check_title_exists() {
    local title_num=$1
    local check_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    
    # Use curl with timeout and proper error handling
    if curl -I --connect-timeout 10 --max-time 30 "$check_url" 2>/dev/null | head -1 | grep -q "200"; then
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
    
    # Try PDF first
    local pdf_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_num}.pdf"
    local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter_num}.pdf"
    
    echo -e "    ${BLUE}Trying Chapter ${chapter_num} PDF...${NC}"
    
    if curl -I --connect-timeout 10 --max-time 30 "$pdf_url" 2>/dev/null | head -1 | grep -q "200"; then
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
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_num}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter_num}.htm"
            
            if curl -I --connect-timeout 10 --max-time 30 "$html_url" 2>/dev/null | head -1 | grep -q "200"; then
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
    
    return 1  # Chapter not found
}

# Function to process a title
process_title() {
    local title_num=$1
    local title_name=$(get_title_name "$title_num")
    
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}📖 TITLE $title_num: $title_name${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if title exists
    if ! check_title_exists "$title_num"; then
        echo -e "${YELLOW}⚠ Title $title_num not available, skipping...${NC}"
        return
    fi
    
    # Create title directory
    local clean_name=$(echo "$title_name" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/__*/_/g' | sed 's/_$//')
    local title_dir="${BASE_DIR}/Title_$(printf "%02d" $title_num)_${clean_name}"
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
    
    # Download individual chapters (start with reasonable limits)
    local max_chapters
    case $title_num in
        1) max_chapters=5 ;;
        2) max_chapters=30 ;;
        3) max_chapters=5 ;;
        15) max_chapters=125 ;;  # We know this has 123 chapters
        *) max_chapters=50 ;;
    esac
    
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
    echo -e "${CYAN}🎯 Target: Selected titles with chapter breakdown${NC}"
    echo -e "${CYAN}💾 Output: $BASE_DIR${NC}"
    echo ""
    
    # Create base directory
    mkdir -p "$BASE_DIR"
    
    # Process test titles first
    local test_titles=(1 2 3 15)  # Start with these for testing
    
    echo -e "${YELLOW}🧪 Testing with titles: ${test_titles[*]}${NC}"
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
