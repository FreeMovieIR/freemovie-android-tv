part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  final int focusedSectionIndex; // -1 for nav, 0 for movies, 1 for tv shows
  final int focusedNavIndex; // -1 for content, 0-3 for nav items
  final bool isAnnouncementBtnFocused; // false for not selected, true for selected
  final int focusedSliderActionBtnIndex; // -1 for not selected, 0-1 for buttons
  final int focusedSlideNavigationBtnIndex; // -1 for not selected, 0-1 for buttons
  final double? scrollToOffset; // Target scroll offset, null if no scroll needed
  final List<MovieModel> trendingMovies;
  final List<TvShowModel> trendingTvShows;
  final String? errorMessage; // Only used by HomeError
  final int sliderIndex;
  final List<SliderItem> sliderItems;

  const HomeState({
    required this.focusedSectionIndex,
    required this.focusedNavIndex,
    required this.isAnnouncementBtnFocused,
    required this.focusedSliderActionBtnIndex,
    required this.focusedSlideNavigationBtnIndex,
    this.scrollToOffset,
    this.trendingMovies = const [],
    this.trendingTvShows = const [],
    this.sliderItems = const [],
    this.sliderIndex = 0,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        focusedSectionIndex,
        focusedNavIndex,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex,
        scrollToOffset,
        trendingMovies,
        trendingTvShows,
        sliderItems,
        sliderIndex,
        errorMessage,
      ];

  HomeState copyWith({
    int? focusedSectionIndex,
    int? focusedNavIndex,
    bool? isAnnouncementBtnFocused,
    int? focusedSliderActionBtnIndex,
    int? focusedSlideNavigationBtnIndex,
    double? scrollToOffset,
    bool setScrollToNull = false,
    List<MovieModel>? trendingMovies,
    List<TvShowModel>? trendingTvShows,
    List<SliderItem>? sliderItems,
    int? sliderIndex,
    String? errorMessage,
  }) {
    if (this is HomeLoaded) {
      final current = this as HomeLoaded;
      return HomeLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        sliderItems: current.sliderItems,
        sliderIndex: sliderIndex ?? this.sliderIndex,
        trendingMovies: current.trendingMovies,
        trendingTvShows: current.trendingTvShows,
        moviePosters: current.moviePosters,
        tvShowPosters: current.tvShowPosters,
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
      );
    } else if (this is HomeSlidesLoaded) {
      final current = this as HomeSlidesLoaded;
      return HomeSlidesLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        sliderItems: current.sliderItems,
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
      );
    } else if (this is HomeMoviesLoaded) {
      final current = this as HomeMoviesLoaded;
      return HomeMoviesLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        sliderItems: current.sliderItems,
        trendingMovies: current.trendingMovies,
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
      );
    } else if (this is HomeTvShowsLoaded) {
      final current = this as HomeTvShowsLoaded;
      return HomeTvShowsLoaded(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        sliderItems: current.sliderItems,
        trendingMovies: current.trendingMovies,
        trendingTvShows: current.trendingTvShows,
        moviePosters: current.moviePosters,
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
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
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
      );
    } else if (this is HomeLoading) {
      return HomeLoading(
        focusedSectionIndex: focusedSectionIndex ?? this.focusedSectionIndex,
        focusedNavIndex: focusedNavIndex ?? this.focusedNavIndex,
        scrollToOffset: setScrollToNull ? null : scrollToOffset ?? this.scrollToOffset,
        isAnnouncementBtnFocused: isAnnouncementBtnFocused ?? this.isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex:
            focusedSliderActionBtnIndex ?? this.focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex:
            focusedSlideNavigationBtnIndex ?? this.focusedSlideNavigationBtnIndex,
      );
    }
    return this;
  }
}

final class HomeInitial extends HomeState {
  const HomeInitial({
    super.focusedSectionIndex = notSelectedIndex,
    super.focusedNavIndex = homeNavIndex, // Start with Home focused
    super.scrollToOffset,
    super.isAnnouncementBtnFocused = false,
    super.focusedSliderActionBtnIndex = notSelectedIndex,
    super.focusedSlideNavigationBtnIndex = notSelectedIndex,
  });
}

final class HomeLoading extends HomeState {
  const HomeLoading({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });
}

final class HomeSlidesLoaded extends HomeState {
  @override
  final List<SliderItem> sliderItems;

  const HomeSlidesLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.sliderItems,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        trendingMovies,
        trendingTvShows,
        sliderItems,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex
      ];
}

final class HomeMoviesLoaded extends HomeState {
  @override
  final List<SliderItem> sliderItems;
  @override
  final List<MovieModel> trendingMovies;

  const HomeMoviesLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.sliderItems,
    required this.trendingMovies,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        trendingMovies,
        sliderItems,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex
      ];
}

final class HomeTvShowsLoaded extends HomeState {
  @override
  final List<SliderItem> sliderItems;
  @override
  final List<MovieModel> trendingMovies;
  @override
  final List<TvShowModel> trendingTvShows;
  final Map<int, String> moviePosters;

  const HomeTvShowsLoaded({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required this.sliderItems,
    required this.trendingMovies,
    required this.trendingTvShows,
    required this.moviePosters,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        sliderItems,
        trendingMovies,
        trendingTvShows,
        moviePosters,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex
      ];
}

final class HomeLoaded extends HomeState {
  @override
  final List<SliderItem> sliderItems;
  @override
  final int sliderIndex;
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
    required this.sliderItems,
    required this.sliderIndex,
    required this.trendingMovies,
    required this.trendingTvShows,
    required this.moviePosters,
    required this.tvShowPosters,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        trendingMovies,
        trendingTvShows,
        sliderItems,
        sliderIndex,
        moviePosters,
        tvShowPosters,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex
      ];

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
      sliderItems: sliderItems,
      sliderIndex: sliderIndex,
      moviePosters: moviePosters ?? this.moviePosters,
      tvShowPosters: tvShowPosters ?? this.tvShowPosters,
      isAnnouncementBtnFocused: isAnnouncementBtnFocused,
      focusedSliderActionBtnIndex: focusedSliderActionBtnIndex,
      focusedSlideNavigationBtnIndex: focusedSlideNavigationBtnIndex,
    );
  }
}

final class HomeError extends HomeState {
  const HomeError({
    required super.focusedSectionIndex,
    required super.focusedNavIndex,
    super.scrollToOffset,
    required String super.errorMessage,
    required super.isAnnouncementBtnFocused,
    required super.focusedSliderActionBtnIndex,
    required super.focusedSlideNavigationBtnIndex,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        errorMessage,
        isAnnouncementBtnFocused,
        focusedSliderActionBtnIndex,
        focusedSlideNavigationBtnIndex
      ];
}
