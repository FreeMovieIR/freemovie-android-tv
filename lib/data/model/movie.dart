class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String originalLanguage;
  final String posterPath;
  final String releaseDate;
  final double vote;

  MovieModel(
      {required this.id,
      required this.title,
      required this.originalTitle,
      required this.overview,
      required this.originalLanguage,
      required this.posterPath,
      required this.releaseDate,
      required this.vote});

  MovieModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        overview = json['overview'] ?? 'null',
        title = json['title'] ?? 'null',
        originalTitle = json['original_title'] ?? 'null',
        originalLanguage = json['original_language'] ?? 'null',
        posterPath = json['poster_path'] ?? 'null',
        releaseDate = json['release_date'] ?? 'null',
        vote = json['vote_average'] ?? -1;

  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? originalLanguage,
    String? posterPath,
    String? originalTitle,
    String? releaseDate,
    double? vote,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      posterPath: posterPath ?? this.posterPath,
      originalTitle: originalTitle ?? this.originalTitle,
      releaseDate: releaseDate ?? this.releaseDate,
      vote: vote ?? this.vote,
    );
  }

  static List<MovieModel> parseJsonArray(List<dynamic> jsonArray) {
    final List<MovieModel> items = List.empty(growable: true);
    for (var jsonObject in jsonArray) {
      items.add(MovieModel.fromJson(jsonObject));
    }
    return items;
  }
}

class MovieListResponseModel {
  final int page;
  final List<MovieModel> movies;
  final int totalPages;
  final int totalResults;

  MovieListResponseModel.fromJson(Map<String, dynamic> json)
      : page = json['page'],
        movies = MovieModel.parseJsonArray(json['results']),
        totalPages = json['total_pages'],
        totalResults = json['total_results'];
}
