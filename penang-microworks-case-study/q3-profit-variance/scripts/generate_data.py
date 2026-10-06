"""
Generate fictional FY2026 data for Penang Microworks Sdn Bhd.
Case study 1: Where did Q3 profit go?

Budget covers Jan-Dec 2026. Actuals cover Jan-Sep 2026.
Amounts follow the GL sign convention: debits positive, credits negative
(revenue is negative, costs are positive).

Run from the case study folder:
    python3 scripts/generate_data.py
"""
import csv
import random
from datetime import date
from pathlib import Path

random.seed(2026)  # same data every run

OUT = Path(__file__).resolve().parent.parent / "data"
OUT.mkdir(exist_ok=True)

MONTHS = [date(2026, m, 1) for m in range(1, 13)]
ACTUAL_MONTHS = MONTHS[:9]  # Jan-Sep

# Monthly multiplier on units (Feb = Chinese New Year, Oct-Nov = pre-holiday build)
SEASONALITY = {1: 0.90, 2: 0.85, 3: 0.95, 4: 1.00, 5: 1.00, 6: 1.00,
               7: 1.00, 8: 1.05, 9: 1.05, 10: 1.10, 11: 1.10, 12: 1.00}

# ---------------------------------------------------------------- master data
ACCOUNTS = [
    # account_id, code, name, type, fs_line, fs_sort_order
    (1, "4000", "Product sales", "Revenue", "Revenue", 10),
    (2, "4100", "Sales returns and allowances", "Revenue", "Revenue", 10),
    (3, "5000", "Direct materials", "COGS", "Cost of sales", 20),
    (4, "5100", "Direct labour", "COGS", "Cost of sales", 20),
    (5, "5200", "Manufacturing overhead", "COGS", "Cost of sales", 20),
    (6, "6000", "Salaries and wages", "Opex", "Staff costs", 40),
    (7, "6100", "EPF, SOCSO and EIS contributions", "Opex", "Staff costs", 40),
    (8, "6200", "Rent and utilities", "Opex", "Facilities", 50),
    (9, "6300", "Depreciation", "Opex", "Depreciation", 60),
    (10, "6400", "Travel", "Opex", "Other operating expenses", 70),
    (11, "6500", "Professional fees", "Opex", "Other operating expenses", 70),
    (12, "6600", "Marketing", "Opex", "Other operating expenses", 70),
]
ACC = {code: aid for aid, code, *_ in ACCOUNTS}

DEPARTMENTS = [
    # department_id, cost_center_code, name, budget heads, monthly cost per head (RM)
    (1, "CC100", "Engineering", 45, 9000),
    (2, "CC200", "Operations", 25, 6000),
    (3, "CC300", "Sales & Marketing", 15, 8000),
    (4, "CC400", "G&A", 18, 7000),
]

PRODUCTS = [
    # product_id, code, name, family, budget ASP (RM), base monthly units, budget GP%
    (1, "SEN-100", "Temperature sensor module", "Sensor modules", 85, 20000, 0.45),
    (2, "SEN-200", "Pressure sensor module", "Sensor modules", 120, 12000, 0.45),
    (3, "PWR-100", "DC-DC converter module", "Power modules", 60, 30000, 0.25),
    (4, "PWR-200", "Battery management module", "Power modules", 150, 8000, 0.25),
    (5, "CON-100", "Wi-Fi/Bluetooth board", "Connectivity boards", 45, 25000, 0.35),
    (6, "CON-200", "Industrial Ethernet board", "Connectivity boards", 180, 5000, 0.35),
]

COGS_SPLIT = {"5000": 0.70, "5100": 0.12, "5200": 0.18}
RETURNS_RATE = 0.01
STATUTORY_RATE = 0.14  # EPF + SOCSO + EIS, employer share (approx.)

# Shared non-staff costs: monthly budget and allocation % by department_id
SHARED_COSTS = {
    "6200": (200_000, {1: 0.40, 2: 0.25, 3: 0.10, 4: 0.25}),  # rent and utilities
    "6300": (220_000, {1: 0.60, 2: 0.20, 4: 0.20}),           # depreciation
    "6400": (50_000, {1: 0.25, 2: 0.15, 3: 0.50, 4: 0.10}),   # travel
    "6500": (60_000, {1: 0.20, 4: 0.80}),                     # professional fees
    "6600": (90_000, {3: 1.00}),                              # marketing
}


