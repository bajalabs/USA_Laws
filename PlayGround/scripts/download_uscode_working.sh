#!/bin/bash

# 🇺🇸 USA Code Download Script - Working Version
# Downloads all available titles of the United States Code from GovInfo.gov
# Uses the pattern: https://www.govinfo.gov/content/pkg/USCODE-2024-title[X]/pdf/USCODE-2024-title[X].pdf

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
DOWNLOAD_DIR="../data/pdf"
MAX_TITLES=54

# Counters
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_SIZE=0

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
TITLE_NAMES[34]="Crime Control and Law Enforcement"
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

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_progress() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

create_directory_structure() {
    log_info "Creating directory structure..."
    
    mkdir -p "$DOWNLOAD_DIR"
    
    # Create title directories
    for title_num in {1..54}; do
        title_name="${TITLE_NAMES[$title_num]}"
        title_dir=$(printf "Title_%02d_%s" "$title_num" "$(echo "$title_name" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')")
        mkdir -p "../$title_dir"
        
        # Create title info file
        cat > "../$title_dir/README.md" << EOF
# Title $title_num - $title_name

## Overview
This directory contains **Title $title_num** of the United States Code: **$title_name**.

## Files Available
- **PDF**: Complete title in PDF format from GovInfo.gov
- **Metadata**: Title information and download details

## Source
- **Official Source**: [GovInfo.gov](https://www.govinfo.gov/app/collection/uscode/$YEAR/title$title_num)
- **Download URL**: [Direct PDF](https://www.govinfo.gov/content/pkg/USCODE-$YEAR-title$title_num/pdf/USCODE-$YEAR-title$title_num.pdf)
- **Last Updated**: $(date '+%Y-%m-%d')
- **Format**: PDF

## Navigation
- [📋 All US Code Titles](../README.md#titles)
- [🔍 Search All Titles](../README.md#search)
- [🤝 Contributing](../CONTRIBUTING.md)
EOF
    done
    
    log_success "Directory structure created for all 54 titles"
}

download_title() {
    local title_num=$1
    local title_name="${TITLE_NAMES[$title_num]}"
    local title_dir=$(printf "Title_%02d_%s" "$title_num" "$(echo "$title_name" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')")
    
    log_progress "[$title_num/$MAX_TITLES] Testing: $title_name"
    
    # Construct download URL
    local download_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    local output_file="$DOWNLOAD_DIR/USCODE-${YEAR}-title${title_num}.pdf"
    local title_pdf_file="../$title_dir/USCODE-${YEAR}-title${title_num}.pdf"
    local title_info_file="../$title_dir/title_info.json"
    
    # First test if the URL is accessible
    if curl -s -I "$download_url" | head -1 | grep -q "200"; then
        log_info "  📡 Title $title_num is available - downloading..."
        
        # Download the PDF file
        if curl -s -f -L "$download_url" -o "$output_file"; then
            # Copy to title directory as well
            cp "$output_file" "$title_pdf_file"
            
            # Get file size
            local file_size=$(du -h "$output_file" | cut -f1)
            TOTAL_SIZE=$((TOTAL_SIZE + $(du -k "$output_file" | cut -f1)))
            
            log_success "  Downloaded: $file_size"
            
            # Create title metadata
            cat > "$title_info_file" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "year": "$YEAR",
    "source_url": "$download_url",
    "file_size": "$file_size",
    "download_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "format": "PDF",
    "status": "downloaded",
    "source": "GovInfo.gov"
  }
}
EOF
            
            ((SUCCESSFUL_DOWNLOADS++))
            
            # Try to get basic page count (if pdfinfo is available)
            if command -v pdfinfo >/dev/null 2>&1; then
                local pages=$(pdfinfo "$output_file" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "unknown")
                log_info "    📄 Pages: $pages"
                
                # Update metadata with page count
                if command -v jq >/dev/null 2>&1; then
                    jq --arg pages "$pages" '.title.pages = $pages' "$title_info_file" > "${title_info_file}.tmp" && mv "${title_info_file}.tmp" "$title_info_file"
                fi
            fi
            
        else
            log_error "  Failed to download Title $title_num"
            create_failed_metadata "$title_info_file" "$title_num" "$title_name" "$download_url" "Download failed"
            ((FAILED_DOWNLOADS++))
        fi
        
    else
        log_warning "  Title $title_num not available on GovInfo.gov"
        create_failed_metadata "$title_info_file" "$title_num" "$title_name" "$download_url" "Not available"
        ((FAILED_DOWNLOADS++))
    fi
    
    echo ""
}

create_failed_metadata() {
    local info_file=$1
    local title_num=$2
    local title_name=$3
    local download_url=$4
    local error_msg=$5
    
    cat > "$info_file" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "year": "$YEAR",
    "source_url": "$download_url",
    "download_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "status": "failed",
    "error": "$error_msg",
    "source": "GovInfo.gov"
  }
}
EOF
}

