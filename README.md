# hesabu_app

A new Flutter project.

## API configuration

The API currently defaults to the staging endpoint. Override it at build time
when required:

```sh
flutter run --dart-define=API_BASE_URL=https://app.hesabuonline.com
```

For temporary native-device testing against a host with an invalid certificate:

```sh
flutter run --dart-define=ALLOW_INSECURE_TLS=true
```

The TLS bypass is disabled by default, restricted to the configured API host
and port, and unsupported on web. Never publish a production build with it
enabled; replace the server certificate instead.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
