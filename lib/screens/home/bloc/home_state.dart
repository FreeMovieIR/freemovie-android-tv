part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  // Navigation/Focus state
  final int focusedSectionIndex; // -1 for nav, 0 for movies, 1 for tv shows
  final int focusedNavIndex; // -1 for content, 0-3 for nav items
  final double? scrollToOffset; // Target scroll offset, null if no scroll needed

  // Data state
  final DataStatus status;
  final List<MovieModel> trendingMovies;
  final List<TvShowModel> trendingTvShows;
  final String? errorMessage;

  const HomeState({
    // Focus
    required this.focusedSectionIndex,
    required this.focusedNavIndex,
    this.scrollToOffset,
    // Data
    this.status = DataStatus.loading,
    this.trendingMovies = const [],
    this.trendingTvShows = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        focusedSectionIndex,
        focusedNavIndex,
        scrollToOffset,
        status,
        trendingMovies,
        trendingTvShows,
        errorMessage,
      ];

  HomeState copyWith({
    int? focusedSectionIndex,
    int? focusedNavIndex,
    double? scrollToOffset,
    bool setScrollToNull = false,
    DataStatus? status,
    List<MovieModel>? trendingMovies,
    List<TvShowModel>? trendingTvShows,
    String? errorMessage,
    bool clearErrorMessage = false, // Flag to explicitly clear error
  }) {
    return HomeLoaded(
      // Focus state
      focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
      focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
      scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
      // Data state
      status: status ?? this.status,
      trendingMovies: trendingMovies ?? this.trendingMovies,
      trendingTvShows: trendingTvShows ?? this.trendingTvShows,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Initial state: Includes focus state and initial data status
final class HomeInitial extends HomeState {
  const HomeInitial()
      : super(
          focusedSectionIndex: -1,
          focusedNavIndex: 3, // Start with Home focused
          scrollToOffset: null,
          status: DataStatus.loading,
        );
}

// Loaded state: Now represents both focus and loaded data
final class HomeLoaded extends HomeState {
  const HomeLoaded({
    // Focus
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    // Data
    super.status = DataStatus.loaded,
    required super.trendingMovies,
    required super.trendingTvShows,
    super.errorMessage,
  });
}

// Consider adding HomeError state if HomeBloc itself can encounter errors.
// final class HomeError extends HomeState { ... }
