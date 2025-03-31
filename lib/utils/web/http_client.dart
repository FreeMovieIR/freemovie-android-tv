import 'package:dio/dio.dart';

final Dio tmdbHttpClient = Dio(
  BaseOptions(
    baseUrl: const String.fromEnvironment('TMDB_BASE_URL', defaultValue: 'https://api.themoviedb.org/3/'),
    headers: {
      'Authorization': 'Bearer ${const String.fromEnvironment('TMDB_API_KEY')}',
    },
  ),
);

final Dio omdbHttpClient = Dio(
  BaseOptions(
    baseUrl: const String.fromEnvironment('OMDB_BASE_URL', defaultValue: 'http://www.omdbapi.com/'),
    queryParameters: {
      'apikey': const String.fromEnvironment('OMDB_API_KEY'),
    },
  ),
);
