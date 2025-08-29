#!/bin/bash

# 🔍 Discover Available Chapters for USA Code 2023 Titles 16-54
# Comprehensively test which titles have chapters and create the proper structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

YEAR="2023"
BASE_URL="https://www.govinfo.gov/content/pkg"
EXISTING_DIR="/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/USA-Codes-16-54"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Comprehensive Chapter Discovery for USA Code 2023        ║${NC}"  
echo -e "${BLUE}║                    Titles 16-54                             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"

# Quick URL test
url_exists() {
    curl --head --silent --connect-timeout 8 --max-time 15 "$1" 2>/dev/null | grep -q "200 OK"
}

# Extract title number from directory
get_title_number() {
    echo "$1" | grep -o 'Title_[0-9]*' | cut -d_ -f2 | sed 's/^0*//'
}

# Test and create chapters for a specific title
discover_title_chapters() {
    local title_dir="$1"
    local title_name=$(basename "$title_dir")
    local title_num=$(get_title_number "$title_name")
    local chapters_found=0
    
    echo -e "${CYAN}🔍 Testing $title_name (Title $title_num)${NC}"
    
    # Test chapters 1-50 efficiently
    for chapter in {1..50}; do
        local chapter_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
        
        if url_exists "$chapter_url"; then
            ((chapters_found++))
            echo -e "  ${GREEN}✅ Chapter $chapter found${NC}"
            
            # Create the chapter directory  
            local chapter_dir="${title_dir}/Chapter_$(printf "%02d" $chapter)"
            mkdir -p "$chapter_dir"
            
            # Download chapter files
            echo -e "    ${YELLOW}📥 Downloading Chapter $chapter files...${NC}"
            
            # Download PDF
            local pdf_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.pdf"
            if curl -L --connect-timeout 20 --max-time 120 --silent "$chapter_url" -o "$pdf_file" 2>/dev/null; then
                if [ -f "$pdf_file" ] && [ -s "$pdf_file" ]; then
                    local pdf_size=$(du -h "$pdf_file" | cut -f1)
                    echo -e "      ${GREEN}✓ PDF ($pdf_size)${NC}"
                fi
            fi
            
            # Download HTML
            local html_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            local html_file="${chapter_dir}/USCODE-${YEAR}-title${title_num}-chap${chapter}.htm"
            if curl -L --connect-timeout 20 --max-time 120 --silent "$html_url" -o "$html_file" 2>/dev/null; then
                if [ -f "$html_file" ] && [ -s "$html_file" ]; then
                    local html_size=$(du -h "$html_file" | cut -f1)
                    echo -e "      ${GREEN}✓ HTML ($html_size)${NC}"
                fi
            fi
        fi
        
        # Also test chapter with letter suffixes (A, B, C, D)
        for suffix in A B C D; do
            local chapter_letter="${chapter}${suffix}"
            local chapter_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
            
            if url_exists "$chapter_url_suffix"; then
                ((chapters_found++))
                echo -e "  ${GREEN}✅ Chapter ${chapter_letter} found${NC}"
                
                local chapter_dir_suffix="${title_dir}/Chapter_$(printf "%02d" $chapter)${suffix}"
                mkdir -p "$chapter_dir_suffix"
                
                # Download files with suffix
                echo -e "    ${YELLOW}📥 Downloading Chapter ${chapter_letter} files...${NC}"
                
                local pdf_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.pdf"
                if curl -L --connect-timeout 20 --max-time 120 --silent "$chapter_url_suffix" -o "$pdf_file_suffix" 2>/dev/null; then
                    if [ -f "$pdf_file_suffix" ] && [ -s "$pdf_file_suffix" ]; then
                        local pdf_size=$(du -h "$pdf_file_suffix" | cut -f1)
                        echo -e "      ${GREEN}✓ PDF ($pdf_size)${NC}"
                    fi
                fi
                
                local html_url_suffix="${BASE_URL}/USCODE-${YEAR}-title${title_num}/html/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                local html_file_suffix="${chapter_dir_suffix}/USCODE-${YEAR}-title${title_num}-chap${chapter_letter}.htm"
                if curl -L --connect-timeout 20 --max-time 120 --silent "$html_url_suffix" -o "$html_file_suffix" 2>/dev/null; then
                    if [ -f "$html_file_suffix" ] && [ -s "$html_file_suffix" ]; then
                        local html_size=$(du -h "$html_file_suffix" | cut -f1)
                        echo -e "      ${GREEN}✓ HTML ($html_size)${NC}"
                    fi
                fi
            fi
        done
    done
    
    if [ $chapters_found -gt 0 ]; then
        echo -e "  ${GREEN}📊 Total chapters found and downloaded: $chapters_found${NC}"
    else
        echo -e "  ${BLUE}ℹ️  No chapters found (single-file title)${NC}"
    fi
    
    echo ""
    return $chapters_found
}

# Main execution
main() {
    if [ ! -d "$EXISTING_DIR" ]; then
        echo -e "${RED}❌ Error: Directory $EXISTING_DIR not found!${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Starting comprehensive chapter discovery...${NC}"
    echo -e "${YELLOW}📁 Working directory: $EXISTING_DIR${NC}\n"
    
    local total_titles_with_chapters=0
    local total_chapters=0
    
    # Process each title directory
    for title_dir in "$EXISTING_DIR"/Title_*; do
        if [ -d "$title_dir" ]; then
            local chapters_found=$(discover_title_chapters "$title_dir")
            if [ $chapters_found -gt 0 ]; then
                ((total_titles_with_chapters++))
                total_chapters=$((total_chapters + chapters_found))
            fi
            sleep 1  # Be respectful to server
        fi
    done
    
    # Final report
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    DISCOVERY COMPLETE                       ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${GREEN}📊 Titles with chapters: $total_titles_with_chapters${NC}"
    echo -e "${GREEN}📚 Total chapters discovered: $total_chapters${NC}"
    
    if [ $total_chapters -gt 0 ]; then
        echo -e "\n${GREEN}🎉 Chapter discovery and download completed!${NC}"
        echo -e "${CYAN}✨ Your USA Code titles now have complete chapter structure!${NC}"
    else
        echo -e "\n${YELLOW}ℹ️  No chapters found for USA Code 2023 titles 16-54${NC}"
        echo -e "${BLUE}💡 This may indicate these titles use single-file format in 2023${NC}"
    fi
}

# Execute
main

echo -e "\n${CYAN}🏛️ USA Code 2023 Chapter Discovery Complete! 🏛️${NC}"