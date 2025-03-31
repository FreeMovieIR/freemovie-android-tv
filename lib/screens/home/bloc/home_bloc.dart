import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import '../../../data/model/movie.dart';
import '../../../data/model/tv_show.dart';
import '../../../data/repo/home_repo.dart';
import '../../../utils/enums/data_status.dart';

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
    try {
      emit(state.copyWith(status: DataStatus.loading));

      final List<MovieModel> trendingMovies = await _homeRepository.getTrendingMovies();
      final List<TvShowModel> trendingShows = await _homeRepository.getTrendingTvShows();

      emit(state.copyWith(
        status: DataStatus.loaded,
        trendingMovies: trendingMovies,
        trendingTvShows: trendingShows,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
