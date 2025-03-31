import 'package:freemovie_android_tv/data/model/tv_show.dart';
import 'package:freemovie_android_tv/utils/enums/media_type.dart';

import '../../utils/web/http_client.dart';
import '../model/movie.dart';
import '../src/home_src.dart';

final homeRepository = HomeRepository(HomeRemoteSrc(
  tmdbHttpClient: tmdbHttpClient,
  omdbHttpClient: omdbHttpClient,
));

class HomeRepository {
  final HomeRemoteSrc _remoteSrc;

  HomeRepository(this._remoteSrc);

  Future<List<MovieModel>> getTrendingMovies() async {
    try {
      List<MovieModel> trendingMovies = await _remoteSrc.getTrendingMovies();
      List<MovieModel> moviesWithPoster = List.empty(growable: true);
      for (MovieModel movie in trendingMovies) {
        final String imdbId = await _remoteSrc.convertTmdbToImdb(movie.id, MediaType.movie);
        final String posterPath = await _remoteSrc.getOmdbPosterUrl(imdbId);

        moviesWithPoster.add(movie.copyWith(posterPath: posterPath));
      }

      return moviesWithPoster;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<TvShowModel>> getTrendingTvShows() async {
    try {
      List<TvShowModel> trendingShows = await _remoteSrc.getTrendingShows();
      List<TvShowModel> showsWithPoster = List.empty(growable: true);
      for (TvShowModel show in trendingShows) {
        final String imdbId = await _remoteSrc.convertTmdbToImdb(show.id, MediaType.tv);
        final String posterPath = await _remoteSrc.getOmdbPosterUrl(imdbId);

        showsWithPoster.add(show.copyWith(posterPath: posterPath));
      }

      return showsWithPoster;
    } catch (e) {
      throw Exception(e);
    }
  }
}
