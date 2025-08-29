# USC 2023 - Complete Extraction Summary

## Overview
- **Total Titles Processed**: 53
- **Excluded Titles**: 53 (reserved)
- **Source**: https://www.govinfo.gov/app/collection/uscode/2023
- **Extraction Method**: Automated using Python + BeautifulSoup + requests

## Hierarchical Structure Statistics

### Total Elements Extracted
- **Subtitles**: 51
- **Parts**: 1,891
- **Subparts**: 523
- **Chapters**: 2,911

### Structure Type Distribution
- **Type 1: Chapters Only**: 16 titles
- **Type 2: Parts → Chapters**: 20 titles
- **Type 5: Parts → Subparts → Chapters**: 11 titles
- **Type 3: Subtitles → Parts → Chapters**: 3 titles
- **Type 4: Subtitles → Parts → Subparts → Chapters**: 3 titles

## Largest Titles by Chapter Count

1. **Title 10**: TITLE 10—ARMED FORCES (340 chapters)
2. **Title 42**: TITLE 42—THE PUBLIC HEALTH AND WELFARE (195 chapters)
3. **Title 15**: TITLE 15—COMMERCE AND TRADE (152 chapters)
4. **Title 16**: TITLE 16—CONSERVATION (150 chapters)
5. **Title 18**: TITLE 18—CRIMES AND CRIMINAL PROCEDURE (141 chapters)
6. **Title 36**: TITLE 36—PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS (132 chapters)
7. **Title 7**: TITLE 7—AGRICULTURE (130 chapters)
8. **Title 22**: TITLE 22—FOREIGN RELATIONS AND INTERCOURSE (125 chapters)
9. **Title 49**: TITLE 49—TRANSPORTATION (114 chapters)
10. **Title 46**: TITLE 46—SHIPPING (108 chapters)

## Most Complex Titles (Type 3 & 4 Hierarchies)

- **Title 10**: TITLE 10—ARMED FORCES (Type 3: Subtitles → Parts → Chapters)
- **Title 26**: TITLE 26—INTERNAL REVENUE CODE (Type 4: Subtitles → Parts → Subparts → Chapters)
- **Title 34**: TITLE 34—CRIME CONTROL AND LAW ENFORCEMENT (Type 4: Subtitles → Parts → Subparts → Chapters)
- **Title 36**: TITLE 36—PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS (Type 3: Subtitles → Parts → Chapters)
- **Title 46**: TITLE 46—SHIPPING (Type 3: Subtitles → Parts → Chapters)
- **Title 52**: TITLE 52—VOTING AND ELECTIONS (Type 4: Subtitles → Parts → Subparts → Chapters)

## Complete Title Listing

