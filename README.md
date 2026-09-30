# 🍿 VOD Streaming Service Database Architecture (TKIF2203 Final Project)

**Course:** TKIF2203 – Database Technology  
**Instructor:** Dr. Guntur D Putra  
**Student Account:** andreyyste (TKIF2203)

---

## 📌 Project Overview
This repository contains the complete relational database architecture, SQL DDL scripts, sample datasets, and analytical queries for modernizing the classic **Sakila DVD rental database** into a modern **Video-on-Demand (VOD) Streaming Service** (e.g., Netflix, Disney+).

---

## 📂 Repository Contents & Deliverables

| File / Artifact | Description | Assessment Weight |
| :--- | :--- | :--- |
| 📄 **[01-mapping-sakila-to-vod.md](01-mapping-sakila-to-vod.md)** | Table-by-table mapping from Sakila to VOD Streaming with business rationales. | 20% |
| 📐 **[02-erd-and-logical-schema.md](02-erd-and-logical-schema.md)** | Logical Schema specifications & Mermaid Crow's Foot ERD diagram. | 20% |
| 🛠️ **[03-schema-ddl.sql](03-schema-ddl.sql)** | Production-grade PostgreSQL DDL script with PKs, FKs, CHECK constraints, and Indexes. | 20% |
| 📊 **[04-analytics-queries.sql](04-analytics-queries.sql)** | 6 Business Intelligence analytics queries + OLAP aggregate summary table ETL pipeline. | 20% |
| 📥 **[05-sample-data.sql](05-sample-data.sql)** | Realistic sample dataset across all core tables (>20 playback event logs). | 10% |
| 📝 **[06-final-report.md](06-final-report.md)** | Executive report covering design choices, 3NF vs OLAP tradeoffs, indexing, and GDPR/PII. | 10% |

---

## 📚 Study Guides & Interview Prep

- 🎯 **[INTERVIEW-PREPARATION.md](INTERVIEW-PREPARATION.md)**: Full answers to all 17 potential interview questions.
- 📐 **[DETAIL-RELASI-TABEL.md](DETAIL-RELASI-TABEL.md)**: Detailed breakdown of 15 table relationships including 4 Many-to-Many junction tables.
- 📘 **[PANDUAN-FINAL-PROJECT.md](PANDUAN-FINAL-PROJECT.md)**: Quick tutorial and execution roadmap.

---

## 🚀 Quickstart Guide (Local PostgreSQL Docker Setup)

```bash
# 1. Start Docker container stack (PostgreSQL + pgAdmin)
docker compose up -d

# 2. Run DDL schema creation
docker exec -i postgres_lab psql -U admin -d learning_db < 03-schema-ddl.sql

# 3. Populate sample dataset
docker exec -i postgres_lab psql -U admin -d learning_db < 05-sample-data.sql

# 4. Execute analytics queries
docker exec -i postgres_lab psql -U admin -d learning_db < 04-analytics-queries.sql
```
