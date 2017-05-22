# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
We are basically in feature parity to the redmine time tracker plugins [latest version](https://github.com/hicknhack-software/redmine_time_tracker). Notable changes to this version are listed below.

### Added
- functionality is available as an api, so desktop and mobile clients are possible 
- rounding can be configured to only affect sums 
- proper support for grouping entries in list views
- project specific plugin settings
- time trackers can now be queried

### Changed
- rounding is now only for time bookings instead of time logs
- enhanced access rights
- changed data structure massively, if anyone relied on the database tables, please update your code

### Removed
- dropped support for redmine below version 3
- dropped support for ruby below 2.0.0
- removed the extra report tab, it's now merged in the time bookings tab
- removed the continue feature for time bookings (if you want this back, consider giving a +1 here: #3)
