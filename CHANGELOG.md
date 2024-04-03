# ChatCleaner Change Log
All notable changes to this project will be documented in this file. Be aware that the [Unreleased] features are not yet available in the official tagged builds.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] 2024-04-03
### Changed
- Messages containing links from Questie are now parsed. Will monitor the situation.

### Fixed
- Fixed some false positives on quest completion leading to weirdly formated messages.

## [2.0.56-Release] 2024-04-03
- Updated for WoW Client Patch 1.15.2.

## [2.0.55-Release] 2024-03-22
- Updated for WoW Client Patch 10.2.6.
- Updated for WoW Client Patch 4.4.0.

### Fixed
- Zone changes for general public channels are now correctly abbreviated.

## [2.0.54-Release] 2024-03-11
### Added
- Messages about not being in a raid group while in a battleground should now be suppressed.

## [2.0.53-Release] 2024-02-07
- Updated for WoW Client Patch 1.15.1.

## [2.0.52-Release] 2024-01-17
- Updated for WoW Client Patch 10.2.5.

## [2.0.51-Release] 2023-11-19
### Fixed
- The loot filter should hide the game's own honor messages better than before now.

## [2.0.50-Release] 2023-11-17
- Updated for WoW Client Patch 1.15.0.

### Changed
- Re-enabled various development filters in the development version. Does not affect general users downloading the addon through its supported addon websites and download clients.

## [2.0.49-Release] 2023-11-14
### Fixed
- Fixed an issue that caused money parsing to sometimes bug out in esES, frFR and ruRU clients.

## [2.0.48-Release] 2023-11-07
- Updated for WoW Client Patch 10.2.0.

## [2.0.47-Release] 2023-10-23
### Fixed
- Removed a double embed of AceConfig. This update has no effect on the end user, but still needed to be fixed.

## [2.0.46-Release] 2023-10-21
### Changed
- The system messages notifying you of honor- and arenapoints gained is now completely filtered out, as this also is represented as loot gained and would be a duplicate message.

## [2.0.45-Release] 2023-10-19
### Changed
- We're now also parsing for Guild Achievements, as well as filtering out duplicate entries that for some reason are posted both in the regular achievement channel and the guild achievement channel.

## [2.0.44-Release] 2023-10-13
### Fixed
- Fixed an issue that caused many chat replacements like the removal of brackets around player names to not be registered and processed.

## [2.0.43-Release] 2023-10-11
### Fixed
- Fixed the issue where the addon sometimes would attempt to hook into the hiding of the `ClassTrainerFrame` before it had been loaded.

## [2.0.42-Release] 2023-10-11
- Updated for WoW Client Patch 3.4.3.

## [2.0.41-Release] 2023-10-08
### Fixed
- Fixed a bug that would mock up all the output.

## [2.0.40-Release] 2023-09-28
- Rewrote the addon, see git for details.

## [1.0.39-Release] 2023-09-06
- Updated for Retail client patch 10.1.7.

## [1.0.38-Release] 2023-09-04
### Fixed
- Questie links should no longer be parsed or modified.

## [1.0.37-Release] 2023-08-24
- Updated for Classic client patch 1.14.4.

## [1.0.36-Release] 2023-07-27
### Fixed
- Fixed the bug introduced in the previous update today.

## [1.0.35-Release] 2023-07-27
### Fixed
- Fixed some issue with search patterns in some non-English game clients.

## [1.0.34-Release] 2023-07-12
- Bumped to Retail Client Patch 10.1.5.

## [1.0.33-Release] 2023-06-21
### Fixed
- Channel- and player names should be properly cleaned up now.

## [1.0.32-Release] 2023-06-21
- Bumped to Wrath Classic Client Patch 3.4.2.

## [1.0.31-Release] 2023-05-31
### Added
- Added an options menu with filter selection, available by typing `/chatcleaner`or `/cc`.

## [1.0.30-Release] 2023-05-31
- Updated addon listing icon textures for Retail.

## [1.0.29-Release] 2023-05-03
- Updated for WoW 10.1.0.

## [1.0.28-Release] 2023-03-25
- Updated for WoW 10.0.7.

### Fixed
- Fixed a bug that would sometimes show the wrong person getting loot or currency in Wrath.

## [1.0.27-Release] 2023-01-26
- Updated for WoW 10.0.5.

## [1.0.26-Release] 2023-01-18
- Updated for WoW 3.4.1.

## [1.0.25-Release] 2023-01-09
### Fixed
- Fixed a bug.

## [1.0.24-Release] 2022-12-08
### Fixed
- Quests you have completed and thus fail to pickup from NPCs or friends who share them should no longer wrongly be filtered as a completed quest. The error message will remain unchanged.

## [1.0.23-Release] 2022-11-19
### Changed
- Slightly changed how the size of money icons are calculated. Might need further adjustments.
- The NPC chat removal module is now disabled by default unless you download the addon directly from GitHub. This module doesn't follow the filtering scheme of the rest of the addon, and was never really meant to be public anyway.

## [1.0.22-Release] 2022-11-16
- Bump to retail client patch 10.0.2.

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
