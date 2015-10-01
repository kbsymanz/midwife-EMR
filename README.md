# Midwife EMR

Midwife-EMR (Midwife Electronic Medical Record) is custom patient management
software for a large charity maternity clinic in the Philippines serving a low
income community. This software is specifically designed for one particular
clinic, though anyone can use parts or all of it freely as you see fit. See
LICENSE.md for details.

Phase one of the application had a focus upon upon prenatal care. It was
installed in February 2015 and is currently being used on a daily basis in the
central facility. Design and development for phase two, which includes
post-prenatal care (labor, delivery, and postpartum), is ongoing at the
current time.

## Features at a glance

- New patient setup
   - Any number of patients allowed.
- Prenatal history
- Prenatal questionnaire
- Prenatal examinations
   - Lab results
   - Vaccinations
   - Prenatal measurements/notes
   - Referrals
   - Medicines administered
   - Health Teachings
   - Progress notes
- Patient Search
   - exact and wildcard
   - search by priority number (scanning the priority badge/tag)
   - search by scheduled appointment day
   - search by date of birth
   - search by Phil Health ID or DOH ID
- Reports
   - To date these are reports required by the local government
      - Tetanus Reports 1 through 5
      - Iron Given Reports 1 through 5
      - Deworming Report
      - DOH Master list
      - Phil Health Daily Report
      - Inactives Report
      - Summary Report - everything about one patient in one report.
   - Reports produce PDFs for storage, printing, etc.
   - Report input includes to and from dates, type of report, etc.
- Priority number scheduling
   - Barcode generation system to allow scanning priority badges/tags for
    faster and efficient patient processing
      - Generator script creates PDF of barcodes
      - Barcodes can then be permanently attached to priority badges/tags that the patients
      use when they arrive. This is done once to setup the priority
      badges/tags.
      - The queuing system uses priority badges/tags and scanners can be used to
      quickly access the patient's records as they proceed through the exam
      processes.
- User management (staff, etc.)
   - Roles
      - Supervisor
      - Attending
      - Clerk
      - Guard
      - Administrator
   - Permissions and ACL based upon roles
   - Any number of users/staff allowed.
- Web browser and mobile browser compatible
- Full logging of all changes to the database
   - All historical changes reviewable by supervisor role.
      - Allows supervisor to traverse forward and backword "through time"
        viewing the screens as they appeared across all pages of the application,
        or review only changes that occurred on a specific page.
      - Shows who made what changes at what time.
      - Is completely read-only, reviewing historical changes does not change
        data.
      - Fast - uses SPA technology so that reviewing changes are quick and
        simple.
- HTTPS (HTTP redirects to HTTPS)
   - Allows HTTP only if configured as such, though not recommended.
- Tests (152 to date)
- MIT license

## Some Additional Documentation

See the [wiki for more detailed user and system documentation](../../wiki).

## The Setting

The clinic for which the application is designed and is being used performs
over 20,000 prenatal exams and delivers approximately 1600 babies each year.
In the Philippines, this type of maternity clinic is called a lay-in maternity
clinic. Our hope is that Midwife-EMR might be of use to many other lay-in
maternity clinics not only in the Philippines but elsewhere where
high-quality, free or low-cost, maternal services can be offered to those most
in need.

![ODroid XU3-Lite](docs/images/IMG_2568_cropped_rounded_830x542.JPG)

Due to the relatively frequent power outages at the current location of the clinic,
Midwife-EMR is currently running on an [ODroid
XU3-Lite](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G141351880955)
single board computer. This allows the wireless router and the server running
the Midwife-EMR application to stay operational for 5+ hours during a power
outage while running on a 600 watt UPS. The application itself is accessed
using tablets (mostly Nexus 7 right now), some smartphones, and laptops. It is
normal for 12 or so users to be using the application, which is itself running on
the ODroid XU3-Lite, at any one time without any issues or any hint of
performance degradation.

A few facts about the specific XU3-Lite setup that we are using.

- 64 GB eMMC card
- 64 GB class 10 SD card
- Built in ethernet port, not using a WiFi module.

The SD card is solely used for automated backups. Additionally, encrypted
backups are automatically stored on a remote VPS.

**Note that as of this time (September 2015) the ODroid XU3-Lite is being
retired by Hardkernel in favor of the XU4. We have not begun testing
Midwife-EMR on the XU4 yet, though we do not foresee any issues with doing
so.**

## Status

Beta - initial pilot for prenatal exams was hugely successful. Midwife-EMR
continues to be used on a daily basis since the pilot.

Phase two which includes labor, delivery and postpartum is currently being
designed and developed.

## Technology Used

- Nodejs - version v0.10.40 (upgrade to Node 4.x is in pending dependencies).
- MySQL
- Nginx - reverse proxy for the application (optional)

Web based and compatible with tablet browsers.

## Future Plans

These are the ongoing, high-level plans for the project.

- Upgrade/migrate most/all third-party node modules to current.
- Refactor the database design.
- Implement labor, delivery, and postpartum.
- Refactor the application for SPA clients.

## Contributions

Contributions, comments, suggestions, issues and pull requests are welcome.

## License

The MIT License (MIT)

Copyright (c) 2014 Kurt Symanzik <kurt.symanzik@lightsys.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

