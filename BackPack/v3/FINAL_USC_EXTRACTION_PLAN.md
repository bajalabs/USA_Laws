# Final USC 2023 Extraction Plan - Refined Approach

## Project Overview

Extract hierarchical structure and download links for all 2023 USA Code titles from GovInfo website, focusing on **structure, names, and links** only.

## Website Structure Knowledge Gathered

### URL Patterns Discovered
```
Main Collection: https://www.govinfo.gov/app/collection/uscode/2023
Title Details: https://www.govinfo.gov/app/details/USCODE-2023-title{N}/
Title HTML: https://www.govinfo.gov/content/pkg/USCODE-2023-title{N}/html/USCODE-2023-title{N}.htm
Title PDF: https://www.govinfo.gov/content/pkg/USCODE-2023-title{N}/pdf/USCODE-2023-title{N}.pdf
MODS: https://www.govinfo.gov/metadata/pkg/USCODE-2023-title{N}/mods.xml
PREMIS: https://www.govinfo.gov/metadata/pkg/USCODE-2023-title{N}/premis.xml
ZIP: https://www.govinfo.gov/content/pkg/USCODE-2023-title{N}.zip
```

### Hierarchical Structure Patterns

Based on analysis of sample titles, we identified these organizational patterns:

**Type 1: Chapters Only**
- Example: Title 1 (3 chapters), Title 4 (5 chapters)
- Structure: Title → Chapters

**Type 2: Parts → Chapters**
- Example: Title 5, Title 15
- Structure: Title → Parts → Chapters

**Type 3: Subtitles → Parts → Chapters**
- Example: Title 10
- Structure: Title → Subtitles → Parts → Chapters

**Type 4: Subtitles → Parts → Subparts → Chapters**
- Example: Title 26 (Internal Revenue Code)
- Structure: Title → Subtitles → Parts → Subparts → Chapters

**Type 5: Parts → Subparts → Chapters**
- Example: Title 42
- Structure: Title → Parts → Subparts → Chapters

### HTML Structure Analysis

#### Table of Contents Location
```html
<div class="analysis">
  <div><div class="analysis-head-left">Chap.</div><div class="analysis-head-right">Sec.</div></div>
  <!-- Chapter listings -->
</div>
```

#### Hierarchical Elements CSS Classes
```html
<h2 class="part-head">Subtitle A—General Military Law</h2>  <!-- Subtitles -->
<h2 class="part-head">PART I—ORGANIZATION</h2>              <!-- Parts -->
<h3 class="subpart-head">subpart i—health centers</h3>      <!-- Subparts -->
<h3 class="chapter-head">CHAPTER 1—DEFINITIONS</h3>         <!-- Chapters -->
```

### Document Types Available

For each organizational level (Title, Subtitle, Part, Subpart, Chapter):
1. **PDF** - Complete document
2. **HTML** - Web version
3. **Details** - Metadata page
4. **MODS** - Bibliographic metadata
5. **PREMIS** - Preservation metadata
6. **ZIP** - Complete package

### Special Documents
- **Frontmatter** - Introduction/preliminary material
- **Table of Contents** - Navigation structure
- **Appendices** - Supplementary material (where present)

## Requirements Clarification

### What We Need to Extract
1. **Hierarchical Structure**: Only if Parts, Subparts, Subtitles exist at title level
2. **Names**: Official names of all organizational elements
3. **Download Links**: All document format links for each element
4. **Special Documents**: Frontmatter, ToC, Appendices links

### What We DON'T Need
- Internal chapter subdivisions (subchapters, internal parts)
- Detailed legal analysis
- Section-level information
- Extensive descriptive text

## Final Technical Approach

### Phase 1: Structure Detection Script
Create `detect_title_structure.py` that:
1. Fetches title HTML using requests/curl
2. Parses hierarchical elements using CSS selectors
3. Determines organizational pattern (Type 1-5)
4. Extracts names and basic structure

### Phase 2: Link Extraction Script  
Create `extract_download_links.py` that:
1. Identifies all organizational elements
2. Constructs download URLs for each format
3. Validates link availability
4. Extracts frontmatter/ToC/appendix links

### Phase 3: Progressive Processing
Process titles individually:
1. Run structure detection
2. Run link extraction  
3. Generate focused report
4. Move to next title

### Phase 4: Validation (Optional)
Use Playwright MCP for:
- Visual verification of complex structures
- Screenshot documentation
- Navigation testing

## Implementation Strategy

### Script Architecture
```python
# detect_title_structure.py
def analyze_title_structure(title_num):
    """Detect hierarchical organization pattern"""
    
def extract_hierarchical_elements(soup):
    """Extract subtitles, parts, subparts, chapters"""
    
def determine_structure_type(elements):
    """Classify into Type 1-5 patterns"""

# extract_download_links.py  
def build_download_urls(title_num, elements):
    """Generate all format URLs for each element"""
    
def find_special_documents(soup):
    """Locate frontmatter, ToC, appendices"""
    
def validate_links(urls):
    """Check link availability"""

# generate_title_report.py
def create_focused_report(structure, links):
    """Generate minimal structure + links report"""
```

### Output Format
```markdown
# Title N: TITLE_NAME

## Hierarchical Structure
- Type: [1-5]
- Organization: [Pattern description]

## [Subtitles] (if present)
### Subtitle A: NAME
- PDF: [link]
- HTML: [link] 
- Details: [link]
- MODS: [link]
- PREMIS: [link]

## Parts (if present)
### Part I: NAME
[Same link structure]

## Chapters
### Chapter 1: NAME
[Same link structure]

## Special Documents
- Frontmatter: [links]
- Table of Contents: [links]
- Appendices: [links]
```

## Execution Plan

### Title Processing Order
1. **Test Group**: Titles 4, 5, 10 (different structure types)
2. **Simple Titles**: 1, 3, 9, 13, 14 (chapters only)
3. **Medium Complexity**: 2, 15, 18, 23 (parts + chapters)
4. **Complex Titles**: 26, 42, 46 (full hierarchy)
5. **Remaining Titles**: Sequential processing

### Quality Control
- Validate structure detection accuracy
- Verify link functionality
- Ensure consistent formatting
- Document any anomalies

### Deliverables
1. **Individual Title Reports** - Focused structure + links
2. **Master Index** - All titles overview
3. **Processing Scripts** - Reusable tools
4. **Documentation** - Structure patterns and findings

## Success Criteria

✅ **Accurate Structure Detection**: Correct identification of organizational patterns
✅ **Complete Link Coverage**: All download formats for every element  
✅ **Minimal Text Focus**: Structure, names, links only
✅ **Special Document Inclusion**: Frontmatter, ToC, appendices
✅ **Progressive Processing**: One title at a time
✅ **Validation Capability**: Playwright backup for verification

## Risk Mitigation

- **Rate Limiting**: Respectful delays between requests
- **Error Handling**: Graceful failure with retry logic
- **Backup Methods**: Playwright MCP as fallback
- **Incremental Progress**: Save results after each title
- **Validation**: Cross-check structure detection

This refined approach focuses exclusively on extracting the essential hierarchical information and download links while eliminating unnecessary complexity and text.
