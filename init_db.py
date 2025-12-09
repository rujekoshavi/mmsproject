import sqlite3
import os

DB_NAME = "ProjectDB.db"
SQL_FILE = "PROJECTDB.sql"   # make sure this file is in the same folder


def main():
    if not os.path.exists(SQL_FILE):
        print(f"ERROR: Could not find {SQL_FILE} in this folder.")
        return

    # Read the SQL file
    with open(SQL_FILE, "r", encoding="utf-8") as f:
        sql_script = f.read()

    # Create (or overwrite) the database
    if os.path.exists(DB_NAME):
        print(f"Deleting existing {DB_NAME} so we can recreate it...")
        os.remove(DB_NAME)

    print(f"Creating {DB_NAME}...")
    conn = sqlite3.connect(DB_NAME)
    try:
        conn.executescript(sql_script)
        conn.commit()
        print("Database created successfully and SQL script executed.")
    except Exception as e:
        print("Error while executing SQL script:")
        print(e)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
