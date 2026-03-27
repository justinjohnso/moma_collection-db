# MoMA Collection Database

A SQLite database builder for the [Museum of Modern Art (MoMA) Collection](https://github.com/MuseumofModernArt/collection) data with **automatic rebuilding** when the source data updates.

This project converts MoMA's public collection data (JSON format) into a queryable SQLite database for analysis, visualization, and application development.

## Features

- 🔄 **Automatic Updates**: Database rebuilds automatically when you pull changes
- 📊 **~160,000 Artworks**: Full MoMA collection in SQLite format  
- 🎨 **~15,800 Artists**: Complete artist biographies and metadata
- 🚀 **Dynamic Schema**: Auto-generated from JSON structure
- 🧹 **Clean Data**: Normalized arrays, sanitized strings, consistent types

## Quick Start

### Prerequisites

- **Python 3.7+**
- **Git** with **Git LFS** support
  - macOS: `brew install git-lfs && git lfs install`
  - Ubuntu/Debian: `apt-get install git-lfs && git lfs install`

### Setup

1. **Clone the repository with submodules:**
   ```bash
   git clone --recursive git@github.com:justinjohnso/_db_moma-collection.git
   cd _db_moma-collection
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

   This will:
   - Configure git hooks for automatic database rebuilding
   - Initialize and download the collection submodule
   - Pull Git LFS data files
   - Build the initial database

3. **You're done!** The database is now in `moma_full.db`

## Automatic Updates

The database **automatically rebuilds** when the collection data changes:

```bash
git pull
```

If the upstream collection was updated, you'll see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Collection submodule updated - rebuilding database...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 Updating submodule files...
📦 Pulling LFS files...
🏗️  Rebuilding database...
✅ Database rebuilt successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Manual Rebuild

If you need to rebuild the database manually:

```bash
python3 build_moma.py
```

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

- **Arrays**: Flattened to comma-separated strings (e.g., `["Paris", "New York"]` → `"Paris, New York"`)
- **Objects**: Serialized as JSON strings for complex nested data
- **String cleanup**: Removes artifact JSON formatting from strings (`["`, `"]`, etc.)
- **Type normalization**: All non-ID fields stored as TEXT for flexibility
- **Primary keys**: `ObjectID` for artworks, `ConstituentID` for artists (both INTEGER)

The build process:
1. Loads JSON files from `collection/` directory
2. Analyzes schema dynamically from all records
3. Drops existing tables (if any) and recreates fresh
4. Cleans and inserts all records in batch
5. Typical build time: 10-30 seconds depending on hardware

## Git Submodule

The `collection/` directory is a git submodule pointing to:
- **Repository**: https://github.com/MuseumofModernArt/collection
- **License**: CC0 (Public Domain)
- **Documentation**: See `collection/README.md` for MoMA's official documentation

The submodule data is automatically kept in sync with your pulls. To manually update to the absolute latest from MoMA:

```bash
git submodule update --remote collection
cd collection && git lfs pull && cd ..
python3 build_moma.py  # Rebuild with new data
```

## Project Structure

```
_db_moma-collection/
├── collection/              # Git submodule → MoMA collection data
│   ├── Artworks.json       # Source data (Git LFS, ~138MB)
│   ├── Artists.json        # Source data (Git LFS, ~3.4MB)
│   └── README.md           # MoMA's collection documentation
├── .githooks/              # Git hooks (version controlled)
│   └── post-merge          # Auto-rebuild trigger
├── build_moma.py           # Database builder script
├── setup.sh                # One-time setup script
├── moma_full.db            # Generated SQLite database (~72MB)
├── .gitignore              # Git ignore patterns
├── .gitmodules             # Submodule configuration
├── AGENTS.md               # AI assistant context
└── README.md               # This file
```

## How It Works

The automatic rebuild system uses a git hook:

1. **Setup**: `./setup.sh` configures git to use hooks from `.githooks/` directory
2. **Hook trigger**: `.githooks/post-merge` runs after `git pull` or `git merge`
3. **Change detection**: Hook checks if the `collection/` submodule commit changed
4. **Automatic rebuild**: If changed, runs `python3 build_moma.py` automatically
5. **Result**: `moma_full.db` is regenerated and always in sync with collection data

This approach is distribution-ready because:
- Hooks are version-controlled in `.githooks/` directory
- No manual copying to `.git/hooks/` needed
- Works immediately after running `./setup.sh`
- Safe: hook errors don't fail your git operations
- Database file is pre-built and tracked in git for immediate use

### Using This Repo as a Submodule

If you're including this repo as a git submodule in another project:

- ✅ **Pre-built database**: `moma_full.db` is tracked in git and available immediately
- ✅ **Hooks are isolated**: This repo's hooks won't affect your parent repository
- ✅ **Builder script available**: You can rebuild manually with `python3 build_moma.py`
- 📝 **No automatic updates**: Hooks only work in standalone mode, not as submodule

Example workflow from parent repo:
```bash
# Add as submodule
git submodule add git@github.com:justinjohnso/_db_moma-collection.git vendor/moma-db

# Update submodule to latest
git submodule update --remote vendor/moma-db

# Rebuild database if needed
cd vendor/moma-db
python3 build_moma.py
cd ../..
```

## Troubleshooting

**Hook not running after git pull?**
- Check: `git config --get core.hooksPath` should return `.githooks`
- Fix: Run `./setup.sh` again

**Database not building?**
- Ensure Python 3 is installed: `python3 --version`
- Ensure Git LFS is installed: `git lfs version`
- Check collection files exist: `ls -lh collection/*.json`
- Rebuild manually: `python3 build_moma.py`

**Fresh clone setup:**
```bash
git clone --recursive git@github.com:justinjohnso/_db_moma-collection.git
cd _db_moma-collection
./setup.sh
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
