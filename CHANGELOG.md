# Changelog

All notable changes to RegRipper will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.8.1] - 2026-09-22

### Added
- Comprehensive README.md with installation, usage, and architecture documentation
- cpanfile for Perl/CPAN dependency management
- .perlcriticrc for Perl linting configuration
- GitHub Actions CI/CD workflows (ci.yml, perlcritic.yml)
- Test suite structure with sample tests (t/00-load.t, t/rip_pl.t, t/plugins/)
- CONTRIBUTING.md with contribution guidelines
- CHANGELOG.md with version history
- .env.example for configuration template
- Dockerfile for containerized deployment
- LICENSE file with GPL v3.0 header
- .github/dependabot.yml for automated dependency updates
- Input validation and security hardening in rip.pl and rr.pl
- Path traversal protection using File::Spec
- File existence validation before processing
- Secure temporary file handling

### Changed
- Updated rip.pl with enhanced input validation
- Updated rr.pl with enhanced input validation
- Improved error handling and logging
- Modernized Perl version requirement to 5.14+

### Security
- Added path traversal protection
- Added file existence checks
- Removed bareword filehandles
- Added three-argument open() calls
- Added input sanitization for plugin loading
- Added dependency audit in CI pipeline

### Fixed
- Fixed potential command injection vectors
- Fixed path handling for cross-platform compatibility
- Fixed plugin loading to use controlled directory only

## [2.8.0] - 2013-08-01

### Added
- Initial Win8 support to appcompatcache.pl
- Cross-platform support to rip.pl (File::Spec)
- alertMsg() capability to rip.pl, rr.pl, and plugins
- New plugins: srun_tln.pl, urun_tln.pl, cmdproc_tln.pl, cmd_shell_tln.pl, muicache_tln.pl
- alertMsg() functionality to multiple plugins

### Changed
- RegRipper and rip updated to v2.8
- Retired userinit.pl (functionality included in winlogon.pl)
- Retired scanwithav.pl (functionality included in attachmgr.pl)
- Retired taskman.pl (functionality included in winlogon.pl)
- Retired vista_wireless.pl (functionality in networklist.pl)

### Fixed
- Fixed issue with rip.exe syntax info containing 'rr'
- Fixed banner in findexes.pl

## [2.7.0] - 2013-04-11

### Added
- Wow6432Node support to winlogon.pl, winlogon_u.pl
- Wow6432Node support to shellexec.pl, imagefile.pl, installedcomp.pl

### Changed
- Retired specaccts.pl & notify.pl (incorporated into winlogon.pl)
- Retired taskman.pl (merged into winlogon.pl)

## [2.6.0] - 2013-04-05

### Added
- drivers32.pl (C. Harrell)

### Changed
- Updated bho.pl to support Wow6432Node

## [2.5.0] - 2012-05-05

### Added
- Updated to v2.5 release

### Changed
- Consolidated Basic and Advanced versions into single track

## [2.0.0] - 2008-05-12

### Added
- Initial release of consolidated RegRipper

---

## Historical Updates (from updates.txt)

### 2014-11-12
- Created mixer.pl, mixer_tln.pl, audiodev.pl

### 2014-11-11
- Updated usb.pl, usbstor.pl, wpdbusenum.pl

### 2014-11-03
- Updated inprocserver.pl to include detection for PowerLiks

### 2014-10-15
- Updated/modified usb.pl, usbstor.pl, wpdbusenum.pl

### 2014-08-21
- Created at.pl, at_tln.pl

### 2014-08-08
- Updated inprocserver.pl, removed inprocserver_u.pl

### 2014-08-07
- Created del.pl, del_tln.pl

### 2014-07-30
- Updated winzip.pl
- Updated ares.pl (G. Nieves submission)
- Updated lsa_packages.pl & shares.pl (S. Kelm submission)
- Created secrets.pl (based on input from Jamie Levy)

### 2014-07-24
- Updated appcompatcache.pl with 64-bit Win8.1 support (data from Shafik Punja)

### 2014-07-23
- Updated applets.pl
- Updated ie_version.pl

### 2014-07-21
- Update to mountdev2.pl submitted/incorporated

### 2014-05-12
- Updated uninstall.pl, uninstall_tln.pl

### 2014-05-10
- Added profiler.pl

### 2014-05-01
- Added processor_architecture.pl, wevtx.pl (C. Harrell)
- Updated pagefile.pl (C. Harrell)

### 2014-04-16
- Updated usbdevices.pl (updates by J. Chau)

