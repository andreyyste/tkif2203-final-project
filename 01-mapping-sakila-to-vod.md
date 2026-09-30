# 🔄 Section 1: Sakila to VOD Streaming Service Mapping & Rationale

**Course:** TKIF2203 – Database Technology  
**Project:** Final Project — Modernize the Sakila DB for a Streaming Service  
**Student:** Andrey (TKIF2203)

---

## Overview of Domain Transformation
Sakila was designed for a legacy physical DVD rental store business model (circa 2005). To adapt Sakila for a modern Video-on-Demand (VOD) Streaming Service (e.g., Netflix, Disney+), physical inventory, brick-and-mortar stores, manual disk rentals, and point-of-sale staff must be replaced with digital streaming telemetry, subscriber account hierarchies, episodic content structures, and regional licensing windows.

---

## Complete Table-by-Table Mapping Matrix

| Original Sakila Table | Action Taken | New VOD Streaming Table(s) | Architectural & Business Justification / Rationale |
| :--- | :--- | :--- | :--- |
| `film` | **Split & Evolve** | `contents`, `movies`, `series`, `episodes` | Sakila modeled single standalone films. Streaming platforms distinguish standalone feature films (`movies`) from multi-season TV shows (`series` & `episodes`). Common metadata (title, age rating, description, release year) is centralized in `contents` using Class Table Inheritance to eliminate nullability anomalies. |
| `category` & `film_category` | **Rename & Retain** | `genres` & `content_genres` | Renamed to reflect modern media industry terminology. Preserves the many-to-many relationship between content items and multiple genres. |
| `actor` & `film_actor` | **Rename & Expand** | `cast_members` & `content_cast` | Expanded from "actors" to general cast and crew credits (Directors, Executive Producers, Lead Cast) to support comprehensive media credits. |
| `language` | **Retain & Extend** | `languages` | Retained to track audio dubbing, original audio tracks, and subtitle availability for global localization. |
| `customer` | **Evolve & Split** | `users` & `user_profiles` | In physical DVD rentals, 1 customer = 1 individual. In VOD services, 1 billing account (`users`) supports multiple viewer profiles (`user_profiles` e.g., Kids, Adult) with independent watch histories, parental controls, and watchlists. |
| `address`, `city`, `country` | **Simplify & Focus** | `countries` | Physical street addresses are unnecessary for digital streaming users. Retained `countries` for territory-based content licensing, geoblocking enforcement, and localized pricing tiers. |
| `store` & `staff` | **Drop & Replace** | `content_providers` & `content_licenses` | Physical rental stores and store staff are obsolete in a digital platform. Replaced with studio content licensors (`content_providers`) and digital rights contracts (`content_licenses`) specifying regional start/end availability windows. |
| `inventory` | **Drop** | *(Removed)* | Physical DVD disk copies do not exist in digital cloud streaming. Replaced by digital video file URLs stored per movie/episode. |
| `rental` | **Replace & Expand** | `streaming_sessions` | Physical rental timestamps and disk returns are replaced by event-level digital streaming session telemetry (tracking watch duration in seconds, completion status, max bitrate, device type, and IP). |
| `payment` | **Evolve** | `subscription_plans`, `subscriptions`, `payment_transactions` | Pay-per-rental per disk is replaced with recurring monthly subscription models (Basic, Standard, Premium) and transactional billing logs. |

---

## Detailed Rationale for Key Design Changes

### 1. Split of `film` into `contents`, `movies`, `series`, and `episodes`
- **Problem in Sakila:** Sakila assumes every title is a standalone movie of fixed length.
- **VOD Solution:** Modern platforms host both 2-hour movies and 10-season series with 100+ episodes. Storing series data in a flat table causes severe data duplication or widespread NULL values (e.g., `season_number` NULL for movies, `duration` NULL for series).
- **Design Pattern:** Class Table Inheritance (1:1 between `contents` and `movies`/`series`, and 1:N between `series` and `episodes`).

### 2. Split of `customer` into `users` and `user_profiles`
- **Problem in Sakila:** Sakila binds a customer directly to rentals.
- **VOD Solution:** On streaming platforms, a family shares one subscription account (`users`), but each family member has a distinct profile (`user_profiles`). Binding watch history and recommendations to the account level leads to inaccurate recommendation signals (e.g., mixing cartoon watches with horror movies).
- **Design Pattern:** 1:N relationship from `users` to `user_profiles`.

### 3. Transition from `rental` to `streaming_sessions`
- **Problem in Sakila:** `rental` tracks physical check-out and return dates.
- **VOD Solution:** Streaming requires high-cardinality telemetry recording exact playback start/end timestamps, watch duration in seconds, completion flags (to measure drop-offs), device IDs, and bitrate logs for Quality-of-Experience (QoE) tracking.
