# ChatCleaner Change Log
All notable changes to this project will be documented in this file. Be aware that the [Unreleased] features are not yet available in the official tagged builds.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.21-Release] 2022-10-25
- Bumped retail version to the 10.0.0 patch.

## [1.0.20-Release] 2022-10-08
### Changed
- Money messages should now appear only in windows you have enabled money display for, instead of always being forced into the primary chat window as before.

### Fixed
- Added a blacklist for general non-event filters, to avoid normal chat messages in guild- or party chat or similar being interpreted as loot or currency messages and filtered.

## [1.0.19-Release] 2022-09-24
### Fixed
- Added the missing Evoker color entry to make this work for Dragonflight.

## [1.0.18-Release] 2022-09-07
- Switching to single addon multiple toc-file format.

## [1.0.17-Release] 2022-09-03
### Removed
- Removing TaintLess.xml as its about to be deprecated.

## [1.0.16-Release] 2022-08-17
- Bump to client patch 9.2.7.

## [1.0.15-Release] 2022-08-04
### Added
- Added rules to format completed appearance sets, and prevent them from firing as completed quests.

### Changed
- Prettied up some of the code. It's more happy now.
- Removed a boat load of trailing whitespace.

## [1.0.14-Release] 2022-07-21
- Add support for WotLK beta.
- Bump toc to WoW Classic Era patch 1.14.3.

## [1.0.13-Release] 2022-05-31
- Bump toc to WoW client patch 9.2.5.

## [1.0.12-Release] 2022-04-07
- Bump for BCC client patch 2.5.4.

## [1.0.11-Release] 2022-02-28
### Changed
- Now parsing AddMessage for auction created and removed, as this appears to have been moved from system messages to direct output in WoW client patch 9.2.0.

## [1.0.10-Release] 2022-02-23
- ToC bumps and license update.

## [1.0.9-Release] 2022-02-16
- ToC bumps and license update.

## [1.0.8-Release] 2022-02-06
### Fixed
- Chat messages from creating multiple items at once, like when conjuring food or water, should be properly displayed.

## [1.0.7-Release] 2021-12-15
### Fixed
- Group member loot should no longer be displayed as your loot.

## [1.0.5-Release] 2021-12-15
### Added
- Added filters for group member looting. Needs testing.

## [1.0.4-Release] 2021-11-17
- Bump Classic Era toc to client patch 1.14.1.

## [1.0.3-Release] 2021-11-03
- Bump Retail toc to client patch 9.1.5.

## [1.0.2-Release] 2021-10-18
- Bump Classic Era toc to client patch 1.14.

## [1.0.1-Release] 2021-09-26
### Changed
- Keep unfinished hidden features to the development versions only.

## [1.0.0-Release] 2021-09-25
- First commit.