# ---------------------------------------------------------------- the stories
def units_factor(family, month):
    if family == "Sensor modules" and month >= 7:
        return 0.88   # Story 1: key automotive customer cuts orders from July
    if family == "Connectivity boards" and month in (7, 8, 9):
        return 1.08   # Story 4: favourable volume, but lower margin (mix)
    return 1.0


def price_factor(family, month):
    if family == "Power modules" and month >= 4:
        return 0.95   # Story 2: competitor undercuts prices from April
    return 1.0


def actual_heads(dept_id, budget_heads, month):
    if dept_id == 1 and month >= 6:
        return budget_heads + 6  # Story 3: Engineering hires ahead of plan from June
    return budget_heads


def noise(spread):
    return random.uniform(1 - spread, 1 + spread)


def r2(x):
    return round(x, 2)


# ---------------------------------------------------------------- generators
def build_budget():
    rows, sales = [], {}
    for m in MONTHS:
        for pid, _, _, fam, asp, base, gp in PRODUCTS:
            units = round(base * SEASONALITY[m.month])
            rev = r2(units * asp)
            sales[(m, pid)] = (units, rev)
            rows.append((m, ACC["4000"], None, pid, -rev))
            rows.append((m, ACC["4100"], None, pid, r2(rev * RETURNS_RATE)))
            cogs = units * asp * (1 - gp)
            for code, share in COGS_SPLIT.items():
                rows.append((m, ACC[code], None, pid, r2(cogs * share)))
        for did, _, _, heads, cph in DEPARTMENTS:
            sal = heads * cph
            rows.append((m, ACC["6000"], did, None, r2(sal)))
            rows.append((m, ACC["6100"], did, None, r2(sal * STATUTORY_RATE)))
        for code, (total, alloc) in SHARED_COSTS.items():
            for did, pct in alloc.items():
                rows.append((m, ACC[code], did, None, r2(total * pct)))
    return rows, sales


def build_actuals():
    rows, sales = [], {}
    for m in ACTUAL_MONTHS:
        for pid, _, _, fam, asp, base, gp in PRODUCTS:
            budget_units = base * SEASONALITY[m.month]
            units = round(budget_units * units_factor(fam, m.month) * noise(0.03))
            price = asp * price_factor(fam, m.month) * noise(0.01)
            rev = r2(units * price)
            sales[(m, pid)] = (units, rev)

            # Revenue posted as 4 invoice batches per product per month
            weights = [random.uniform(0.2, 0.3) for _ in range(4)]
            total_w = sum(weights)
            posted = 0.0
            for i, w in enumerate(weights):
                amt = r2(rev - posted) if i == 3 else r2(rev * w / total_w)
                posted = r2(posted + amt)
                rows.append((m, ACC["4000"], None, pid, -amt))

            rows.append((m, ACC["4100"], None, pid, r2(rev * RETURNS_RATE * noise(0.10))))

            # Unit cost stays at standard, so price cuts squeeze margin
            cogs = units * asp * (1 - gp) * noise(0.02)
            for code, share in COGS_SPLIT.items():
                rows.append((m, ACC[code], None, pid, r2(cogs * share)))

        for did, _, _, heads, cph in DEPARTMENTS:
            sal = actual_heads(did, heads, m.month) * cph * noise(0.01)
            rows.append((m, ACC["6000"], did, None, r2(sal)))
            rows.append((m, ACC["6100"], did, None, r2(sal * STATUTORY_RATE)))

        for code, (total, alloc) in SHARED_COSTS.items():
            if code == "6300":
                month_total = total                      # depreciation is fixed
            elif code == "6400":
                month_total = total * noise(0.15)
            elif code == "6600" and m.month == 6:
                month_total = total * 3                  # genuine one-off: June trade show
            else:
                month_total = total * noise(0.08)
            for did, pct in alloc.items():
                rows.append((m, ACC[code], did, None, r2(month_total * pct)))
    return rows, sales


def add_line_ids(rows):
    return [dict(line_id=i, month=m, account_id=a, department_id=d, product_id=p, amount=amt)
            for i, (m, a, d, p, amt) in enumerate(rows, start=1)]


