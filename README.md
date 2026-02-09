# Azure SQL Cost Analysis (End-to-End Data Analytics Project)

## 📌 Project Overview
This project demonstrates an **end-to-end cost analysis solution** using **Azure SQL, Python, SQL, and Power BI**.

The goal was to simulate a **real-world construction / infrastructure cost reporting system**, build a clean data model, load data programmatically, and create an **interactive Power BI dashboard** for decision-makers.

This mirrors how cost data is handled in enterprise environments like construction, engineering, and infrastructure companies.

---

## 🧱 Architecture & Flow
**Data Flow:**

Azure SQL Database  
→ Python (data generation & loading)  
→ SQL (data modelling & constraints)  
→ Power BI (reporting & dashboards)

---

## 🛠️ Tools & Technologies Used

| Tool | Purpose |
|----|----|
| **Azure SQL Database** | Cloud database to store fact & dimension tables |
| **SQL (T-SQL)** | Schema creation, constraints, relationships |
| **Python (pandas, pyodbc, numpy, faker)** | Data generation & loading |
| **Power BI** | Interactive dashboards & KPIs |
| **GitHub** | Version control & portfolio |

---

## 🗄️ Data Model (Star Schema)

### Fact Table
- **FactCost**
  - CommittedCost
  - ActualCost
  - ForecastEAC
  - ApprovedVariation
  - PendingVariation
  - CurrencyCode
  - LoadKey

### Dimension Tables
- **DimDate**
- **DimProject**
- **DimSupplier**
- **DimPackage**

Each fact record links to dimensions using surrogate keys.

---

## 🐍 Why Python Was Used (Important)
Although SQL alone could insert data, **Python was used to simulate a real production pipeline**:

- Generate realistic synthetic data
- Enforce uniqueness (`LoadKey`)
- Avoid duplicate inserts (idempotent loads)
- Bulk insert efficiently using `executemany`
- Mimic ETL processes used in real companies

👉 This reflects **real analyst / data engineer workflows**, not just ad-hoc SQL scripts.

---

## 📄 What the Python Code Does (High Level)

### 1️⃣ Connects to Azure SQL
- Uses `pyodbc`
- Secure encrypted connection
- Reusable connection logic

### 2️⃣ Generates Dimension Data
- Dates (calendar logic)
- Projects, suppliers, packages
- Flags like `IsCurrent`, `IsPreferred`

### 3️⃣ Generates Fact Data
- Random but realistic cost values
- Links facts to dimension keys
- Creates a **unique LoadKey** per row

### 4️⃣ Loads Data Safely
- Skips duplicates
- Uses bulk inserts
- Commits only when successful

---

## 📊 Power BI Reports

### Page 1 — Executive Cost Overview
- KPI Cards:
  - Total Committed (£)
  - Total EAC (£)
  - Variance (£)
  - Variance (%)
- Monthly cost trends
- Variance by month
- Date slicer

### Page 2 — Detailed Cost Analysis
- Top 10 Projects by Actual Cost
- Top 10 Suppliers by Actual Cost
- Detailed cost table
- Conditional formatting for variance
- Project & Supplier slicers
- Tooltip-enabled visuals

---

## 🎯 Key Business Insights Enabled
- Identify cost overruns early
- Compare committed vs actual spend
- Track supplier impact on cost
- Monitor trends over time
- Support executive decision-making

---

## 🔐 Security Notes
- Credentials are **not committed**
- Synthetic data only
- No production or client data used

---

## 📸 Screenshots
Screenshots of the Power BI dashboard are included in the `/screenshots` folder.

---

## 🚀 What This Project Demonstrates
✔ Cloud SQL experience  
✔ Python-driven data pipelines  
✔ Data modelling (star schema)  
✔ Power BI storytelling  
✔ Real-world cost analytics  

## 📸 Dashboard Screenshots

### Executive Overview
![Executive Overview](screenshots/overview.png)

### Cost Analysis Details
![Cost Analysis](screenshots/detail.png)


---

## 📬 Contact
If you’d like to discuss this project or similar analytics work, feel free to connect with me on LinkedIn.

---

⭐ If you found this project interesting, feel free to star the repo!
