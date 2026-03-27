import json
import sqlite3
import re
from pathlib import Path

db_file = Path("moma_full.db")
artworks_file = Path("collection/Artworks.json")
artists_file = Path("collection/Artists.json")

def load_json(filepath):
    print(f"Loading {filepath}...")
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)

def clean_value(val):
    if val is None:
        return None
    
    # Flatten actual Python lists to comma-separated strings
    if isinstance(val, list):
        val = ", ".join(str(v) for v in val if v is not None)
    elif isinstance(val, dict):
        return json.dumps(val)
        
    # Strip anomalous JSON-style array formatting out of strings
    if isinstance(val, str):
        val = re.sub(r'\["|"]', '', val)
        val = re.sub(r'","', ', ', val)
        val = re.sub(r'\[|]', '', val)
        
    return val

def build_dynamic_table(conn, table_name, data, pk_field):
    if not data:
        return
        
    print(f"Analyzing schema for {table_name}...")
    
    all_keys = set()
    for item in data:
        all_keys.update(item.keys())
        
    columns = [pk_field] + [k for k in sorted(list(all_keys)) if k != pk_field]
    
    col_defs = []
    for col in columns:
        safe_col = f'"{col}"'
        if col == pk_field:
            col_defs.append(f"{safe_col} INTEGER PRIMARY KEY")
        else:
            col_defs.append(f"{safe_col} TEXT")
            
    cur = conn.cursor()
    cur.execute(f"DROP TABLE IF EXISTS {table_name};")
    cur.execute(f"CREATE TABLE {table_name} ({', '.join(col_defs)});")
    
    print(f"Cleaning and inserting {len(data)} records into {table_name}...")
    placeholders = ", ".join(["?"] * len(columns))
    insert_sql = f"INSERT INTO {table_name} ({', '.join(['\"'+c+'\"' for c in columns])}) VALUES ({placeholders})"
    
    records = []
    for item in data:
        row = [clean_value(item.get(col)) for col in columns]
        records.append(row)
        
    cur.executemany(insert_sql, records)
    conn.commit()

if __name__ == "__main__":
    if not artworks_file.exists() or not artists_file.exists():
        print("Missing JSON files. Run 'git lfs pull' in the collection directory.")
        exit(1)
        
    conn = sqlite3.connect(db_file)
    
    build_dynamic_table(conn, "artworks", load_json(artworks_file), "ObjectID")
    build_dynamic_table(conn, "artists", load_json(artists_file), "ConstituentID")
    
    conn.close()
    print(f"Cleaned database built successfully at {db_file.absolute()}")