| Title | Name | Structure Type | Chapters | Parts | Subparts | Subtitles |
|-------|------|----------------|----------|-------|----------|-----------|
| 1 | TITLE 1—GENERAL PROVISIONS | Type 1: Chapters Only | 3 | 0 | 0 | 0 |
| 2 | TITLE 2—THE CONGRESS | Type 2: Parts → Chapters | 54 | 33 | 0 | 0 |
| 3 | TITLE 3—THE PRESIDENT | Type 2: Parts → Chapters | 5 | 5 | 0 | 0 |
| 4 | TITLE 4—FLAG AND SEAL, SEAT OF GOVERNMENT, AND THE STATES | Type 1: Chapters Only | 5 | 0 | 0 | 0 |
| 5 | TITLE 5—GOVERNMENT ORGANIZATION AND EMPLOYEES | Type 2: Parts → Chapters | 63 | 14 | 0 | 0 |
| 6 | TITLE 6—DOMESTIC SECURITY | Type 2: Parts → Chapters | 6 | 53 | 0 | 0 |
| 7 | TITLE 7—AGRICULTURE | Type 5: Parts → Subparts → Chapters | 130 | 42 | 11 | 0 |
| 8 | TITLE 8—ALIENS AND NATIONALITY | Type 2: Parts → Chapters | 15 | 13 | 0 | 0 |
| 9 | TITLE 9—ARBITRATION | Type 1: Chapters Only | 4 | 0 | 0 | 0 |
| 10 | TITLE 10—ARMED FORCES | Type 3: Subtitles → Parts → Chapters | 340 | 32 | 0 | 6 |
| 11 | TITLE 11—BANKRUPTCY | Type 1: Chapters Only | 9 | 0 | 0 | 0 |
| 12 | TITLE 12—BANKS AND BANKING | Type 5: Parts → Subparts → Chapters | 62 | 47 | 7 | 0 |
| 13 | TITLE 13—CENSUS | Type 1: Chapters Only | 6 | 0 | 0 | 0 |
| 14 | TITLE 14—COAST GUARD | Type 1: Chapters Only | 17 | 0 | 0 | 0 |
| 15 | TITLE 15—COMMERCE AND TRADE | Type 2: Parts → Chapters | 152 | 28 | 0 | 0 |
| 16 | TITLE 16—CONSERVATION | Type 5: Parts → Subparts → Chapters | 150 | 46 | 13 | 0 |
| 17 | TITLE 17—COPYRIGHTS | Type 1: Chapters Only | 15 | 0 | 0 | 0 |
| 18 | TITLE 18—CRIMES AND CRIMINAL PROCEDURE | Type 2: Parts → Chapters | 141 | 5 | 0 | 0 |
| 19 | TITLE 19—CUSTOMS DUTIES | Type 5: Parts → Subparts → Chapters | 31 | 87 | 22 | 0 |
| 20 | TITLE 20—EDUCATION | Type 5: Parts → Subparts → Chapters | 86 | 273 | 111 | 0 |
| 21 | TITLE 21—FOOD AND DRUGS | Type 5: Parts → Subparts → Chapters | 30 | 26 | 10 | 0 |
| 22 | TITLE 22—FOREIGN RELATIONS AND INTERCOURSE | Type 5: Parts → Subparts → Chapters | 125 | 125 | 27 | 0 |
| 23 | TITLE 23—HIGHWAYS | Type 1: Chapters Only | 6 | 0 | 0 | 0 |
| 24 | TITLE 24—HOSPITALS AND ASYLUMS | Type 1: Chapters Only | 11 | 0 | 0 | 0 |
| 25 | TITLE 25—INDIANS | Type 2: Parts → Chapters | 57 | 18 | 0 | 0 |
| 26 | TITLE 26—INTERNAL REVENUE CODE | Type 4: Subtitles → Parts → Subparts → Chapters | 72 | 184 | 103 | 11 |
| 27 | TITLE 27—INTOXICATING LIQUORS | Type 1: Chapters Only | 10 | 0 | 0 | 0 |
| 28 | TITLE 28—JUDICIARY AND JUDICIAL PROCEDURE | Type 2: Parts → Chapters | 79 | 6 | 0 | 0 |
| 29 | TITLE 29—LABOR | Type 5: Parts → Subparts → Chapters | 36 | 76 | 18 | 0 |
| 30 | TITLE 30—MINERAL LANDS AND MINING | Type 2: Parts → Chapters | 34 | 3 | 0 | 0 |
| 31 | TITLE 31—MONEY AND FINANCE | Type 2: Parts → Chapters | 31 | 2 | 0 | 0 |
| 32 | TITLE 32—NATIONAL GUARD | Type 1: Chapters Only | 5 | 0 | 0 | 0 |
| 33 | TITLE 33—NAVIGATION AND NAVIGABLE WATERS | Type 2: Parts → Chapters | 57 | 3 | 0 | 0 |
| 34 | TITLE 34—CRIME CONTROL AND LAW ENFORCEMENT | Type 4: Subtitles → Parts → Subparts → Chapters | 34 | 54 | 20 | 6 |
| 35 | TITLE 35—PATENTS | Type 2: Parts → Chapters | 25 | 5 | 0 | 0 |
| 36 | TITLE 36—PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS | Type 3: Subtitles → Parts → Chapters | 132 | 4 | 0 | 3 |
| 37 | TITLE 37—PAY AND ALLOWANCES OF THE UNIFORMED SERVICES | Type 1: Chapters Only | 12 | 0 | 0 | 0 |
| 38 | TITLE 38—VETERANS' BENEFITS | Type 2: Parts → Chapters | 47 | 6 | 0 | 0 |
| 39 | TITLE 39—POSTAL SERVICE | Type 2: Parts → Chapters | 22 | 5 | 0 | 0 |
| 40 | TITLE 40—PUBLIC BUILDINGS, PROPERTY, AND WORKS | Type 2: Parts → Chapters | 44 | 4 | 0 | 0 |
| 41 | TITLE 41—PUBLIC CONTRACTS | Type 1: Chapters Only | 27 | 0 | 0 | 4 |
| 42 | TITLE 42—THE PUBLIC HEALTH AND WELFARE | Type 5: Parts → Subparts → Chapters | 195 | 583 | 163 | 0 |
| 43 | TITLE 43—PUBLIC LANDS | Type 1: Chapters Only | 59 | 0 | 0 | 0 |
| 44 | TITLE 44—PUBLIC PRINTING AND DOCUMENTS | Type 2: Parts → Chapters | 23 | 4 | 0 | 0 |
| 45 | TITLE 45—RAILROADS | Type 2: Parts → Chapters | 22 | 3 | 0 | 0 |
| 46 | TITLE 46—SHIPPING | Type 3: Subtitles → Parts → Chapters | 108 | 22 | 0 | 8 |
| 47 | TITLE 47—TELECOMMUNICATIONS | Type 5: Parts → Subparts → Chapters | 16 | 17 | 5 | 0 |
| 48 | TITLE 48—TERRITORIES AND INSULAR POSSESSIONS | Type 2: Parts → Chapters | 21 | 4 | 0 | 0 |
| 49 | TITLE 49—TRANSPORTATION | Type 5: Parts → Subparts → Chapters | 114 | 17 | 4 | 0 |
| 50 | TITLE 50—WAR AND NATIONAL DEFENSE | Type 2: Parts → Chapters | 62 | 36 | 0 | 0 |
| 51 | TITLE 51—NATIONAL AND COMMERCIAL SPACE PROGRAMS | Type 1: Chapters Only | 35 | 0 | 0 | 7 |
| 52 | TITLE 52—VOTING AND ELECTIONS | Type 4: Subtitles → Parts → Subparts → Chapters | 10 | 6 | 9 | 3 |
| 54 | TITLE 54—NATIONAL PARK SERVICE AND RELATED PROGRAMS | Type 1: Chapters Only | 56 | 0 | 0 | 3 |