def plant_dq_issues(rows):
    """Deliberately bad records for the data quality checks to find."""
    next_id = max(r["line_id"] for r in rows) + 1
    log = []

    # 1. NULL column: an August S&M travel line loses its department
    for r in rows:
        if r["month"] == date(2026, 8, 1) and r["account_id"] == ACC["6400"] and r["department_id"] == 3:
            r["department_id"] = None
            log.append(f"NULL department_id on line {r['line_id']} (Aug travel)")
            break

    # 2. Future date: a line dated October when actuals run to September
    rows.append(dict(line_id=next_id, month=date(2026, 10, 1), account_id=ACC["6500"],
                     department_id=4, product_id=None, amount=15_000.00))
    log.append(f"Future-dated line {next_id} (Oct 2026 professional fees)")
    next_id += 1

    # 3. Duplicate: a September revenue batch loaded twice (same line_id)
    dup = next(r for r in rows if r["month"] == date(2026, 9, 1)
               and r["account_id"] == ACC["4000"] and r["product_id"] == 6)
    rows.append(dict(dup))
    log.append(f"Duplicate of line {dup['line_id']} (Sep CON-200 revenue, {dup['amount']})")

    # 4. Missing mandatory fields: no account, and no amount
    rows.append(dict(line_id=next_id, month=date(2026, 7, 1), account_id=None,
                     department_id=4, product_id=None, amount=12_345.67))
    log.append(f"Missing account_id on line {next_id}")
    next_id += 1
    rows.append(dict(line_id=next_id, month=date(2026, 9, 1), account_id=ACC["6400"],
                     department_id=1, product_id=None, amount=None))
    log.append(f"Missing amount on line {next_id}")
    next_id += 1

    # 5. Unseen value: account 99 isn't in the chart of accounts
    rows.append(dict(line_id=next_id, month=date(2026, 8, 1), account_id=99,
                     department_id=1, product_id=None, amount=18_500.00))
    log.append(f"Unmapped account_id 99 on line {next_id} (looks like software subscriptions)")

    # 6. Month-over-month anomaly: June marketing at ~3x normal is genuine (trade show)
    log.append("June marketing ~3x normal: a genuine trade show, not an error")
    return rows, log


# ---------------------------------------------------------------- write files
def write_csv(name, header, rows):
    with open(OUT / name, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        for row in rows:
            w.writerow(["" if v is None else v for v in row])


def main():
    budget_rows, budget_sales = build_budget()
    actual_rows, actual_sales = build_actuals()
    actuals = add_line_ids(actual_rows)
    clean_actuals = [dict(r) for r in actuals]  # kept for the summary check
    actuals, dq_log = plant_dq_issues(actuals)

    write_csv("accounts.csv",
              ["account_id", "account_code", "account_name", "account_type", "fs_line", "fs_sort_order"],
              ACCOUNTS)
    write_csv("departments.csv", ["department_id", "cost_center_code", "department_name"],
              [d[:3] for d in DEPARTMENTS])
    write_csv("products.csv", ["product_id", "product_code", "product_name", "product_family"],
              [p[:4] for p in PRODUCTS])

    gl_header = ["line_id", "month", "account_id", "department_id", "product_id", "amount"]
    write_csv("gl_actuals.csv", gl_header,
              [[r[k] for k in gl_header] for r in actuals])
    write_csv("gl_budget.csv", gl_header,
              [[i, *row] for i, row in enumerate(budget_rows, start=1)])

    sales_rows = []
    for m in MONTHS:
        for pid, *_ in PRODUCTS:
            b_units, b_rev = budget_sales[(m, pid)]
            a_units, a_rev = actual_sales.get((m, pid), (None, None))
            sales_rows.append((m, pid, a_units, a_rev, b_units, b_rev))
    write_csv("sales_volume.csv",
              ["month", "product_id", "actual_units", "actual_revenue", "budget_units", "budget_revenue"],
              sales_rows)

    # ---- summary: Q3 operating profit, budget vs actual (clean data, flipped to report signs)
    q3 = {date(2026, 7, 1), date(2026, 8, 1), date(2026, 9, 1)}
    bud_op = -sum(amt for m, _, _, _, amt in budget_rows if m in q3)
    act_op = -sum(r["amount"] for r in clean_actuals if r["month"] in q3)
    print(f"Q3 operating profit  budget: RM{bud_op:,.0f}  actual: RM{act_op:,.0f}  "
          f"variance: RM{act_op - bud_op:,.0f} ({(act_op - bud_op) / bud_op:.1%})")
    fy_rev = sum(rev for (_, _), (_, rev) in budget_sales.items())
    fy_op = -sum(amt for *_, amt in budget_rows)
    print(f"FY2026 budget  revenue: RM{fy_rev:,.0f}  operating profit: RM{fy_op:,.0f} ({fy_op / fy_rev:.1%})")
    print(f"Rows  gl_actuals: {len(actuals)}  gl_budget: {len(budget_rows)}  sales_volume: {len(sales_rows)}")
    print("Planted data quality issues:")
    for line in dq_log:
        print("  -", line)


if __name__ == "__main__":
    main()
