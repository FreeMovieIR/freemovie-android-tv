class TvShowModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String originalLanguage;
  final String originCountry;
  final String releaseDate;
  final double vote;

  TvShowModel(
      {required this.id,
      required this.title,
      required this.originalTitle,
      required this.overview,
      required this.originalLanguage,
      required this.originCountry,
      required this.releaseDate,
      required this.vote});

  TvShowModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        overview = json['overview'],
        title = json['name'],
        originalTitle = json['original_name'] ?? 'null',
        originalLanguage = json['original_language'],
        originCountry =
            (json['origin_country'] as List).isNotEmpty ? json['origin_country'][0] : '',
        releaseDate = json['first_air_date'],
        vote = json['vote_average'] ?? -1;

  TvShowModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? originalLanguage,
    String? originCountry,
    String? originalTitle,
    String? releaseDate,
    double? vote,
  }) {
    return TvShowModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      originCountry: originCountry ?? this.originCountry,
      originalTitle: originalTitle ?? this.originalTitle,
      releaseDate: releaseDate ?? this.releaseDate,
      vote: vote ?? this.vote,
    );
  }

  static List<TvShowModel> parseJsonArray(List<dynamic> jsonArray) {
    final List<TvShowModel> items = List.empty(growable: true);
    for (var jsonObject in jsonArray) {
      items.add(TvShowModel.fromJson(jsonObject));
    }
    return items;
  }
}

class TvShowListResponseModel {
  final int page;
  final List<TvShowModel> shows;
  final int totalPages;
  final int totalResults;

  TvShowListResponseModel.fromJson(Map<String, dynamic> json)
      : page = json['page'],
        shows = TvShowModel.parseJsonArray(json['results']),
        totalPages = json['total_pages'],
        totalResults = json['total_results'];
}
