import '../../utils/enums/media_type.dart';
import '../../utils/web/http_client.dart';
import '../model/movie.dart';
import '../model/tv_show.dart';
import '../src/home_src.dart';

final homeRepository = HomeRepository(HomeRemoteSrc(
  tmdbHttpClient: tmdbHttpClient,
  omdbHttpClient: omdbHttpClient,
));

class HomeRepository {
  final HomeRemoteSrc _remoteSrc;

  HomeRepository(this._remoteSrc);

  // TODO: handle exceptions in 3 methods below

  Future<List<MovieModel>> getRawTrendingMovies() async => await _remoteSrc.getTrendingMovies();

  Future<List<TvShowModel>> getRawTrendingTvShows() async => await _remoteSrc.getTrendingShows();

  Future<String?> getPoster(int tmdbId, MediaType type) async {
    final String imdbId = await _remoteSrc.convertTmdbToImdb(tmdbId, type);
    return await _remoteSrc.getOmdbPosterUrl(imdbId);
  }
}
