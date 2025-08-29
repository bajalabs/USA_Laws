#!/bin/bash

# 🇺🇸 USA Code Download Script
# Downloads all 54 titles of the United States Code from GovInfo.gov
# Organizes into structured directory hierarchy: Title > Chapter > Section

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
BASE_URL="https://www.govinfo.gov/bulkdata/USCODE"
YEAR="2024"
DOWNLOAD_DIR="../data/xml"
TEMP_DIR="/tmp/uscode_download"

# Counters
TOTAL_TITLES=54
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0
TOTAL_SIZE=0

# US Code Title Information
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
    mkdir -p "$TEMP_DIR"
    
    # Create title directories
    for title_num in {1..54}; do
        title_name="${TITLE_NAMES[$title_num]}"
        title_dir=$(printf "Title_%02d_%s" "$title_num" "$(echo "$title_name" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')")
        mkdir -p "../$title_dir"
        
        # Create title info file
        cat > "../$title_dir/README.md" << EOF
# Title $title_num - $title_name

## Overview
This directory contains all chapters and sections for **Title $title_num** of the United States Code: **$title_name**.

## Structure
- **XML Files**: Original USLM XML from GovInfo.gov
- **JSON Files**: Structured data for programmatic access
- **Markdown Files**: Human-readable format

## Source
- **Official Source**: [GovInfo.gov](https://www.govinfo.gov/app/collection/uscode/$YEAR/title$title_num)
- **Last Updated**: $(date '+%Y-%m-%d')
- **Format**: USLM (United States Legislative Markup) XML

## Navigation
- [📋 Complete Title List](../README.md#titles)
- [🔍 Search All Titles](../README.md#search)
- [🤝 Contributing](../CONTRIBUTING.md)
EOF
    done
    
    log_success "Directory structure created"
}

download_title() {
    local title_num=$1
    local title_name="${TITLE_NAMES[$title_num]}"
    local title_dir=$(printf "Title_%02d_%s" "$title_num" "$(echo "$title_name" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')")
    
    log_progress "[$title_num/$TOTAL_TITLES] Downloading: $title_name"
    
    # Construct download URL
    local download_url="${BASE_URL}/${YEAR}/title${title_num}/USCODE-${YEAR}-title${title_num}.xml"
    local output_file="$DOWNLOAD_DIR/USCODE-${YEAR}-title${title_num}.xml"
    local title_info_file="../$title_dir/title_info.json"
    
    # Download the XML file
    if curl -s -f -L "$download_url" -o "$output_file"; then
        # Get file size
        local file_size=$(du -h "$output_file" | cut -f1)
        TOTAL_SIZE=$((TOTAL_SIZE + $(du -k "$output_file" | cut -f1)))
        
        log_success "Downloaded: $file_size"
        
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
    "format": "USLM XML",
    "status": "downloaded"
  }
}
EOF
        
        ((SUCCESSFUL_DOWNLOADS++))
        
        # Parse basic structure (chapters count)
        if command -v xmllint >/dev/null 2>&1; then
            local chapters_count=$(xmllint --xpath "count(//chapter)" "$output_file" 2>/dev/null || echo "unknown")
            local sections_count=$(xmllint --xpath "count(//section)" "$output_file" 2>/dev/null || echo "unknown")
            
            log_info "  📊 Structure: $chapters_count chapters, $sections_count sections"
            
            # Update metadata with structure info
            jq --arg chapters "$chapters_count" --arg sections "$sections_count" \
               '.title.chapters_count = $chapters | .title.sections_count = $sections' \
               "$title_info_file" > "${title_info_file}.tmp" && mv "${title_info_file}.tmp" "$title_info_file"
        fi
        
    else
        log_error "Failed to download Title $title_num: $title_name"
        
        # Create error metadata
        cat > "$title_info_file" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "year": "$YEAR",
    "source_url": "$download_url",
    "download_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "status": "failed",
    "error": "Download failed"
  }
}
EOF
        
        ((FAILED_DOWNLOADS++))
    fi
    
    echo ""
}

