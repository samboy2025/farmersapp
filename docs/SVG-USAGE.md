# SVG Assets Usage

These SVG logos and icons are vector-based and scale crisply across densities.

## Files
- Logos: `assets/images/logo_primary.svg`, `assets/images/logo_monochrome.svg`, `assets/images/logo_appicon.svg`
- Icons: `assets/images/icons/*.svg`

## Setup
1. Ensure the assets folder is declared in `pubspec.yaml` under `flutter/assets` (already present):
   - `assets/images/`
2. Add `flutter_svg` to dependencies if not already added:

```yaml
dependencies:
  flutter_svg: ^2.0.9
```

Run:
```bash
flutter pub add flutter_svg
```

## Usage (Flutter)
```dart
import 'package:flutter_svg/flutter_svg.dart';

// Logo (full color)
SvgPicture.asset('assets/images/logo_primary.svg', width: 120);

// Monochrome logo inherits color
ColorFiltered(
  colorFilter: const ColorFilter.mode(Color(0xFF128C7E), BlendMode.srcIn),
  child: SvgPicture.asset('assets/images/logo_monochrome.svg', width: 120),
);

// Icons (use currentColor by wrapping in IconTheme or DefaultTextStyle)
IconTheme(
  data: const IconThemeData(color: Color(0xFF128C7E), size: 24),
  child: SvgPicture.asset('assets/images/icons/chat.svg'),
);
```

## Tips
- Use `currentColor` aware icons to theme via `IconTheme`.
- Prefer `logo_appicon.svg` for store assets/generators; use provided PNGs for platforms if needed.
- Keep stroke width at 2 for visual consistency.
- For dark mode, prefer `logo_monochrome.svg` with a light color.
