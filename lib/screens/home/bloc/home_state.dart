part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  final int focusedSectionIndex; // -1 for nav, 0 for movies, 1 for tv shows
  final int focusedNavIndex; // -1 for content, 0-3 for nav items
  final double? scrollToOffset; // Target scroll offset, null if no scroll needed
  final List<MovieModel> trendingMovies;
  final List<TvShowModel> trendingTvShows;
  final String? errorMessage; // Only used by HomeError

  const HomeState({
    required this.focusedSectionIndex,
    required this.focusedNavIndex,
    this.scrollToOffset,
    this.trendingMovies = const [],
    this.trendingTvShows = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        focusedSectionIndex,
        focusedNavIndex,
        scrollToOffset,
        trendingMovies,
        trendingTvShows,
        errorMessage,
      ];

  HomeState copyWith({
    int? focusedSectionIndex,
    int? focusedNavIndex,
    double? scrollToOffset,
    bool setScrollToNull = false,
  }) {
    if (this is HomeLoaded) {
      final current = this as HomeLoaded;
      return HomeLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        trendingMovies: current.trendingMovies,
        trendingTvShows: current.trendingTvShows,
        moviePosters: current.moviePosters,
        tvShowPosters: current.tvShowPosters,
      );
    } else if (this is HomeMoviesLoaded) {
      final current = this as HomeMoviesLoaded;
      return HomeMoviesLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        trendingMovies: current.trendingMovies,
      );
    } else if (this is HomeTvShowsLoaded) {
      final current = this as HomeTvShowsLoaded;
      return HomeTvShowsLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        trendingMovies: current.trendingMovies,
        trendingTvShows: current.trendingTvShows,
        moviePosters: current.moviePosters,
      );
    } else if (this is HomeInitial) {
      return HomeInitial(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
      );
    } else if (this is HomeError) {
      final currentError = this as HomeError;
      return HomeError(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        errorMessage: currentError.errorMessage!, // Keep existing error message
      );
    } else if (this is HomeLoading) {
      return HomeLoading(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
      );
    }
    return this;
  }
}

final class HomeInitial extends HomeState {
  const HomeInitial({
    super.focusedSectionIndex = -1,
    super.focusedNavIndex = 3, // Start with Home focused
    super.scrollToOffset,
  });
}

final class HomeLoading extends HomeState {
  const HomeLoading({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
  });
}

final class HomeMoviesLoaded extends HomeState {
  @override
  final List<MovieModel> trendingMovies;

  const HomeMoviesLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.trendingMovies,
  });

  @override
  List<Object?> get props => [...super.props, trendingMovies];
}

final class HomeTvShowsLoaded extends HomeState {
  @override
  final List<MovieModel> trendingMovies;
  @override
  final List<TvShowModel> trendingTvShows;
  final Map<int, String> moviePosters;

  const HomeTvShowsLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.trendingMovies,
    required this.trendingTvShows,
    required this.moviePosters,
  });

  @override
  List<Object?> get props => [...super.props, trendingMovies, trendingTvShows, moviePosters];
}

final class HomeLoaded extends HomeState {
  @override
  final List<MovieModel> trendingMovies;
  @override
  final List<TvShowModel> trendingTvShows;
  final Map<int, String> moviePosters;
  final Map<int, String> tvShowPosters;

  const HomeLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.trendingMovies,
    required this.trendingTvShows,
    required this.moviePosters,
    required this.tvShowPosters,
  });

  @override
  List<Object?> get props =>
      [...super.props, trendingMovies, trendingTvShows, moviePosters, tvShowPosters];

  HomeLoaded copyWithPosters({
    Map<int, String>? moviePosters,
    Map<int, String>? tvShowPosters,
  }) {
    return HomeLoaded(
      focusedSectionIndex: focusedSectionIndex,
      focusedNavIndex: focusedNavIndex,
      scrollToOffset: scrollToOffset,
      trendingMovies: trendingMovies,
      trendingTvShows: trendingTvShows,
      moviePosters: moviePosters ?? this.moviePosters,
      tvShowPosters: tvShowPosters ?? this.tvShowPosters,
    );
  }
}

final class HomeError extends HomeState {
  const HomeError({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required String super.errorMessage,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