generate_summary() {
    local total_size_mb=$((TOTAL_SIZE / 1024))
    
    cat > "../DOWNLOAD_SUMMARY.md" << EOF
# 🇺🇸 USA Code Download Summary

## 📊 Download Statistics
- **Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Total Titles Tested**: $MAX_TITLES
- **Successful Downloads**: $SUCCESSFUL_DOWNLOADS
- **Failed Downloads**: $FAILED_DOWNLOADS
- **Success Rate**: $(( SUCCESSFUL_DOWNLOADS * 100 / MAX_TITLES ))%
- **Total Size**: ${total_size_mb} MB

## 📁 Downloaded Titles

| Title | Name | Status | Size |
|-------|------|--------|------|
EOF

    for title_num in {1..54}; do
        local title_name="${TITLE_NAMES[$title_num]}"
        local pdf_file="$DOWNLOAD_DIR/USCODE-${YEAR}-title${title_num}.pdf"
        
        if [ -f "$pdf_file" ]; then
            local file_size=$(du -h "$pdf_file" | cut -f1)
            echo "| $title_num | $title_name | ✅ Downloaded | $file_size |" >> "../DOWNLOAD_SUMMARY.md"
        else
            echo "| $title_num | $title_name | ❌ Not Available | - |" >> "../DOWNLOAD_SUMMARY.md"
        fi
    done
    
    cat >> "../DOWNLOAD_SUMMARY.md" << EOF

## 🎯 Next Steps

1. **Text Extraction**: Convert PDFs to searchable text format
2. **Structure Analysis**: Parse PDF content to identify chapters and sections
3. **Database Creation**: Build searchable database of US Code content
4. **Markdown Generation**: Create human-readable format

## 🔍 File Locations

- **PDF Files**: \`data/pdf/USCODE-${YEAR}-title[XX].pdf\`
- **Title Directories**: \`Title_[XX]_[Name]/\`
- **Metadata**: Each title directory contains \`title_info.json\`

## 📋 Available vs Unavailable Titles

$(if [ $FAILED_DOWNLOADS -gt 0 ]; then
    echo "⚠️  **$FAILED_DOWNLOADS titles are not available on GovInfo.gov**"
    echo ""
    echo "This is normal - not all US Code titles may be published in PDF format."
    echo "Available titles represent the core federal statutes."
else
    echo "✅ **All titles downloaded successfully!**"
fi)

## 🏛️ About the US Code

The United States Code is the codification of general and permanent federal statutes.
It's organized into 54 titles covering different areas of federal law.

**Key Titles Downloaded:**
- **Title 1**: General Provisions (foundational legal principles)
- **Title 15**: Commerce and Trade (business regulation)
- **Title 18**: Crimes and Criminal Procedure (federal criminal law)
- **Title 26**: Internal Revenue Code (federal tax law)
- **Title 42**: Public Health and Welfare (social programs)

---

*Generated by download_uscode_working.sh on $(date)*
EOF
}

# Main execution
main() {
    echo -e "${CYAN}"
    cat << "EOF"
🇺🇸 ═══════════════════════════════════════════════════════════════
   USA CODE DOWNLOAD SYSTEM
   Downloading all available titles of the United States Code
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
    echo -e "${NC}"
    
    log_info "Starting USA Code download process..."
    log_info "Target: $MAX_TITLES titles from year $YEAR"
    log_info "Source: $BASE_URL"
    echo ""
    
    # Create directory structure
    create_directory_structure
    echo ""
    
    # Download all titles
    log_info "Testing and downloading available titles..."
    echo ""
    
    for title_num in {1..54}; do
        download_title $title_num
        
        # Small delay to be respectful to the server
        sleep 1
    done
    
    # Generate summary
    log_info "Generating download summary..."
    generate_summary
    
    # Final report
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📊 DOWNLOAD COMPLETE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    log_success "Successfully downloaded: $SUCCESSFUL_DOWNLOADS/$MAX_TITLES titles"
    
    if [ $FAILED_DOWNLOADS -gt 0 ]; then
        log_warning "Unavailable titles: $FAILED_DOWNLOADS (normal for GovInfo.gov)"
    fi
    
    log_info "Total size: $((TOTAL_SIZE / 1024)) MB"
    log_info "Summary report: ../DOWNLOAD_SUMMARY.md"
    echo ""
    
    if [ $SUCCESSFUL_DOWNLOADS -gt 0 ]; then
        log_success "🎉 USA Code titles downloaded successfully!"
        echo ""
        log_info "Next steps:"
        echo -e "  ${YELLOW}1.${NC} Extract text from PDFs for analysis"
        echo -e "  ${YELLOW}2.${NC} Parse structure (chapters, sections)"
        echo -e "  ${YELLOW}3.${NC} Create searchable database"
        echo -e "  ${YELLOW}4.${NC} Generate markdown format"
    else
        log_warning "No titles were successfully downloaded."
        log_info "Check internet connection and GovInfo.gov availability."
    fi
    
    echo ""
    echo -e "${PURPLE}🚀 Ready to build the future of American legal technology!${NC}"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_warning "jq not found - metadata will be basic JSON only"
    fi
    
    if ! command -v pdfinfo >/dev/null 2>&1; then
        log_warning "pdfinfo not found - page counts will be skipped"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 1
    fi
}

# Run the script
check_dependencies
main

echo -e "${GREEN}✨ USA Code download completed! ✨${NC}"
