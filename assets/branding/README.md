# Branding assets (add these files, then run the icon generator)

| File | Size | Used for |
|---|---|---|
| `icon.png` | 1024×1024 PNG, no transparency | Launcher icon (legacy + iOS) and Play Store icon (export a 512×512 copy for Play) |
| `icon_foreground.png` | 1024×1024 PNG, transparent background, logo inside the centre ~66% | Android adaptive icon foreground (background colour is #0D3B66) |
| `feature_graphic.png` | 1024×500 PNG/JPG | Play Store feature graphic (upload in Play Console, not used in the app) |

Generate the launcher icons:

```sh
dart run flutter_launcher_icons
```

Config lives in `pubspec.yaml` → `flutter_launcher_icons`.
