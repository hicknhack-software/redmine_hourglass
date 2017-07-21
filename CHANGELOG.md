# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
The first enhancement release which adds plenty of new feature which were long time overdue. Some of the things were requested several years before and were finally possible.

### Added
- custom field support, all of our models now support the various custom fields you can create, either as a filter or in case of time booking and time tracker als as fillable fields
- you can now set up activity default per user, which will be automatically used for time trackers and bookings
- there is now version filter for time trackers
- a qr code on the overview page intended to help integrating the upcoming companion app
- error messages for client side validations
- direct links from running time tracker to issue and project

### Changed
- we improved the timezone handling cause there was a synchronisation problem between client and server

### Removed
- ability to remove time logs with time bookings, you now need to remove the time booking first

## [1.0.0] - 2017.??.??
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
- dropped support for redmine below version 3.2
- dropped support for ruby below 2.0.0
- removed the extra report tab, it's now merged in the time bookings tab
- removed the continue feature for time bookings (if you want this back, consider giving a +1 [here](https://github.com/hicknhack-software/redmine_hourglass/issues/3))
