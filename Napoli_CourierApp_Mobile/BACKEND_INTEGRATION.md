# Backend Integration Guide

The Napoli Drivers App is architected using **Clean Architecture** patterns, which makes swapping the current "mock" data for a real backend API seamless. The application is **already prepared** for this transition.

## 🏗️ Architecture Readiness

The app currently uses a 3-layer structure that facilitates this change:

1.  **Domain Layer (Ready)**: Contains business entities (`Driver`, `Order`) and Repository Interfaces. This layer **does not change** when you add a backend.
2.  **Presentation Layer (Ready)**: Contains UI and Logic (`Cubits`). This layer interacts *only* with the Domain layer, so it doesn't care if data comes from memory or an API.
3.  **Data Layer (To Be Updated)**: Currently contains `MockDataSource` and `RepositoryImpl`. This is where the integration happens.

## 🚀 Steps to Integrate API

### 1. Create API Service
First, standardizing HTTP requests is crucial. Typically, we use `dio` for this.

**Create**: `lib/core/api/api_client.dart`
```dart
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: 'https://api.napoli.com/v1'));

  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, dynamic data) => _dio.post(path, data: data);
  // ... put, delete
}
```

### 2. Create Remote Data Sources
Replace logic in `MockDataSource` with actual API calls.

**Example**: `lib/features/auth/data/datasources/remote_auth_datasource.dart`
```dart
class RemoteAuthDataSource {
  final ApiClient _api;

  RemoteAuthDataSource(this._api);

  Future<DriverModel> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    // DriverModel alread has fromJson! ✅
    return DriverModel.fromJson(response.data);
  }
}
```

### 3. Update Repositories
Update implementation to use the new `RemoteDataSource` instead of the Mock one.

**File**: `lib/features/auth/data/repositories/auth_repository_impl.dart`
```dart
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource remoteDataSource; // Changed from MockAuthDataSource
  // ...
}
```

### 4. Update Dependency Injection
Finally, tell the app to use the real implementation.

**File**: `lib/core/di/injection.dart`
```dart
// Remove this
// getIt.registerLazySingleton(() => MockAuthDataSource());

// Add this
getIt.registerLazySingleton(() => ApiClient());
getIt.registerLazySingleton(() => RemoteAuthDataSource(getIt()));
```

## ✅ What is Already Done?

Your codebase already includes the hardest parts of preparation:

1.  **JSON Serialization**: Files like `driver_model.dart` already have `fromJson` and `toJson` methods ready to parse API responses.
2.  **Entity Mapping**: Methods like `toEntity()` are already implemented to convert API data to Domain objects.
3.  **Strict Separation**: The UI code never calls data sources directly; it always goes through the abstract Repository, meaning **you won't have to touch a single line of UI code** to connect the API.

## 📋 Checklist for Backend Team

When the backend developer (or you) starts this phase, simply:

- [ ] Set up `Dio` or `http` package.
- [ ] Create `RemoteDataSource` files for each feature (Auth, Dashboard, Orders, History).
- [ ] Update `injection.dart` to point to the new sources.
- [ ] Ensure backend JSON response format matches `fromJson` expectations in models.
