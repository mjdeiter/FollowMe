# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-06-14

### Added
- Zone-based "standby" feature:
  - New **Standby in listed zones** checkbox (on by default) to enable/disable automatic standby.
  - Configurable list of standby zones, pre-populated with `nexus`, `poknowledge`, and `tranquility` (The Nexus, Plane of Knowledge, Plane of Tranquility).
  - UI to add new zones by short name via a text input and **Add** button (auto-lowercased, de-duplicated).
  - Dropdown to view configured standby zones, with a **Remove Selected** button.
  - When in a standby zone, automatic firing pauses, status shows `Standby (zone: <shortname>)`, and the progress bar shows a "Standby - zone excluded" indicator.
  - **Fire Once** continues to work manually even while in standby.

## [1.0.0] - Initial release

### Added
- Core script: periodically sends `/e3bcg /nav id <driver ID>` on a configurable interval (1.0–30.0 seconds).
- ImGui control panel with:
  - Interval slider
  - START/STOP toggle
  - Fire Once button
  - Status text with color-coded states (idle, running, fired)
  - Progress bar showing time until next fire
