import '../enums/media_type.dart';
import '../extensions/media_type.dart';

const String language = 'fa';
const String defaultTmdbApiKey = String.fromEnvironment('TMDB_API_KEY'); // کلید پیش‌فرض TMDb
const String defaultOmdbApiKey = String.fromEnvironment('OMDB_API_KEY'); // کلید پیش‌فرض OMDb

const String trendingMoviesURL =
    'trending/movie/week?api_key=$defaultTmdbApiKey&language=$language';
const String trendingTvShowsURL = 'trending/tv/week?api_key=$defaultTmdbApiKey&language=$language';

String getImdbIdURL({required MediaType type, required int tmdbId}) =>
    '${type.toApiString()}/$tmdbId/external_ids?api_key=$defaultTmdbApiKey';

String getImageURL({required String imdbId}) => '?i=$imdbId&apikey=$defaultOmdbApiKey';