generate_summary() {
    local total_size_mb=$((TOTAL_SIZE / 1024))
    
    cat > "../DOWNLOAD_SUMMARY.md" << EOF
# 🇺🇸 USA Code Download Summary

## 📊 Download Statistics
- **Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Total Titles**: $TOTAL_TITLES
- **Successful Downloads**: $SUCCESSFUL_DOWNLOADS
- **Failed Downloads**: $FAILED_DOWNLOADS
- **Success Rate**: $(( SUCCESSFUL_DOWNLOADS * 100 / TOTAL_TITLES ))%
- **Total Size**: ${total_size_mb} MB

## 📁 Downloaded Titles

| Title | Name | Status | Size |
|-------|------|--------|------|
EOF

    for title_num in {1..54}; do
        local title_name="${TITLE_NAMES[$title_num]}"
        local xml_file="$DOWNLOAD_DIR/USCODE-${YEAR}-title${title_num}.xml"
        
        if [ -f "$xml_file" ]; then
            local file_size=$(du -h "$xml_file" | cut -f1)
            echo "| $title_num | $title_name | ✅ Downloaded | $file_size |" >> "../DOWNLOAD_SUMMARY.md"
        else
            echo "| $title_num | $title_name | ❌ Failed | - |" >> "../DOWNLOAD_SUMMARY.md"
        fi
    done
    
    cat >> "../DOWNLOAD_SUMMARY.md" << EOF

## 🎯 Next Steps

1. **Data Processing**: Run \`convert_to_json.sh\` to parse XML into structured JSON
2. **Markdown Generation**: Run \`convert_to_markdown.sh\` for human-readable format
3. **Database Population**: Run \`populate_database.sh\` to create searchable database
4. **Quality Validation**: Run \`validate_structure.sh\` to verify data integrity

## 🔍 File Locations

- **XML Files**: \`data/xml/USCODE-${YEAR}-title[XX].xml\`
- **Title Directories**: \`Title_[XX]_[Name]/\`
- **Metadata**: Each title directory contains \`title_info.json\`

## 📋 Issues

$(if [ $FAILED_DOWNLOADS -gt 0 ]; then
    echo "⚠️  **$FAILED_DOWNLOADS titles failed to download**"
    echo ""
    echo "Failed titles should be retried manually or investigated for availability."
else
    echo "✅ **All titles downloaded successfully!**"
fi)

---

*Generated by download_uscode.sh on $(date)*
EOF
}

# Main execution
main() {
    echo -e "${CYAN}"
    cat << "EOF"
🇺🇸 ═══════════════════════════════════════════════════════════════
   USA CODE DOWNLOAD SYSTEM
   Downloading all 54 titles of the United States Code
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
    echo -e "${NC}"
    
    log_info "Starting USA Code download process..."
    log_info "Target: $TOTAL_TITLES titles from year $YEAR"
    log_info "Source: $BASE_URL"
    echo ""
    
    # Create directory structure
    create_directory_structure
    echo ""
    
    # Download all titles
    log_info "Beginning downloads..."
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
    log_success "Successfully downloaded: $SUCCESSFUL_DOWNLOADS/$TOTAL_TITLES titles"
    
    if [ $FAILED_DOWNLOADS -gt 0 ]; then
        log_warning "Failed downloads: $FAILED_DOWNLOADS titles"
    fi
    
    log_info "Total size: $((TOTAL_SIZE / 1024)) MB"
    log_info "Summary report: ../DOWNLOAD_SUMMARY.md"
    echo ""
    
    if [ $SUCCESSFUL_DOWNLOADS -eq $TOTAL_TITLES ]; then
        log_success "🎉 All USA Code titles downloaded successfully!"
        echo ""
        log_info "Next steps:"
        echo -e "  ${YELLOW}1.${NC} Run ${GREEN}./convert_to_json.sh${NC} to parse XML data"
        echo -e "  ${YELLOW}2.${NC} Run ${GREEN}./convert_to_markdown.sh${NC} to generate readable format"
        echo -e "  ${YELLOW}3.${NC} Run ${GREEN}./populate_database.sh${NC} to create searchable database"
    else
        log_warning "Some downloads failed. Check DOWNLOAD_SUMMARY.md for details."
        log_info "You can re-run this script to retry failed downloads."
    fi
    
    echo ""
    echo -e "${PURPLE}🚀 Ready to build the future of legal technology!${NC}"
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
    
    if ! command -v xmllint >/dev/null 2>&1; then
        log_warning "xmllint not found - structure analysis will be skipped"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 1
    fi
}

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup on exit
trap cleanup EXIT

# Check dependencies and run
check_dependencies
main

echo -e "${GREEN}✨ USA Code download completed! ✨${NC}"
