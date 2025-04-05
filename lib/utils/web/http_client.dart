import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'api_key_switcher.dart';

final Dio tmdbHttpClient = Dio(
  BaseOptions(
    baseUrl: const String.fromEnvironment('TMDB_BASE_URL',
        defaultValue: 'https://api.themoviedb.org/3/'),
    headers: {
      'Authorization': 'Bearer ${const String.fromEnvironment('TMDB_API_KEY')}',
    },
  ),
);

final Dio omdbHttpClient = Dio(
  BaseOptions(
    baseUrl: const String.fromEnvironment('OMDB_BASE_URL', defaultValue: 'http://www.omdbapi.com/'),
  ),
);

late ApiKeySwitcher omdbApiKeySwitcher;

Future<void> initializeApiClients() async {
  List<String> keys = [];
  try {
    final String keysJson = await rootBundle.loadString('assets/omdb_keys.json');
    keys = List<String>.from(jsonDecode(keysJson));
  } catch (e) {
    // If file loading fails, use a default key
    keys = ['38fa39d5'];
  }

  omdbApiKeySwitcher = await ApiKeySwitcher.initialize(keys);
}
