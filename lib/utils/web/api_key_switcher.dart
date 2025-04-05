import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeySwitcher {
  static const String _userApiKeyPref = 'user_omdb_api_key';

  final List<String> _keys;
  int _currentIndex = 0;
  String? _userApiKey;

  final Set<String> _invalidKeys = {};

  ApiKeySwitcher(this._keys);

  /// Initializes the ApiKeySwitcher by loading the user's API key from SharedPreferences
  static Future<ApiKeySwitcher> initialize(List<String> keys) async {
    final instance = ApiKeySwitcher(keys);
    await instance._loadUserApiKey();
    return instance;
  }

  Future<void> _loadUserApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userApiKey = prefs.getString(_userApiKeyPref);
    } catch (e) {
      debugPrint('OMDB > Error loading user API key: $e');
    }
  }

  Future<bool> saveUserApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userApiKey = apiKey;
      _invalidKeys.clear();
      return await prefs.setString(_userApiKeyPref, apiKey);
    } catch (e) {
      debugPrint('OMDB > Error saving user API key: $e');
      return false;
    }
  }

  Future<bool> clearUserApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userApiKey = null;
      _invalidKeys.clear();
      return await prefs.remove(_userApiKeyPref);
    } catch (e) {
      debugPrint('OMDB > Error clearing user API key: $e');
      return false;
    }
  }

  /// Gets the user key if available, otherwise first available key
  String getCurrentKey() {
    if (_userApiKey != null && _userApiKey!.isNotEmpty) {
      return _userApiKey!;
    }

    if (_keys.isEmpty) {
      throw Exception('OMDB > No API keys available');
    }

    // Find the next non-invalid key
    String key = _keys[_currentIndex];
    debugPrint('OMDB > Using key: $key');
    return key;
  }

  bool switchToNextKey() {
    if (_userApiKey != null && _userApiKey!.isNotEmpty) {
      debugPrint('OMDB > User API key is being used, not switching keys');
      return false;
    }

    if (_keys.isEmpty) {
      throw Exception('OMDB > No API keys available to switch to');
    }

    // Mark current key as invalid
    final currentKey = _keys[_currentIndex];
    _invalidKeys.add(currentKey);

    // Find next valid key
    int originalIndex = _currentIndex;
    int validKeysChecked = 0;
    int availableKeys = _keys.length - _invalidKeys.length;

    // If all keys are invalid, reset and try again
    if (availableKeys <= 0) {
      debugPrint('OMDB > All keys are marked invalid, resetting invalid keys cache');
      _invalidKeys.clear();
      availableKeys = _keys.length;
    }

    // Find the next non-invalid key
    while (validKeysChecked < availableKeys) {
      _currentIndex = (_currentIndex + 1) % _keys.length;
      if (!_invalidKeys.contains(_keys[_currentIndex])) {
        debugPrint('OMDB > Switched to next API key: ${_keys[_currentIndex]}');
        return true;
      }
      validKeysChecked++;
    }

    // If we get here, all keys are invalid but we cleared the cache
    _currentIndex = (_currentIndex + 1) % _keys.length;
    debugPrint('OMDB > Switched to next API key: ${_keys[_currentIndex]}');
    return originalIndex != _currentIndex;
  }

  /// Executes a request with the current API key, switching to the next key if necessary
  Future<Response<T>> fetchWithKeySwitch<T>({
    required Dio dio,
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    int maxRetries = 3,
  }) async {
    // For non-auth errors (not 401), track per-key retry attempts
    final Map<String, int> keyRetryAttempts = {};

    // Track total attempts across all keys for logging
    int totalAttempts = 0;

    // Calculate max attempts
    // For auth failures we try each key once
    // For other errors, we retry each key up to maxRetries times
    final maxAttempts = _userApiKey != null ? maxRetries : _keys.length * maxRetries;

    debugPrint('OMDB > Maximum attempts allowed: $maxAttempts');

    while (totalAttempts < maxAttempts) {
      final currentKey = getCurrentKey();

      // Skip keys we already know are invalid
      if (_invalidKeys.contains(currentKey)) {
        if (_userApiKey != null) {
          // If using user key that's already known to be invalid, fail fast
          throw Exception('OMDB > Invalid API key. Please check your OMDB API key.');
        } else {
          switchToNextKey();
          continue; // Try next key without incrementing attempts
        }
      }

      // Check if we've exceeded retries for this specific key (for non-auth errors)
      final currentKeyAttempts = keyRetryAttempts[currentKey] ?? 0;
      if (currentKeyAttempts >= maxRetries) {
        debugPrint(
            'OMDB > Key $currentKey has been tried $maxRetries times, switching to next key');
        switchToNextKey();
        continue;
      }

      try {
        final Map<String, dynamic> params = {
          ...(queryParameters ?? {}),
          'apikey': currentKey,
        };

        debugPrint(
            'OMDB > Attempting request with key: $currentKey (retry ${currentKeyAttempts + 1}/$maxRetries)');
        final response = await dio.request<T>(
          path,
          queryParameters: params,
          data: data,
          options: options,
        );

        // Request succeeded, clear this key from invalid keys if it was there
        _invalidKeys.remove(currentKey);

        return response;
      } on DioException catch (e) {
        totalAttempts++;

        // For non-auth errors, track per-key attempts
        if (e.response?.statusCode != 401) {
          keyRetryAttempts[currentKey] = (keyRetryAttempts[currentKey] ?? 0) + 1;
        }

        debugPrint('OMDB > Error in request with API key $currentKey');
        debugPrint('OMDB > Total attempts: $totalAttempts of $maxAttempts');

        // Specifically handle authentication errors (401) as a key issue
        if (e.response?.statusCode == 401) {
          debugPrint('OMDB > API key authentication failed (401). Key is invalid.');
          _invalidKeys.add(currentKey);

          if (_userApiKey != null) {
            // For user key, just fail with a helpful message
            throw Exception(
                'OMDB > Your OMDB API key appears to be invalid. Please check the key in settings.');
          } else {
            // For app keys, switch to next key immediately without counting against maxRetries
            // because auth failures mean the key is definitely invalid
            switchToNextKey();
            totalAttempts--; // Don't count auth failures toward total attempts
          }
        }
        // Handle rate limiting (status code 429) or other API-specific errors
        else if (e.response?.statusCode == 429 ||
            (e.response?.data is Map && (e.response?.data as Map).containsKey('Error'))) {
          // If we've exceeded retries for this key, switch to next
          if (keyRetryAttempts[currentKey]! >= maxRetries) {
            if (_userApiKey == null) {
              switchToNextKey();
            }
          }

          // Add a delay before retrying
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          // For other errors, we'll retry up to maxRetries times per key
          if (keyRetryAttempts[currentKey]! >= maxRetries && _userApiKey == null) {
            switchToNextKey();
          }

          // If user key and exceeded retries, or other critical error, just rethrow
          if ((_userApiKey != null && keyRetryAttempts[currentKey]! >= maxRetries) ||
              e.response?.statusCode == 403 ||
              e.response?.statusCode == 404) {
            rethrow;
          }
        }
      } catch (e) {
        totalAttempts++;
        // Track this error against the current key
        keyRetryAttempts[currentKey] = (keyRetryAttempts[currentKey] ?? 0) + 1;

        debugPrint('OMDB > Unexpected error on attempt $totalAttempts: $e');

        // If exceeded retries for this key, switch to next
        if (_userApiKey == null && keyRetryAttempts[currentKey]! >= maxRetries) {
          switchToNextKey();
        } else if (_userApiKey != null) {
          // If using user key and hit max retries, just fail
          rethrow;
        }
      }
    }

    throw Exception('OMDB > All API key attempts failed after $totalAttempts tries');
  }

  String? get userApiKey => _userApiKey;

  bool get hasUserApiKey => _userApiKey != null && _userApiKey!.isNotEmpty;
}
