[![Dependency Status](https://gemnasium.com/hicknhack-software/redmine_hourglass.png)](https://gemnasium.com/hicknhack-software/redmine_hourglass)
[![Code Climate](https://codeclimate.com/github/hicknhack-software/redmine_hourglass.png)](https://codeclimate.com/github/hicknhack-software/redmine_hourglass)
[![Build Status](https://travis-ci.org/hicknhack-software/redmine_hourglass.png)](https://travis-ci.org/hicknhack-software/redmine_hourglass)

# Redmine Hourglass Plugin
 
 Hourglass is a Redmine plugin to aid in tracking spent time on projects and issues. It allows users to start / stop a timer with an optional reference to what they are working on.
  
  It allows various queries for time entries as well as possibilities to update existing entries.
  
  Hourglass can be configured on a global base as well as per project.

_Note: This is a complete rewrite of the [Redmine Time Tracker Plugin](https://github.com/hicknhack-software/redmine_time_tracker). While it has feature parity (atleast we hope we didn't forget anything), the code base has changed positively, so further additions are no longer a pain to do._

_We already did some additions to the existing version, see [CHANGELOG.md](CHANGELOG.md) for details._
 
## Features
- Per user time tracking
- Integrates well with redmine by reusing time entries
- Overview of spent time for users
- Track project unrelated time
- Book tracked time on issues
- Detailed statistics for team management
- Status monitor of currently running trackers
- Detailed list views with redmine queries integrated
- Report generation for projects with graphical time representation with customizable company logo
- Project specific settings

## Requirements
* Ruby >= 2.0.0
* Redmine >= 3.0.0

See [.travis.yml](.travis.yml) for details about supported version. If a newer version doesn't appear in there, feel free to open an issue and report your experience with that redmine or ruby version.

## Installation

1. Download and put the plugin code in `plugins/redmine_hourglass`. For example by issuing `git clone https://github.com/hicknhack-software/redmine_hourglass.git` in the `plugins` directory.
1. Run `bundle install` to install necessary gems.
1. Run `rake redmine:plugins:migrate RAILS_ENV=production`
1. Run `rake redmine:plugins:assets RAILS_ENV=production`. (If you redmine is deployed in a subfolder like `www.example.com/redmine` you need to add `RAILS_RELATIVE_URL_ROOT=/redmine` to that task like this `rake redmine:plugins:assets RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/redmine`)
1. (Re)start your redmine
1. The plugin is now installed and can be used.

## Update

The process is roughly the same as installing. Make sure you have the desired version in the `plugins` directory and run the steps 2 - 5 from above.

If you had it installed via git before, the first step is simply doing `git pull` in the `plugins/redmine_hourglass` directory.

## Usage

1. Login as an administrator and setup the permissions for your roles
1. Enable the "Hourglass" module for your project
1. You should now see the Time Tracking link in the top menu
                    
To track time directly on an issue, you can use the context menu (right click in the issues list) in
the issue list to start or stop the timer or press the "Start Tracking" button on the top right, next to the default "Book Time" Redmine button.


### What's what?

The plugin is intended to help us create invoices for customers. This requires the separation of time that was spent and time that is booked. Only booked times can be billed.
More information are available in the [wiki](http://github.com/hicknhack-software/redmine_hourglass/wiki).

#### Time Tracker

The stop watch. Time you spent gets "generated" by the trackers.

#### Time Log

A time log is a spent amount of time. If you stop the tracker, a time log is created. A time log has nothing attached to it. To add this time to issues or projects, you **book** time.
Role permissions can be edited to disable logging. This might be useful for reviewers, that do not generate time on their own but want to look up statistics on a project or user.

#### Time Booking

A booking is time that is actually connected to a task (project or issue). To create a booking, you book time from a time log. You are not limited to spent the whole time of a single booking, you can divide as you wish. You however aren't able book more time than what was actually logged. The role you have on projects and their settings determine if you are able to edit bookings or are just allowed to create them.

#### Settings

The plugin offers a list of settings at the Redmine roles and permission settings page. Also you can set the size and file for a logo to be displayed at the report in the Redmine plugin settings, enable rounding behaviour and interval as well as snapping percentage. You can also refine this settings per project if you have different accounting rules per project.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/hicknhack-software/redmine_hourglass). Please check the [contribution guide](CONTRIBUTING.md).This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to our [code of conduct](CODE_OF_CONDUCT.md).

## License

The plugin is available released under the terms of [GPL](https://www.gnu.org/licenses/gpl).
