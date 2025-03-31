import 'package:dio/dio.dart';

final Dio tmdbHttpClient = Dio(
  BaseOptions(baseUrl: const String.fromEnvironment('TMDB_BASE_URL')),
);

final Dio omdbHttpClient = Dio(
  BaseOptions(baseUrl: const String.fromEnvironment('OMDB_BASE_URL')),
);
