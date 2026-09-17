/// Central application endpoints. Change URLs here when environments change.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://apivatandosh.7z7.uz/api/v1/';
  static const String mediaBaseUrl = 'https://apivatandosh.7z7.uz';
  static const String dummyImageBaseUrl = 'https://picsum.photos/seed';
  static const String yandexMapKitApiKey = String.fromEnvironment(
    'MAPKIT_API_KEY',
    defaultValue: '3f9f0fea-af66-4466-8f71-72db860bf4bd',
  );
}
// flutter run --dart-define=MAPKIT_API_KEY=another_key
