# Currency Converter App

A modern, animated currency converter mobile app built with Flutter using BLoC architecture and Firebase authentication.

## Features

### 🔐 Authentication
- Firebase-based email/password authentication
- Secure login with validation
- Password reset functionality
- Automatic session management

### 💱 Currency Conversion
- Real-time currency conversion using CurrencyLayer API
- Support for 4 major currencies (USD, INR, EUR, AED)
- Interactive currency selection with animated dropdowns
- Quick amount selection buttons
- Amount validation (positive values, max $100,000)

### 🚀 Smart Caching System
- **Fresh Cache**: Rates cached for 5 minutes (green indicator)
- **Stale Cache**: Rates usable for up to 30 minutes (orange/red indicator)
- **Offline Support**: App works with cached data when offline
- **API Fallback**: Graceful degradation when API is unavailable

### 🎨 Smooth Animations & UI/UX
- Fluid screen transitions with slide animations
- Fade-in animations for content
- Interactive button animations
- Modern Material Design 3 UI
- Responsive layout for all screen sizes

### 📊 Real-time Information
- Cache status indicators
- Error handling with user-friendly messages
- Loading states with progress indicators

## Architecture

The app follows BLoC pattern with clean separation of concerns:

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── app.dart                           # Main app widget with BLoC providers
├── firebase_options.dart              # Firebase configuration
├── config/
│   ├── contants.dart                  # Currency symbols and names
│   └── env.dart                       # Environment configuration
├── data/
│   ├── models/
│   │   ├── currency_model.dart        # Currency data model
│   │   └── rate_cache.dart            # Cache model for exchange rates
│   └── services/
│       ├── api_service.dart           # Currency API service
│       └── auth_service.dart          # Firebase authentication service
├── features/
│   ├── authentication/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart         # Authentication BLoC
│   │   │   ├── auth_event.dart        # Authentication events
│   │   │   └── auth_state.dart        # Authentication states
│   │   └── views/
│   │       └── login_screen.dart      # Login UI
│   └── currency_converter/
│       ├── bloc/
│       │   ├── converter_bloc.dart    # Currency conversion BLoC
│       │   ├── converter_event.dart   # Conversion events
│       │   └── converter_state.dart   # Conversion states
│       └── views/
│           ├── amount_input.dart      # Amount input screen
│           ├── currency_selector.dart # Currency selection screen
│           ├── error_screen.dart      # Error handling screen
│           ├── result_screen.dart     # Conversion result screen
│           └── widget/
│               ├── currency_chip_widget.dart  # Currency selection chips
│               ├── info_tile_widget.dart      # Information display tiles
│               └── result_body_widget.dart    # Result display widget
└── routes/
    ├── app_router.dart                # GoRouter configuration
    └── route_paths.dart               # Route path definitions
```

## Caching Strategy

The app implements a sophisticated multi-layered caching system to ensure optimal performance and offline functionality.

### Cache Implementation Details
- **Storage**: Uses `SharedPreferences` for persistent local storage
- **Cache Key**: Combination of currency pairs (e.g., "USD_EUR")
- **Data Structure**: `RateCacheEntry` model with rate, timestamp, and currency pair
- **Cache File**: Stored as JSON in device preferences with key `rate_cache_v1`

### Cache Duration & Logic
- **Fresh Cache**: 5 minutes (defined in `Env.freshDuration`)
- **Fallback Cache**: 30 minutes (defined in `Env.fallbackDuration`)

### Smart Cache Behavior
The `getBestRate()` function implements intelligent cache logic:

1. **Check Fresh Cache First**: If cached data exists and is under 5 minutes old, return immediately
2. **Try API Call**: Attempt to fetch fresh rate from CurrencyLayer API
3. **Update Cache**: Save successful API response to cache with timestamp
4. **Fallback on API Failure**: If API fails, check if cached data exists under 30 minutes old
5. **Error Handling**: Throw exception only if no usable cache data available




### Cache Indicators & User Experience
- 🟢 **Fresh**: Rate is less than 5 minutes old (optimal experience)
- 🟠 **Cached**: Rate is between 5-30 minutes old (acceptable for offline use)
- 🔴 **Stale Cache**: Rate is older than 5 minutes (shown when API fails)

### Cache Benefits
- **Offline Functionality**: App works completely offline with cached rates
- **Reduced API Calls**: Minimizes unnecessary API requests and costs
- **Faster Response**: Instant results for recently cached rates
- **Battery Efficiency**: Less network usage improves battery life

## API Integration

### CurrencyLayer API
- **Endpoint**: `http://api.currencylayer.com/convert`
- **Access Key**: Included in the app
- **Rate Limits**: Free tier with reasonable limits
- **Response Format**: JSON with success/error handling

### Example API Call
```bash
curl --location --request GET 'http://api.currencylayer.com/convert?access_key=YOUR_KEY&from=USD&to=EUR&amount=25&format=1'
```

### API Response
```json
{
    "success": true,
    "query": {
        "from": "USD",
        "to": "EUR",
        "amount": 25
    },
    "info": {
        "timestamp": 1754673966,
        "quote": 0.85746
    },
    "result": 21.4365
}
```

## Business Logic Functions

### getBestRate(from, to)
This function implements the bonus business logic requirement:

```dart
Future<Map<String, dynamic>?> getBestRate({
  required String fromCurrency,
  required String toCurrency,
}) async
```

**Behavior:**
1. **Tries API first**: Attempts to fetch fresh rate
2. **Falls back to cache**: Uses cached data if under 30 minutes old
3. **Returns null**: If no rate is available
4. **Works offline**: Uses cached data when network is unavailable

**Return Format:**
```dart
{
  'rate': 1.2345,
  'timestamp': DateTime.now(),
  'isCached': true,
  'isStale': false,
}
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project



### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  http: ^1.1.0
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.0
  connectivity_plus: ^5.0.2
  go_router: ^14.2.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Usage Flow

1. **Login**: Enter email and password to authenticate
2. **Select Currencies**: Choose source and target currencies with animated dropdowns
3. **Enter Amount**: Input amount with validation and quick selection buttons
4. **View Results**: See conversion with rate information and cache status
5. **Continue**: Convert another amount or start new conversion

## API Failure Handling

The app implements robust error handling and recovery mechanisms to ensure a smooth user experience even when the API is unavailable.

