# deezer_app

A simple Flutter music streaming client demo created for an EPITECH project. It provides a basic Deezer-like experience for playing tracks and managing user data.

## Prerequisites

- **Flutter**: 3.10 or higher (stable channel)
- **Dart**: 3.7 or higher

Ensure you have Flutter installed by following the [Flutter installation guide](https://docs.flutter.dev/get-started/install).

## Running the application

### Android
```sh
flutter run
```

### iOS
```sh
flutter run -d ios
```

### Web
```sh
flutter run -d chrome
```

## Configuration

The API base URL is read from an environment file. Create a `.env` file at the project root with the following contents:

```env
BASE_URL=http://your-api-host:8000
```

Update the value to match your development or production environment.

## Contribution

1. Fork this repository and create a new branch for your feature or fix.
2. Run `flutter analyze` and `flutter test` before opening a pull request.
3. Submit the pull request against the `main` branch.

## Testing

Execute the analyzer and test suite with:

```sh
flutter analyze
flutter test
```
