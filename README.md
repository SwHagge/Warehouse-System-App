# Warehouse-System-App

Responsive Flutter-Oberfläche für die Verwaltung eines Lagersystems auf Basis der PartDB-REST-API.

## Aktueller Stand

Die erste Oberfläche enthält eine Bestandsübersicht mit Suche, Niedrigbestand-Filter sowie lokaler Artikelerfassung. Die angezeigten Einträge sind Beispieldaten und werden noch nicht mit PartDB synchronisiert.

## Voraussetzungen

- Flutter SDK mit Dart 3.3 oder neuer
- Für Android: Android SDK
- Für Windows: Visual Studio mit der Workload „Desktop development with C++“
- Für Linux: CMake, Ninja und die üblichen GTK-Entwicklungsbibliotheken
- Für macOS: Xcode

## Plattformen einrichten

Im Projektordner ausführen:

```powershell
flutter create --project-name warehouse_system_app --platforms=windows,linux,macos,android .
flutter pub get
```

Die nativen Runner können nur auf den jeweils unterstützten Host-Systemen gebaut werden. Android kann zusätzlich auf Windows, Linux oder macOS gebaut werden; iOS benötigt macOS und Xcode.

## Starten

```powershell
flutter run -d windows
flutter run -d linux
flutter run -d macos
flutter run -d android
```

Vorhandene Geräte und Ziele lassen sich mit `flutter devices` anzeigen.

## Nächster Integrationsschritt

Vor der PartDB-Anbindung müssen REST-Basis-URL, Authentifizierung und die gewünschten Lager-Workflows festgelegt werden. Zugangsdaten sollten nicht fest in der App gespeichert werden.
