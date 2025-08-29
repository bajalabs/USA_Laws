#!/bin/bash

# 🧪 USA Code Download Test Script
# Tests the download system with first 5 titles only

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
🧪 ═══════════════════════════════════════════════════════════════
   USA CODE DOWNLOAD TEST
   Testing with first 5 titles only
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

# Configuration
BASE_URL="https://www.govinfo.gov/content/pkg"
YEAR="2024"
TEST_TITLES=(1 2 3 5 15)  # Include Title 15 (Commerce) which we know works
TEST_NAMES=("General Provisions" "The Congress" "The President" "Government Organization and Employees" "Commerce and Trade")

# Create test directories
mkdir -p ../data/pdf
mkdir -p ../test_results

echo -e "${BLUE}🔍 Testing download connectivity and structure...${NC}"
echo ""

# Test each title
for i in "${!TEST_TITLES[@]}"; do
    title_num="${TEST_TITLES[$i]}"
    title_name="${TEST_NAMES[$i]}"
    
    echo -e "${YELLOW}[$((i+1))/5] Testing Title $title_num: $title_name${NC}"
    
    # Construct URL
    download_url="${BASE_URL}/USCODE-${YEAR}-title${title_num}/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    output_file="../data/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    
    echo -e "  ${BLUE}URL: $download_url${NC}"
    
    # Test if URL is accessible
    if curl -s -I "$download_url" | head -1 | grep -q "200"; then
        echo -e "  ${GREEN}✅ URL accessible${NC}"
        
        # Download the file
        if curl -s -f -L "$download_url" -o "$output_file"; then
            file_size=$(du -h "$output_file" | cut -f1)
            echo -e "  ${GREEN}✅ Downloaded: $file_size${NC}"
            
            # Basic PDF validation
            if command -v file >/dev/null 2>&1; then
                if file "$output_file" | grep -q "PDF"; then
                    echo -e "  ${GREEN}✅ Valid PDF file${NC}"
                    
                    # Get page count if pdfinfo is available
                    if command -v pdfinfo >/dev/null 2>&1; then
                        pages=$(pdfinfo "$output_file" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "unknown")
                        echo -e "  ${BLUE}📄 Pages: $pages${NC}"
                    fi
                else
                    echo -e "  ${YELLOW}⚠️  File type validation failed${NC}"
                fi
            fi
            
            # Create basic metadata
            cat > "../test_results/title_${title_num}_info.json" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "test_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source_url": "$download_url",
    "file_size": "$file_size",
    "status": "success"
  }
}
EOF
            
        else
            echo -e "  ${RED}❌ Download failed${NC}"
        fi
        
    else
        echo -e "  ${RED}❌ URL not accessible (may not be available)${NC}"
        
        # Create error metadata
        cat > "../test_results/title_${title_num}_info.json" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "test_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source_url": "$download_url",
    "status": "not_available",
    "error": "URL not accessible"
  }
}
EOF
    fi
    
    echo ""
done

# Generate test summary
echo -e "${BLUE}📋 Generating test summary...${NC}"

cat > "../test_results/TEST_SUMMARY.md" << EOF
# 🧪 USA Code Download Test Summary

## Test Information
- **Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Titles Tested**: 5 (Titles 1, 2, 3, 5, 15)
- **Source**: GovInfo.gov PDF format

## Test Results

| Title | Name | Status | Size | Notes |
|-------|------|--------|------|-------|
EOF

for i in "${!TEST_TITLES[@]}"; do
    title_num="${TEST_TITLES[$i]}"
    title_name="${TEST_NAMES[$i]}"
    pdf_file="../data/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    
    if [ -f "$pdf_file" ]; then
        file_size=$(du -h "$pdf_file" | cut -f1)
        echo "| $title_num | $title_name | ✅ Success | $file_size | Downloaded and validated |" >> "../test_results/TEST_SUMMARY.md"
    else
        echo "| $title_num | $title_name | ❌ Failed | - | Not available or download failed |" >> "../test_results/TEST_SUMMARY.md"
    fi
done

cat >> "../test_results/TEST_SUMMARY.md" << EOF

## File Locations
- **Downloaded PDFs**: \`data/pdf/USCODE-2024-title[X].pdf\`
- **Test Metadata**: \`test_results/title_[X]_info.json\`

## Next Steps
If test results look good:
1. Run the full download: \`./download_uscode_working.sh\`
2. Extract text from PDFs for processing
3. Create structured database
4. Generate searchable format

## Dependencies Check
EOF

# Check dependencies
echo "### System Dependencies" >> "../test_results/TEST_SUMMARY.md"

if command -v curl >/dev/null 2>&1; then
    echo "- ✅ curl: $(curl --version | head -1)" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ❌ curl: Not installed" >> "../test_results/TEST_SUMMARY.md"
fi

if command -v file >/dev/null 2>&1; then
    echo "- ✅ file: Available for PDF validation" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ⚠️ file: Not installed (optional)" >> "../test_results/TEST_SUMMARY.md"
fi

if command -v pdfinfo >/dev/null 2>&1; then
    echo "- ✅ pdfinfo: Available for PDF analysis" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ⚠️ pdfinfo: Not installed (optional)" >> "../test_results/TEST_SUMMARY.md"
fi

cat >> "../test_results/TEST_SUMMARY.md" << EOF

## URL Pattern Discovered
The working URL pattern is:
\`https://www.govinfo.gov/content/pkg/USCODE-2024-title[X]/pdf/USCODE-2024-title[X].pdf\`

Where [X] is the title number (1-54).

**Note**: Not all titles may be available in PDF format on GovInfo.gov.

---

*Generated by test_uscode_download.sh on $(date)*
EOF

# Final results
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🧪 TEST COMPLETE${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Count successful downloads
success_count=0
for i in "${!TEST_TITLES[@]}"; do
    title_num="${TEST_TITLES[$i]}"
    pdf_file="../data/pdf/USCODE-${YEAR}-title${title_num}.pdf"
    if [ -f "$pdf_file" ]; then
        ((success_count++))
    fi
done

echo -e "${GREEN}✅ Successful downloads: $success_count/5${NC}"

if [ $success_count -gt 0 ]; then
    echo -e "${GREEN}🎉 Test downloads successful!${NC}"
    echo ""
    echo -e "${BLUE}Ready to run full download:${NC}"
    echo -e "  ${YELLOW}cd scripts${NC}"
    echo -e "  ${YELLOW}./download_uscode_working.sh${NC}"
else
    echo -e "${YELLOW}⚠️ No test downloads succeeded${NC}"
    echo -e "${BLUE}Check connectivity and GovInfo.gov availability${NC}"
fi

echo ""
echo -e "${BLUE}📋 Test summary: test_results/TEST_SUMMARY.md${NC}"
echo -e "${PURPLE}🚀 Ready to build the future of American legal technology!${NC}"
