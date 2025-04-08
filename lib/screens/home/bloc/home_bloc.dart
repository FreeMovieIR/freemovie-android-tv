import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/model/movie.dart';
import '../../../data/model/tv_show.dart';
import '../../../data/repo/home_repo.dart';
import '../../../utils/enums/media_type.dart';
import '../index_and_offset.dart';
import '../slider.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  bool _processingKeyEvent = false;
  Timer? _keyProcessingTimer;
  int _stuckCounter = 0;

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
    if (_processingKeyEvent) {
      _stuckCounter++;

      // Emergency reset if we detect repeated stuck states
      if (_stuckCounter > 3) {
        _processingKeyEvent = false;
        _stuckCounter = 0;
        debugPrint("Emergency reset of focus processing");
      }
      return; // Prevent processing new key events too quickly
    }

    _processingKeyEvent = true;
    _stuckCounter = 0;

    // Cancel any existing timers to prevent multiple timers
    _keyProcessingTimer?.cancel();

    final currentState = state;
    int currentNavIndex = currentState.focusedNavIndex;
    // int currentSectionIndex = currentState.focusedSectionIndex;

    try {
      // Logic for NavigationBar Focus (currentNavIndex >= 0)
      if (currentNavIndex >= 0) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (currentNavIndex < 5) {
            currentNavIndex++;
            emit(state.copyWith(
              focusedNavIndex: currentNavIndex,
              focusedSectionIndex: -1,
            ));
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (currentNavIndex > 0) {
            currentNavIndex--;
            emit(state.copyWith(
              focusedNavIndex: currentNavIndex,
              focusedSectionIndex: -1,
            ));
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          // Move from nav bar to content (first section)
          currentNavIndex = -1;
          emit(state.copyWith(
            focusedNavIndex: currentNavIndex,
            focusedSectionIndex: announcementSectionIndex,
            scrollToOffset: announcementSectionOffset,
            isAnnouncementBtnFocused: true,
          ));
        } else if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          // TODO: Handle select/enter action on nav items
        }
      }
      // Logic for Content Section Focus (focusedSectionIndex >= 0)
      else if (state.focusedSectionIndex >= 0) {
        // 0 > Announcement Banner
        // 1 > Slider
        // 2 > Movies
        // 3 > Tv Shows

        /// Announcement Banner
        if (state.focusedSectionIndex == announcementSectionIndex) {
          // Scroll down to Slider
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            emit(state.copyWith(
              focusedSectionIndex: sliderSectionIndex,
              focusedSliderActionBtnIndex: playSliderActionBtnIndex,
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              scrollToOffset: sliderSectionOffset,
              isAnnouncementBtnFocused: false,
            ));
          }
          // Go back to Nav bar
          else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emit(state.copyWith(
              focusedSectionIndex: notSelectedIndex,
              focusedNavIndex: homeNavIndex, // Default to Home nav item
              scrollToOffset: announcementSectionOffset,
              isAnnouncementBtnFocused: false,
            ));
          }
          // Do nothing
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          }
          // Do nothing
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {}
        }

        /// Slider
        else if (state.focusedSectionIndex == sliderSectionIndex) {
          // Play Btn
          if (state.focusedSliderActionBtnIndex == playSliderActionBtnIndex) {
            // Go to Slide Navigation Btns
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                focusedSectionIndex: sliderSectionIndex,
                focusedNavIndex: notSelectedIndex,
                focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                isAnnouncementBtnFocused: false,
                isTvShowItemsFocused: false,
                isMovieItemsFocused: false,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                scrollToOffset: sliderSectionOffset,
              ));
            }
            // Go Back to Announcement Section
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: announcementSectionOffset,
                focusedSectionIndex: announcementSectionIndex,
                isAnnouncementBtnFocused: true,
              ));
            }
            // Select Bookmark Btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              emit(state.copyWith(
                focusedSliderActionBtnIndex: bookmarkSliderActionBtnIndex,
                scrollToOffset: sliderSectionOffset,
              ));
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {}
          }
          // Bookmark Btn
          else if (state.focusedSliderActionBtnIndex == bookmarkSliderActionBtnIndex) {
            // Go to Slide Navigation Btns
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
              ));
            }
            // Go Back to Announcement Section
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: announcementSectionOffset,
                focusedSectionIndex: announcementSectionIndex,
                isAnnouncementBtnFocused: true,
              ));
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // Select Play Btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              emit(state.copyWith(
                focusedSliderActionBtnIndex: playSliderActionBtnIndex,
                scrollToOffset: sliderSectionOffset,
              ));
            }
          }
          // Next Slide Btn
          else if (state.focusedSlideNavigationBtnIndex == sliderNextNavigationBtnIndex) {
            // go to movie row section
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: movieSectionOffset,
                focusedSectionIndex: moviesSectionIndex,
                isShowMoreMoviesFocused: true,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));
            }
            // go back to slider action btns
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: playSliderActionBtnIndex,
                focusedSectionIndex: sliderSectionIndex,
                focusedNavIndex: notSelectedIndex,
                isAnnouncementBtnFocused: false,
                isTvShowItemsFocused: false,
                isMovieItemsFocused: false,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                scrollToOffset: sliderSectionOffset,
              ));

              // Force immediate reset of processing flag to prevent getting stuck
              _keyProcessingTimer?.cancel();
              _keyProcessingTimer = Timer(const Duration(milliseconds: 10), () {
                _processingKeyEvent = false;
                debugPrint("Forced immediate key processing reset");
              });
            }
            // do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // navigate to prev slide btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              emit(state.copyWith(
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: sliderSectionOffset,
                focusedSlideNavigationBtnIndex: sliderPrevNavigationBtnIndex,
              ));
            }
            // confirm btn /  move slider to next item (Increment)
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // Increment sliderIndex if not at the end
              if (state.sliderIndex < state.sliderItems.length - 1) {
                // Check boundary
                emit(state.copyWith(
                  focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex, // Keep focus
                  sliderIndex: state.sliderIndex + 1, // INCREMENT
                ));
              }
            }
          }
          // Prev Slide Btn
          else if (state.focusedSlideNavigationBtnIndex == sliderPrevNavigationBtnIndex) {
            // Select Show More Movies Btn
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: movieSectionOffset,
                focusedSectionIndex: moviesSectionIndex,
                isShowMoreMoviesFocused: true,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));
            }
            // go back to slider action btns
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: notSelectedIndex,
                focusedSliderActionBtnIndex: playSliderActionBtnIndex,
                focusedSectionIndex: sliderSectionIndex,
                focusedNavIndex: notSelectedIndex,
                isAnnouncementBtnFocused: false,
                isTvShowItemsFocused: false,
                isMovieItemsFocused: false,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                scrollToOffset: sliderSectionOffset,
              ));

              // Force immediate reset of processing flag to prevent getting stuck
              _keyProcessingTimer?.cancel();
              _keyProcessingTimer = Timer(const Duration(milliseconds: 10), () {
                _processingKeyEvent = false;
                debugPrint("Forced immediate key processing reset");
              });
            }
            // navigate to next slide btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              emit(state.copyWith(
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: sliderSectionOffset,
                focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
              ));
            }
            // do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            }
            // confirm btn /  move slider to prev item (Decrement)
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // Decrement sliderIndex if not at the beginning
              if (state.sliderIndex > 0) {
                // Check boundary
                emit(state.copyWith(
                  focusedSlideNavigationBtnIndex: sliderPrevNavigationBtnIndex, // Keep focus
                  sliderIndex: state.sliderIndex - 1, // DECREMENT
                ));
              }
            }
          }
        }

        /// Movies
        else if (state.focusedSectionIndex == moviesSectionIndex) {
          // Show More Movies Btn
          if (state.isShowMoreMoviesFocused) {
            // Select Movie Items
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                scrollToOffset: movieSectionOffset,
                focusedSectionIndex: moviesSectionIndex,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: true,
                isTvShowItemsFocused: false,
              ));
            }
            // Go Back To Slider Navigation Btns
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
                focusedSliderActionBtnIndex: notSelectedIndex,
                scrollToOffset: sliderSectionOffset,
                focusedSectionIndex: sliderSectionIndex,
                focusedNavIndex: notSelectedIndex,
                isAnnouncementBtnFocused: false,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));

              // Force immediate reset of processing flag to prevent getting stuck
              _keyProcessingTimer?.cancel();
              _keyProcessingTimer = Timer(const Duration(milliseconds: 10), () {
                _processingKeyEvent = false;
                debugPrint("Forced immediate key processing reset");
              });
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            }
            // Confirm Btn / Select Show more btn
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // TODO: Handle show more action
            }
          }
          // Movie Items
          else if (state.isMovieItemsFocused) {
            // Select Show More Tv Shows Btn
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                scrollToOffset: tvShowSectionOffset,
                focusedSectionIndex: tvShowsSectionIndex,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: true,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));
            }
            // Go Back To Movie Show More Btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                scrollToOffset: movieSectionOffset,
                focusedSectionIndex: moviesSectionIndex,
                isShowMoreMoviesFocused: true,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            }
            // Confirm Btn / Select Show more btn
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // TODO: Handle movie item selection
            }
          }
        }

        /// Tv Shows
        else if (state.focusedSectionIndex == tvShowsSectionIndex) {
          // Show More Btn
          if (state.isShowMoreTvShowsFocused) {
            // Select Tv Show Items
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              emit(state.copyWith(
                scrollToOffset: tvShowSectionOffset,
                focusedSectionIndex: tvShowsSectionIndex,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: true,
              ));
            }
            // Go Back Movie Items
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                scrollToOffset: movieSectionOffset,
                focusedSectionIndex: moviesSectionIndex,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: false,
                isMovieItemsFocused: true,
                isTvShowItemsFocused: false,
              ));
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            }
            // Confirm Btn / Select Show more btn
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // TODO: Handle show more action
            }
          }
          // Tv Show Items
          else if (state.isTvShowItemsFocused) {
            // Do nothing
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            }
            // Go Back To TvShow Show More Btn
            else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              emit(state.copyWith(
                scrollToOffset: tvShowSectionOffset,
                focusedSectionIndex: tvShowsSectionIndex,
                isShowMoreMoviesFocused: false,
                isShowMoreTvShowsFocused: true,
                isMovieItemsFocused: false,
                isTvShowItemsFocused: false,
              ));
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            }
            // Do nothing
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            }
            // Confirm Btn / Select Show more btn
            else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              // TODO: Handle tv show item selection
            }
          }
        }
      }
    } finally {
      // Reset the processing flag after a short delay - this is critical to prevent getting stuck
      _keyProcessingTimer = Timer(const Duration(milliseconds: 150), () {
        _processingKeyEvent = false;
        debugPrint("Key processing reset");
      });
    }
  }

  Future<void> _onLoadData(HomeLoadData event, Emitter<HomeState> emit) async {
    emit(HomeLoading(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
        isShowMoreTvShowsFocused: false,
        isMovieItemsFocused: false,
        isShowMoreMoviesFocused: false,
        isTvShowItemsFocused: false));

    try {
      final List<MovieModel> trendingMovies = await _homeRepository.getRawTrendingMovies();
      emit(
        HomeSlidesLoaded(
          focusedSectionIndex: state.focusedSectionIndex,
          focusedNavIndex: state.focusedNavIndex,
          scrollToOffset: state.scrollToOffset,
          sliderItems: trendingMovies
              .take(5)
              .map((movie) => SliderItem(
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    backdropPath: '',
                    releaseDate: movie.releaseDate,
                    voteAverage: movie.vote,
                    type: 'movie',
                  ))
              .toList(),
          isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
          focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
          focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
          isShowMoreTvShowsFocused: false,
          isMovieItemsFocused: false,
          isShowMoreMoviesFocused: false,
          isTvShowItemsFocused: false,
        ),
      );
      emit(HomeMoviesLoaded(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        sliderItems: trendingMovies
            .take(5)
            .map((movie) => SliderItem(
                  id: movie.id,
                  title: movie.title,
                  overview: movie.overview,
                  backdropPath: '',
                  releaseDate: movie.releaseDate,
                  voteAverage: movie.vote,
                  type: 'movie',
                ))
            .toList(),
        trendingMovies: trendingMovies,
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
        isShowMoreTvShowsFocused: false,
        isMovieItemsFocused: false,
        isShowMoreMoviesFocused: false,
        isTvShowItemsFocused: false,
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
        sliderItems: trendingMovies
            .take(5)
            .map((movie) => SliderItem(
                  id: movie.id,
                  title: movie.title,
                  overview: movie.overview,
                  backdropPath: moviePosters[movie.id] ?? '',
                  releaseDate: movie.releaseDate,
                  voteAverage: movie.vote,
                  type: 'movie',
                ))
            .toList(),
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
        isShowMoreTvShowsFocused: false,
        isMovieItemsFocused: false,
        isShowMoreMoviesFocused: false,
        isTvShowItemsFocused: false,
      ));

      _fetchPostersInBackground(trendingMovies, trendingShows);

      final currentFocusState = state;
      emit(HomeLoaded(
        focusedSectionIndex: currentFocusState.focusedSectionIndex,
        focusedNavIndex: currentFocusState.focusedNavIndex,
        scrollToOffset: currentFocusState.scrollToOffset,
        sliderItems: trendingMovies
            .take(5)
            .map((movie) => SliderItem(
                  id: movie.id,
                  title: movie.title,
                  overview: movie.overview,
                  backdropPath: moviePosters[movie.id] ?? '',
                  releaseDate: movie.releaseDate,
                  voteAverage: movie.vote,
                  type: 'movie',
                ))
            .toList(),
        trendingMovies: trendingMovies,
        trendingTvShows: trendingShows,
        moviePosters: moviePosters,

        // Initial empty maps
        tvShowPosters: {}, // Initial empty maps
        isShowMoreTvShowsFocused: state.isShowMoreTvShowsFocused,
        isShowMoreMoviesFocused: state.isShowMoreMoviesFocused,
        isMovieItemsFocused: state.isMovieItemsFocused,
        isTvShowItemsFocused: state.isTvShowItemsFocused,
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
        sliderIndex: 0,
      ));
    } catch (e) {
      // Emit Error state with the error message, preserving focus
      emit(HomeError(
        focusedSectionIndex: state.focusedSectionIndex,
        focusedNavIndex: state.focusedNavIndex,
        scrollToOffset: state.scrollToOffset,
        errorMessage: e.toString(),
        // Optionally add previous data if needed for display
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        isShowMoreTvShowsFocused: state.isShowMoreTvShowsFocused,
        isShowMoreMoviesFocused: state.isShowMoreMoviesFocused,
        isMovieItemsFocused: state.isMovieItemsFocused,
        isTvShowItemsFocused: state.isTvShowItemsFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
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
      List<SliderItem> currentSliderItems = [];

      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        currentMoviePosters = Map.from(currentState.moviePosters);
        currentTvShowPosters = Map.from(currentState.tvShowPosters);
        currentSliderItems = currentState.trendingMovies
            .take(5)
            .map((movie) => SliderItem(
                  id: movie.id,
                  title: movie.title,
                  overview: movie.overview,
                  backdropPath: currentMoviePosters[movie.id] ?? '',
                  releaseDate: movie.releaseDate,
                  voteAverage: movie.vote,
                  type: 'movie',
                ))
            .toList();
      } else if (state is HomeTvShowsLoaded) {
        final currentState = state as HomeTvShowsLoaded;
        currentMoviePosters = Map.from(currentState.moviePosters);
        currentSliderItems = currentState.trendingMovies
            .take(5)
            .map((movie) => SliderItem(
                  id: movie.id,
                  title: movie.title,
                  overview: movie.overview,
                  backdropPath: currentMoviePosters[movie.id] ?? '',
                  releaseDate: movie.releaseDate,
                  voteAverage: movie.vote,
                  type: 'movie',
                ))
            .toList();
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
        sliderItems: currentSliderItems,
        sliderIndex: 0,
        trendingMovies: (state is HomeLoaded)
            ? (state as HomeLoaded).trendingMovies
            : (state as HomeTvShowsLoaded).trendingMovies,
        trendingTvShows: (state is HomeLoaded)
            ? (state as HomeLoaded).trendingTvShows
            : (state as HomeTvShowsLoaded).trendingTvShows,
        moviePosters: currentMoviePosters,
        tvShowPosters: currentTvShowPosters,
        isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
        isShowMoreTvShowsFocused: state.isShowMoreTvShowsFocused,
        isShowMoreMoviesFocused: state.isShowMoreMoviesFocused,
        isMovieItemsFocused: state.isMovieItemsFocused,
        isTvShowItemsFocused: state.isTvShowItemsFocused,
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
      ));
    }
  }
}
