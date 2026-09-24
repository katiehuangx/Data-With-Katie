import re, os

INPUT_FILE = "questions-and-solutions.md"
OUTPUT_DIR = "sql"
os.makedirs(OUTPUT_DIR, exist_ok=True)

with open(INPUT_FILE) as f:
    content = f.read()

sections = re.split(r"(?m)^### (\d+)\.\s*(.+)$", content)

for i in range(1, len(sections), 3):
    num, title, body = sections[i], sections[i+1].strip(), sections[i+2]
    sql_blocks = re.findall(r"```sql\n(.*?)```", body, re.DOTALL)
    if not sql_blocks:
        continue
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    filename = f"{int(num):02d}_{slug}.sql"
    with open(os.path.join(OUTPUT_DIR, filename), "w") as out:
        out.write(f"-- Q{num}: {title}\n\n")
        out.write("\n\n-- ---\n\n".join(b.strip() for b in sql_blocks))
        out.write("\n")
    print(f"Wrote sql/{filename}")