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
        currentSectionIndex = announcementSectionIndex;
        emit(state.copyWith(
          focusedNavIndex: currentNavIndex,
          focusedSectionIndex: currentSectionIndex,
          scrollToOffset: announcementSectionOffset,
          isAnnouncementBtnFocused: true,
        ));
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        // TODO: Handle select/enter action on nav items
      }
    }
    // Logic for Content Section Focus (currentSectionIndex >= 0)
    else if (currentSectionIndex >= 0) {
      // 0 > Announcement Banner
      // 1 > Slider
      // 2 > Movies
      // 3 > Tv Shows
      if (currentSectionIndex == announcementSectionIndex) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          emit(state.copyWith(
            focusedSectionIndex: sliderSectionIndex,
            focusedSliderActionBtnIndex: playSliderActionBtnIndex,
            focusedSlideNavigationBtnIndex: notSelectedIndex,
            scrollToOffset: sliderSectionOffset,
            // Scroll down to Slider
            isAnnouncementBtnFocused: false,
          ));
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          emit(state.copyWith(
            focusedSectionIndex: notSelectedIndex,
            focusedNavIndex: homeNavIndex, // Default to Home nav item
            scrollToOffset: announcementSectionOffset,
            isAnnouncementBtnFocused: false,
          ));
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {}
      } else if (currentSectionIndex == sliderSectionIndex) {
        /// Play Btn
        if (state.focusedSliderActionBtnIndex == playSliderActionBtnIndex) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
              focusedSliderActionBtnIndex: notSelectedIndex,
            ));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              focusedSliderActionBtnIndex: notSelectedIndex,
              scrollToOffset: announcementSectionOffset,
              focusedSectionIndex: announcementSectionIndex,
              isAnnouncementBtnFocused: true,
            ));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            emit(state.copyWith(
              focusedSliderActionBtnIndex: bookmarkNavIndex,
              scrollToOffset: sliderSectionOffset,
            ));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {}
        }
        // Bookmark Btn
        else if (state.focusedSliderActionBtnIndex == bookmarkSliderActionBtnIndex) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: sliderNextNavigationBtnIndex,
              focusedSliderActionBtnIndex: notSelectedIndex,
            ));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              focusedSliderActionBtnIndex: notSelectedIndex,
              scrollToOffset: announcementSectionOffset,
              focusedSectionIndex: announcementSectionIndex,
              isAnnouncementBtnFocused: true,
            ));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
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
            ));
          }
          // go back to slider action btns
          else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              focusedSliderActionBtnIndex: playSliderActionBtnIndex,
            ));
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
          // go to movie row section
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              focusedSliderActionBtnIndex: notSelectedIndex,
              scrollToOffset: movieSectionOffset,
              focusedSectionIndex: moviesSectionIndex,
            ));
          }
          // go back to slider action btns
          else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            emit(state.copyWith(
              focusedSlideNavigationBtnIndex: notSelectedIndex,
              focusedSliderActionBtnIndex: playSliderActionBtnIndex,
            ));
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
    }
    //   if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
    //     // Move from Announcement Banner (0) to Slider (1)
    //     if (currentSectionIndex == announcementSectionIndex) {
    //       currentSectionIndex = sliderSectionIndex;
    //       scrollToOffset = sliderSectionOffset; // Scroll down to Slider
    //     }
    //     // Move from Slider (1) to Movies (2)
    //     else if (currentSectionIndex == sliderSectionIndex) {
    //       currentSectionIndex = moviesSectionIndex;
    //       scrollToOffset = movieSectionOffset; // Scroll down to Movies
    //     }
    //     // Move from Movies (2) to Tv Shows (3)
    //     else if (currentSectionIndex == moviesSectionIndex) {
    //       currentSectionIndex = tvShowsSectionIndex;
    //       scrollToOffset = tvShowSectionOffset; // Scroll down to Tv Shows
    //     }
    //   } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
    //     // Move from TV Shows (3) to Movies (2)
    //     if (currentSectionIndex == tvShowsSectionIndex) {
    //       currentSectionIndex = moviesSectionIndex;
    //       scrollToOffset = movieSectionOffset; // Scroll up to Movies
    //     }
    //     // Move from Movies (2) to Slider (1)
    //     else if (currentSectionIndex == moviesSectionIndex) {
    //       currentSectionIndex = sliderSectionIndex;
    //       scrollToOffset = sliderSectionOffset; // Scroll up to Slider
    //     }
    //     // Move from Slider (1) to Announcement Banner (0)
    //     else if (currentSectionIndex == sliderSectionIndex) {
    //       currentSectionIndex = announcementSectionIndex;
    //       scrollToOffset = announcementSectionOffset; // Scroll up to Announcement Banner
    //     }
    //     // Move from Announcement Banner (0) to Nav Bar (Home: 0)
    //     else if (currentSectionIndex == announcementSectionIndex) {
    //       currentSectionIndex = -1;
    //       currentNavIndex = homeNavIndex; // Default to Home nav item
    //       scrollToOffset = 0; // Scroll up to navbar
    //     }
    //   }
    //   // TODO: Handle Left/Right arrows within sections (movie/tv show items)
    //   // TODO: Handle select/enter on movie/tv show items
    // }

    // // Emit the new state if it changed
    // if (currentNavIndex != currentState.focusedNavIndex ||
    //     currentSectionIndex != currentState.focusedSectionIndex ||
    //     scrollToOffset != currentState.scrollToOffset) {
    //   emit(state.copyWith(
    //     focusedNavIndex: currentNavIndex,
    //     focusedSectionIndex: currentSectionIndex,
    //     scrollToOffset: scrollToOffset,
    //     setScrollToNull: scrollToOffset == null,
    //   ));
    // }

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
      isAnnouncementBtnFocused: state.isAnnouncementBtnFocused,
      focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
      focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
    ));

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
        focusedSlideNavigationBtnIndex: state.focusedSlideNavigationBtnIndex,
        focusedSliderActionBtnIndex: state.focusedSliderActionBtnIndex,
      ));
    }
  }
}
