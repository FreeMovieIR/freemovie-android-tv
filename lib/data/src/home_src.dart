import 'package:dio/dio.dart';
import 'package:freemovie_android_tv/data/model/tv_show.dart';
import 'package:freemovie_android_tv/utils/enums/media_type.dart';
import 'package:freemovie_android_tv/utils/web/urls.dart';

import '../model/movie.dart';

class HomeRemoteSrc {
  final Dio _tmdbHttpClient;
  final Dio _omdbHttpClient;

  HomeRemoteSrc({required Dio tmdbHttpClient, required Dio omdbHttpClient})
      : _tmdbHttpClient = tmdbHttpClient,
        _omdbHttpClient = omdbHttpClient;

  Future<List<MovieModel>> getTrendingMovies() async {
    final response = await _tmdbHttpClient.get(trendingMoviesURL);

    final List<MovieModel> nowPlayingMovies = MovieListResponseModel.fromJson(response.data).movies;

    return nowPlayingMovies;
  }

  Future<List<TvShowModel>> getTrendingShows() async {
    final response = await _tmdbHttpClient.get(trendingTvShowsURL);

    final List<TvShowModel> trendingShows = TvShowListResponseModel.fromJson(response.data).shows;

    return trendingShows;
  }

  Future<String> convertTmdbToImdb(int tmdbId, MediaType type) async {
    final response = await _tmdbHttpClient.get(getImdbIdURL(type: type, tmdbId: tmdbId));

    return response.data['imdb_id'];
  }

  Future<String> getOmdbPosterUrl(String imdbId) async {
    final response = await _omdbHttpClient.get(getImageURL(imdbId: imdbId));

    return response.data['Poster'] ?? '';
  }
}
