import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/model/movie.dart';
import '../../../data/model/tv_show.dart';
import '../../../data/repo/home_repo.dart';
import '../../../utils/enums/media_type.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  bool _processingKeyEvent = false;
  Timer? _keyProcessingTimer;

  HomeBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(const HomeInitial()) {
    on<HomeLoadData>(_onLoadData);
    on<HomeNavFocused>(_onNavFocused);
    on<HomeSectionFocused>(_onSectionFocused);
    on<HomeKeyPressed>(_onKeyPressed);
    on<HomePosterFetched>(_onPosterFetched);
  }

  @override
  Future<void> close() {
    _keyProcessingTimer?.cancel();
    return super.close();
  }

  void _onNavFocused(HomeNavFocused event, Emitter<HomeState> emit) {
    if (_processingKeyEvent) return;
    // When a nav item receives focus directly (e.g., initial focus, or focus change not from arrow keys)
    emit(state.copyWith(
        focusedNavIndex: event.navIndex, focusedSectionIndex: -1, setScrollToNull: true));
  }

  void _onSectionFocused(HomeSectionFocused event, Emitter<HomeState> emit) {
    if (_processingKeyEvent) return;
    // When a content section receives focus directly
    emit(state.copyWith(
        focusedSectionIndex: event.sectionIndex, focusedNavIndex: -1, setScrollToNull: true));
  }

  void _onKeyPressed(HomeKeyPressed event, Emitter<HomeState> emit) {
    if (_processingKeyEvent) return; // Prevent processing new key events too quickly
    _processingKeyEvent = true;

    final currentState = state;
    int currentNavIndex = currentState.focusedNavIndex;
    int currentSectionIndex = currentState.focusedSectionIndex;
    double? scrollToOffset;

    // Logic for NavigationBar Focus (currentNavIndex >= 0)
    if (currentNavIndex >= 0) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentNavIndex < 3) {
          currentNavIndex++;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (currentNavIndex > 0) {
          currentNavIndex--;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Move from nav bar to content (first section)
        currentNavIndex = -1;
        currentSectionIndex = 0;
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        // TODO: Handle select/enter action on nav items
      }
    }
    // Logic for Content Section Focus (currentSectionIndex >= 0)
    else if (currentSectionIndex >= 0) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Move from Movies (0) to TV Shows (1)
        if (currentSectionIndex == 0) {
          currentSectionIndex = 1;
          scrollToOffset = 300; // Scroll down to TV shows
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Move from TV Shows (1) to Movies (0)
        if (currentSectionIndex == 1) {
          currentSectionIndex = 0;
          scrollToOffset = 0; // Scroll up to Movies
        }
        // Move from Movies (0) to Nav Bar (Home: 3)
        else if (currentSectionIndex == 0) {
          currentSectionIndex = -1;
          currentNavIndex = 3; // Default to Home nav item
        }
      }
      // TODO: Handle Left/Right arrows within sections (movie/tv show items)
      // TODO: Handle select/enter on movie/tv show items
    }

    // Emit the new state if it changed
    if (currentNavIndex != currentState.focusedNavIndex ||
        currentSectionIndex != currentState.focusedSectionIndex ||
        scrollToOffset != currentState.scrollToOffset) {
      emit(state.copyWith(
        focusedNavIndex: currentNavIndex,
        focusedSectionIndex: currentSectionIndex,
        scrollToOffset: scrollToOffset,
        setScrollToNull: scrollToOffset == null,
      ));
    }

    // Reset the processing flag after a short delay
    _keyProcessingTimer?.cancel(); // Cancel any existing timer
    _keyProcessingTimer = Timer(const Duration(milliseconds: 150), () {
      _processingKeyEvent = false;
    });
  }

  Future<void> _onLoadData(HomeLoadData event, Emitter<HomeState> emit) async {
    emit(HomeLoading(
      focusedSectionIndex: state.focusedSectionIndex,
      focusedNavIndex: state.focusedNavIndex,
      scrollToOffset: state.scrollToOffset,
    ));

    try {
      final List<MovieModel> trendingMovies = await _homeRepository.getRawTrendingMovies();

      emit(HomeMoviesLoaded(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        trendingMovies: trendingMovies,
      ));

      final List<TvShowModel> trendingShows = await _homeRepository.getRawTrendingTvShows();
      final Map<int, String> moviePosters = {};

      emit(HomeTvShowsLoaded(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        trendingMovies: trendingMovies,
        trendingTvShows: trendingShows,
        moviePosters: moviePosters,
      ));

      _fetchPostersInBackground(trendingMovies, trendingShows);

      final currentFocusState = state;
      emit(HomeLoaded(
        focusedSectionIndex: currentFocusState.focusedSectionIndex,
        focusedNavIndex: currentFocusState.focusedNavIndex,
        scrollToOffset: currentFocusState.scrollToOffset,
        trendingMovies: trendingMovies,
        trendingTvShows: trendingShows,
        moviePosters: moviePosters,
        // Initial empty maps
        tvShowPosters: {}, // Initial empty maps
      ));
    } catch (e) {
      // Emit Error state with the error message, preserving focus
      emit(HomeError(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        errorMessage: e.toString(),
        // Optionally add previous data if needed for display
      ));
    }
  }

  void _fetchPostersInBackground(List<MovieModel> movies, List<TvShowModel> shows) {
    // Fetch movie posters
    for (final movie in movies) {
      _homeRepository.getPoster(movie.id, MediaType.movie).then((posterPath) {
        if (posterPath != null) {
          add(HomePosterFetched(
              mediaType: MediaType.movie, mediaId: movie.id, posterPath: posterPath));
        }
      }).catchError((error) {
        debugPrint("Error fetching poster for movie ${movie.id}: $error");
      });
    }

    // Fetch TV show posters
    for (final show in shows) {
      _homeRepository.getPoster(show.id, MediaType.tv).then((posterPath) {
        if (posterPath != null) {
          add(HomePosterFetched(mediaType: MediaType.tv, mediaId: show.id, posterPath: posterPath));
        }
      }).catchError((error) {
        debugPrint("Error fetching poster for show ${show.id}: $error");
      });
    }
  }

  void _onPosterFetched(HomePosterFetched event, Emitter<HomeState> emit) {
    if (state is HomeLoaded || state is HomeTvShowsLoaded) {
      Map<int, String> currentMoviePosters = {};
      Map<int, String> currentTvShowPosters = {};

      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        currentMoviePosters = Map.from(currentState.moviePosters);
        currentTvShowPosters = Map.from(currentState.tvShowPosters);
      } else if (state is HomeTvShowsLoaded) {
        final currentState = state as HomeTvShowsLoaded;
        currentMoviePosters = Map.from(currentState.moviePosters);
      }

      if (event.mediaType == MediaType.movie) {
        currentMoviePosters[event.mediaId] = event.posterPath!;
      } else {
        currentTvShowPosters[event.mediaId] = event.posterPath!;
      }

      emit(HomeLoaded(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        trendingMovies: (state is HomeLoaded)
            ? (state as HomeLoaded).trendingMovies
            : (state as HomeTvShowsLoaded).trendingMovies,
        trendingTvShows: (state is HomeLoaded)
            ? (state as HomeLoaded).trendingTvShows
            : (state as HomeTvShowsLoaded).trendingTvShows,
        moviePosters: currentMoviePosters,
        tvShowPosters: currentTvShowPosters,
      ));
    }
  }
}