### 2014-04-15
- Added winevt.pl (C. Harrell)
- Removed winlivemail.pl, winlivemsn.pl (errors)
- Removed streammru.pl, streams.pl

### 2014-04-14
- Added knowndev.pl, ddo.pl (J. Chau)
- RELEASED

### 2014-04-08
- Updated lsasecrets.pl (improved error message)

### 2014-03-26
- Created susclient.pl

### 2014-02-20
- Updated recentdocs_tln.pl

### 2014-02-03
- Added winscp.pl

### 2014-01-31
- Added reading_locations.pl (from Jason Hale)

### 2014-01-15
- Updated user_run.pl to look for odd char in paths

### 2013-12-10
- Updated crashcontrol.pl
- Updated amcache.pl

### 2013-11-18
- Created cdstaginginfo.pl

### 2013-11-08
- Updated svc.pl to look for WOW64 value in service keys

### 2013-10-25
- Created startup.pl

### 2013-10-11
- Created kankan.pl plugin

### 2013-10-10
- Created vawtrak.pl
- Updated svcll.pl with Derbusi detection
- Updated svc.pl (Backdoor.Kopdel checks)

### 2013-10-09
- Created ahaha.pl

### 2013-10-08
- Created opencandy.pl plugin

### 2013-10-07
- Created lazyshell.pl, comfoo.pl
- Updated imagefile.pl with carnal0wnage link to sticky keys info

### 2013-09-30
- Updated appcompatflags.pl to support Win8 Store key

### 2013-09-25
- Retired compatassist.pl; functionality rolled into appcompatflags.pl

### 2013-09-11
- Updated svc.pl/svc_tln.pl to alert on FailureAction value
- Updated installedcomp.pl to look for StubPath values pointing to rundll32 but not .dll

### 2013-09-10
- Updated winlogon.pl/winlogon_tln.pl to check for GinaDLL value

### 2013-09-05
- Removed winlivemsn.pl from ntuser profile (module dependencies cause errors)
- Updated installedcomp.pl for more searchable output
- Created netsvcs.pl plugin

### 2013-09-04
- Created rlo.plugin (all hives)
- Updated backuprestore.pl (cleaned up code)

### 2013-08-30
- Updated timezone.pl (findings from Mike W.)

### 2013-08-01
- Added initial Win8 support to appcompatcache.pl
- Added cross-platform support to rip.pl (File::Spec)

### 2013-07-31
- Updated ie_settings.pl

### 2013-07-11
- Created pending.pl

### 2013-07-06
- Updated appcompatflags.pl to retrieve values from Persisted key

### 2013-06-30
- Updated usbstor.pl - added parsing of Properties values (Win7)
- Updated devclass.pl - added additional device class check

### 2013-06-03
- Updated alert code (new alert function & check for ADSs)
- Affected: appcompatcache.pl, inprocserver.pl, clsid.pl, appcompatcache_tln.pl, soft_run.pl, user_run.pl, srun_tln.pl, urun_tln.pl, svc.pl, svcdll.pl, svc_tln.pl

### 2013-05-30
- Updated mountdev.pl to address endian issues in display of disk signatures

### 2013-05-22
- Minor changes to attachmgr.pl, attachmgr_tln.pl

### 2013-05-14
- Updated itempos.pl to parse ItemPos* value data beneath ShellNoRoam\Bags subkeys

### 2013-05-13
- Updated userinfo.pl to include UserName value beneath "Common" subkey

### 2013-05-09
- Added alert and warnings to appcompatcache.pl, appcompatcache_tln.pl
- Updated svc.pl, retired svc2.pl
- Created svc_tln.pl based on svc.pl

### 2013-05-04
- Added alert to Run key plugins to check for %AppData% paths (malware)

### 2013-04-29
- Created winlogon_tln.pl, applets_tln.pl
- Added alertMsg() func. to: brisv.pl, inprocserver.pl, inprocserver_u.pl, iejava.pl, spp_clients.pl
- Retired scanwithav.pl (func. included in attachmgr.pl)
- Retired taskman.pl (func. included in winlogon.pl)
- Retired vista_wireless.pl (func. in networklist.pl)

### 2013-04-25
- RegRipper and rip updated to v2.8; added alertMsg() capability
- Retired userinit.pl (functionality included in winlogon.pl)
- Created new plugins: srun_tln.pl, urun_tln.pl, cmdproc_tln.pl, cmd_shell_tln.pl, muicache_tln.pl
- Added alertMsg() functionality to rip.pl, rr.pl, and plugins

---

## Legend

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes