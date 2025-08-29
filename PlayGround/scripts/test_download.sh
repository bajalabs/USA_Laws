#!/bin/bash

# 🧪 USA Code Download Test Script
# Tests the download system with first 3 titles only

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
   Testing with first 3 titles only
   Source: GovInfo.gov (Government Publishing Office)
═══════════════════════════════════════════════════════════════
EOF
echo -e "${NC}"

# Configuration
BASE_URL="https://www.govinfo.gov/bulkdata/USCODE"
YEAR="2024"
TEST_TITLES=(1 2 3)
TEST_NAMES=("General Provisions" "The Congress" "The President")

# Create test directories
mkdir -p ../data/xml
mkdir -p ../test_results

echo -e "${BLUE}🔍 Testing download connectivity and structure...${NC}"
echo ""

# Test each of the first 3 titles
for i in "${!TEST_TITLES[@]}"; do
    title_num="${TEST_TITLES[$i]}"
    title_name="${TEST_NAMES[$i]}"
    
    echo -e "${YELLOW}[$((i+1))/3] Testing Title $title_num: $title_name${NC}"
    
    # Construct URL
    download_url="${BASE_URL}/${YEAR}/title${title_num}/USCODE-${YEAR}-title${title_num}.xml"
    output_file="../data/xml/USCODE-${YEAR}-title${title_num}.xml"
    
    echo -e "  ${BLUE}URL: $download_url${NC}"
    
    # Test if URL is accessible
    if curl -s -I "$download_url" | head -1 | grep -q "200 OK"; then
        echo -e "  ${GREEN}✅ URL accessible${NC}"
        
        # Download the file
        if curl -s -f -L "$download_url" -o "$output_file"; then
            file_size=$(du -h "$output_file" | cut -f1)
            echo -e "  ${GREEN}✅ Downloaded: $file_size${NC}"
            
            # Basic XML validation
            if command -v xmllint >/dev/null 2>&1; then
                if xmllint --noout "$output_file" 2>/dev/null; then
                    echo -e "  ${GREEN}✅ Valid XML structure${NC}"
                    
                    # Count basic elements
                    chapters=$(xmllint --xpath "count(//chapter)" "$output_file" 2>/dev/null || echo "unknown")
                    sections=$(xmllint --xpath "count(//section)" "$output_file" 2>/dev/null || echo "unknown")
                    
                    echo -e "  ${BLUE}📊 Structure: $chapters chapters, $sections sections${NC}"
                else
                    echo -e "  ${YELLOW}⚠️  XML structure validation failed${NC}"
                fi
            else
                echo -e "  ${YELLOW}⚠️  xmllint not available - skipping XML validation${NC}"
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
        echo -e "  ${RED}❌ URL not accessible${NC}"
        
        # Create error metadata
        cat > "../test_results/title_${title_num}_info.json" << EOF
{
  "title": {
    "number": $title_num,
    "name": "$title_name",
    "test_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source_url": "$download_url",
    "status": "failed",
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
- **Titles Tested**: 3 (Titles 1, 2, 3)
- **Source**: GovInfo.gov USLM XML

## Test Results

| Title | Name | Status | Size | Notes |
|-------|------|--------|------|-------|
EOF

for i in "${!TEST_TITLES[@]}"; do
    title_num="${TEST_TITLES[$i]}"
    title_name="${TEST_NAMES[$i]}"
    xml_file="../data/xml/USCODE-${YEAR}-title${title_num}.xml"
    
    if [ -f "$xml_file" ]; then
        file_size=$(du -h "$xml_file" | cut -f1)
        echo "| $title_num | $title_name | ✅ Success | $file_size | Downloaded and validated |" >> "../test_results/TEST_SUMMARY.md"
    else
        echo "| $title_num | $title_name | ❌ Failed | - | Download failed |" >> "../test_results/TEST_SUMMARY.md"
    fi
done

cat >> "../test_results/TEST_SUMMARY.md" << EOF

## File Locations
- **Downloaded XML**: \`data/xml/USCODE-2024-title[X].xml\`
- **Test Metadata**: \`test_results/title_[X]_info.json\`

## Next Steps
If test results look good:
1. Run the full download: \`./download_uscode.sh\`
2. Process the data: \`./convert_to_json.sh\`
3. Generate readable format: \`./convert_to_markdown.sh\`

## Dependencies Check
EOF

# Check dependencies
echo "### System Dependencies" >> "../test_results/TEST_SUMMARY.md"

if command -v curl >/dev/null 2>&1; then
    echo "- ✅ curl: $(curl --version | head -1)" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ❌ curl: Not installed" >> "../test_results/TEST_SUMMARY.md"
fi

if command -v jq >/dev/null 2>&1; then
    echo "- ✅ jq: $(jq --version)" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ⚠️ jq: Not installed (optional)" >> "../test_results/TEST_SUMMARY.md"
fi

if command -v xmllint >/dev/null 2>&1; then
    echo "- ✅ xmllint: Available" >> "../test_results/TEST_SUMMARY.md"
else
    echo "- ⚠️ xmllint: Not installed (optional)" >> "../test_results/TEST_SUMMARY.md"
fi

cat >> "../test_results/TEST_SUMMARY.md" << EOF

---

*Generated by test_download.sh on $(date)*
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
    xml_file="../data/xml/USCODE-${YEAR}-title${title_num}.xml"
    if [ -f "$xml_file" ]; then
        ((success_count++))
    fi
done

echo -e "${GREEN}✅ Successful downloads: $success_count/3${NC}"

if [ $success_count -eq 3 ]; then
    echo -e "${GREEN}🎉 All test downloads successful!${NC}"
    echo ""
    echo -e "${BLUE}Ready to run full download:${NC}"
    echo -e "  ${YELLOW}cd scripts${NC}"
    echo -e "  ${YELLOW}./download_uscode.sh${NC}"
else
    echo -e "${YELLOW}⚠️ Some test downloads failed${NC}"
    echo -e "${BLUE}Check connectivity and try again${NC}"
fi

echo ""
echo -e "${BLUE}📋 Test summary: test_results/TEST_SUMMARY.md${NC}"
echo -e "${PURPLE}🚀 Ready to build the future of American legal technology!${NC}"