## Structure Type Analysis

### Type 1: Chapters Only (16 titles)
Simple structure with direct chapter organization.

- Title 1: TITLE 1—GENERAL PROVISIONS
- Title 4: TITLE 4—FLAG AND SEAL, SEAT OF GOVERNMENT, AND THE STATES
- Title 9: TITLE 9—ARBITRATION
- Title 11: TITLE 11—BANKRUPTCY
- Title 13: TITLE 13—CENSUS
- Title 14: TITLE 14—COAST GUARD
- Title 17: TITLE 17—COPYRIGHTS
- Title 23: TITLE 23—HIGHWAYS
- Title 24: TITLE 24—HOSPITALS AND ASYLUMS
- Title 27: TITLE 27—INTOXICATING LIQUORS
- Title 32: TITLE 32—NATIONAL GUARD
- Title 37: TITLE 37—PAY AND ALLOWANCES OF THE UNIFORMED SERVICES
- Title 41: TITLE 41—PUBLIC CONTRACTS
- Title 43: TITLE 43—PUBLIC LANDS
- Title 51: TITLE 51—NATIONAL AND COMMERCIAL SPACE PROGRAMS
- Title 54: TITLE 54—NATIONAL PARK SERVICE AND RELATED PROGRAMS

### Type 2: Parts → Chapters (20 titles)
Intermediate structure with parts containing chapters.

