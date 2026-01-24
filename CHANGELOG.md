# Changelog

All notable changes to Posturr will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-24

### Added
- Initial release of Posturr
- Real-time posture monitoring using macOS Vision framework
- Screen blur effect that activates when poor posture is detected
- Body pose detection with shoulder and head position tracking
- Face detection fallback when full body pose unavailable
- Command interface for external control (capture, blur, quit)
- Status indicator showing current app state
- Multi-display support for blur overlay
- Camera permission handling with user-friendly prompt

### Technical Details
- Uses private CoreGraphics API for efficient window blur
- Runs as a background app (no dock icon)
- Supports macOS 13.0 and later
