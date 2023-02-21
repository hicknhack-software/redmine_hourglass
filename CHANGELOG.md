# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased] - TBA

### Added
- [please add new features]

### Changed
- [please add noteworthy changes]

### Removed
- [please add dropped features]

### Fixed
- [please add bug fixes]

## [1.2.0] - 2023-02-21

Non-Beta Release after proving that everything works.

### Changed
- added more time clamping options
- many bugfixes
- fixed styling
- fixed timer stops when brower tab in background

### Known issues
- no support for Redmine 5

## [1.2.0-beta] - 2021-06-27

Upgraded to support Redmine 4.2.1

### Changed
- resolved blockers for current Redmine versions
- dropped support for older Redmine versions

### Fixed
- issue filter for administrators works as expected
- update for issue, project and activity work normal

## [1.1.2] - 2019-04-18

Bugfix release.

### Changed
- enhanced activity display in report by adding a dash

### Fixed
- fixed issue where changes to the project filter in time bookings queries would corrupt activity and user filters

## [1.1.1] - 2019-04-04

Bugfix release.

### Fixed
- creating & updating saved queries for time logs, time bookings and tracker
- position of the edit & delete buttons for saved queries for hourglass views

## [1.1.0] - 2019-03-25

First release with Redmine 4.0 support.
Redmine versions 3.x are still supported, but will be removed in future releases.

### Added
- support for Redmine version 4.0.0 and above
- backend and frontend validation of settings

### Changed
- improved testing of multiple databases

### Fixed
- removal of database specific tests that led to errors
- enhanced datetime parsing
- enhanced filters of time logs


## [1.0.0] - 2019-02-26

This is the first mature release after a long beta testing period.
We added plenty of new features which were long time overdue.
Some of the things were requested several years before and were finally possible.

### Added
- functionality is available as an API, so desktop and mobile clients are possible
- rounding can be configured to only affect sums
- proper support for grouping entries in list views
- project specific plugin settings
- time trackers can now be queried
- direct links from running time tracker to issue and project
- error messages for client side validations
- a qr code on the overview page intended to help integrating the upcoming companion app
- there is now version filter for time trackers
- you can now set up activity default per user, which will be automatically used for time trackers and bookings

### Changed
- rounding is now only for time bookings instead of time logs
- enhanced access rights
- changed data structure massively, if anyone relied on the database tables, please update your code
- we improved the timezone handling cause there was a synchronisation problem between client and server

### Removed
- dropped support for Redmine below version 3.2
- dropped support for Ruby below 2.0.0
- removed the extra report tab, it's now merged in the time bookings tab
- ability to remove time logs with time bookings, you now need to remove the time booking first