- Title 2: TITLE 2—THE CONGRESS
- Title 3: TITLE 3—THE PRESIDENT
- Title 5: TITLE 5—GOVERNMENT ORGANIZATION AND EMPLOYEES
- Title 6: TITLE 6—DOMESTIC SECURITY
- Title 8: TITLE 8—ALIENS AND NATIONALITY
- Title 15: TITLE 15—COMMERCE AND TRADE
- Title 18: TITLE 18—CRIMES AND CRIMINAL PROCEDURE
- Title 25: TITLE 25—INDIANS
- Title 28: TITLE 28—JUDICIARY AND JUDICIAL PROCEDURE
- Title 30: TITLE 30—MINERAL LANDS AND MINING
- Title 31: TITLE 31—MONEY AND FINANCE
- Title 33: TITLE 33—NAVIGATION AND NAVIGABLE WATERS
- Title 35: TITLE 35—PATENTS
- Title 38: TITLE 38—VETERANS' BENEFITS
- Title 39: TITLE 39—POSTAL SERVICE
- Title 40: TITLE 40—PUBLIC BUILDINGS, PROPERTY, AND WORKS
- Title 44: TITLE 44—PUBLIC PRINTING AND DOCUMENTS
- Title 45: TITLE 45—RAILROADS
- Title 48: TITLE 48—TERRITORIES AND INSULAR POSSESSIONS
- Title 50: TITLE 50—WAR AND NATIONAL DEFENSE

### Type 3: Subtitles → Parts → Chapters (3 titles)
Complex structure with three-level hierarchy.

- Title 10: TITLE 10—ARMED FORCES
- Title 36: TITLE 36—PATRIOTIC AND NATIONAL OBSERVANCES, CEREMONIES, AND ORGANIZATIONS
- Title 46: TITLE 46—SHIPPING

### Type 4: Subtitles → Parts → Subparts → Chapters (3 titles)
Most complex structure with full four-level hierarchy.

- Title 26: TITLE 26—INTERNAL REVENUE CODE
- Title 34: TITLE 34—CRIME CONTROL AND LAW ENFORCEMENT
- Title 52: TITLE 52—VOTING AND ELECTIONS

### Type 5: Parts → Subparts → Chapters (11 titles)
Three-level structure without subtitles.

- Title 7: TITLE 7—AGRICULTURE
- Title 12: TITLE 12—BANKS AND BANKING
- Title 16: TITLE 16—CONSERVATION
- Title 19: TITLE 19—CUSTOMS DUTIES
- Title 20: TITLE 20—EDUCATION
- Title 21: TITLE 21—FOOD AND DRUGS
- Title 22: TITLE 22—FOREIGN RELATIONS AND INTERCOURSE
- Title 29: TITLE 29—LABOR
- Title 42: TITLE 42—THE PUBLIC HEALTH AND WELFARE
- Title 47: TITLE 47—TELECOMMUNICATIONS
- Title 49: TITLE 49—TRANSPORTATION

## Files Generated

### Individual Title Reports
Each title has a dedicated report file in `USA_Laws/Reports/Individual_Titles/` with:
- Complete hierarchical structure
- Download links for all formats (PDF, HTML, Details, MODS, PREMIS)
- Special documents (Table of Contents, Frontmatter, Appendices where applicable)

### JSON Data Files
Each title has a corresponding JSON data file (`title_N_data.json`) containing:
- Complete structure analysis
- All download links
- Hierarchical element details
- Processing metadata

### Summary Files
- `USC_2023_MASTER_INDEX.json`: Complete structured data
- `USC_2023_MASTER_SUMMARY.md`: This readable summary
- Various batch summary files for processing tracking

---

**Extraction completed successfully for all 53 USC titles.**
