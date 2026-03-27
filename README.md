# MoMA Collection Database

A SQLite database builder for the [Museum of Modern Art (MoMA) Collection](https://github.com/MuseumofModernArt/collection) data.

This project converts MoMA's public collection data (JSON format) into a queryable SQLite database for analysis, visualization, and application development.

## Overview

- **Database**: `moma_full.db` (SQLite3)
- **Source**: MoMA Collection repository (git submodule)
- **Records**: ~160,000 artworks, ~15,800 artists
- **Format**: Dynamically generated schema based on JSON structure

## Quick Start

### Prerequisites

- Python 3.7+
- Git with LFS support

### Setup

1. **Clone the repository with submodules:**
   ```bash
   git clone --recursive <this-repo-url>
   ```

2. **If already cloned, initialize the submodule:**
   ```bash
   git submodule update --init --recursive
   ```

3. **Pull the collection data (requires Git LFS):**
   ```bash
   cd collection
   git lfs pull
   cd ..
   ```

### Build the Database

```bash
python build_moma.py
```

The script will:
- Load `collection/Artworks.json` and `collection/Artists.json`
- Dynamically generate schema from JSON structure
- Clean and normalize data (flatten arrays, sanitize strings)
- Create `moma_full.db` with two tables: `artworks` and `artists`

## Database Schema

The schema is **dynamically generated** based on the JSON data structure. Key fields include:

### `artworks` table
- `ObjectID` (PRIMARY KEY)
- `Title`, `Artist`, `Date`
- `Medium`, `Dimensions`
- `Classification`, `Department`
- `URL`, `ThumbnailURL`
- And many more...

### `artists` table
- `ConstituentID` (PRIMARY KEY)
- `DisplayName`, `ArtistBio`
- `Nationality`, `Gender`
- `BeginDate`, `EndDate`
- `Wiki QID`, `ULAN`
- And more...

## Usage Examples

### Query artworks by artist
```sql
SELECT Title, Date, Medium 
FROM artworks 
WHERE Artist LIKE '%Picasso%' 
LIMIT 10;
```

### Find artworks with images
```sql
SELECT ObjectID, Title, ThumbnailURL 
FROM artworks 
WHERE ThumbnailURL IS NOT NULL AND ThumbnailURL != '';
```

### Join artists and artworks
```sql
SELECT a.DisplayName, COUNT(*) as artwork_count
FROM artists a
JOIN artworks w ON w.Artist LIKE '%' || a.DisplayName || '%'
GROUP BY a.DisplayName
ORDER BY artwork_count DESC
LIMIT 20;
```

## Data Cleaning

The builder script (`build_moma.py`) performs the following transformations:

- **Arrays**: Flattened to comma-separated strings
- **Objects**: Serialized as JSON strings
- **String cleanup**: Removes artifact JSON formatting (`["`, `"]`, etc.)
- **Type normalization**: All non-ID fields stored as TEXT

## Git Submodule

The `collection/` directory is a git submodule pointing to:
- **Repository**: https://github.com/MuseumofModernArt/collection
- **License**: CC0 (Public Domain)

### Update to latest MoMA data
```bash
git submodule update --remote collection
python build_moma.py
```

## Project Structure

```
_db_moma-collection/
├── collection/              # Git submodule → MoMA collection
│   ├── Artworks.json       # Source data (Git LFS)
│   └── Artists.json        # Source data (Git LFS)
├── build_moma.py           # Database builder script
├── moma_full.db            # Generated SQLite database
├── .gitignore
├── .gitmodules             # Submodule configuration
├── AGENTS.md               # AI assistant context
└── README.md               # This file
```

## Contributing

This is a personal utility project for NYU coursework. Feel free to fork and adapt for your own use.

## License

- **This repository**: MIT License (or as specified)
- **MoMA Collection data**: [CC0 1.0 Universal (Public Domain)](https://creativecommons.org/publicdomain/zero/1.0/)

## Credits

Data provided by [The Museum of Modern Art (MoMA)](https://www.moma.org/) via their [public collection repository](https://github.com/MuseumofModernArt/collection).

## Related Projects

- [MoMA API Playground](../_app_moma-api) — Interactive documentation for https://api.moma.org

---

*Last updated: March 2026*
