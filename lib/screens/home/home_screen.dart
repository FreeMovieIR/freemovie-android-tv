import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/movie.dart';
import '../../data/model/tv_show.dart';
import '../../data/repo/home_repo.dart';
import '../../gen/assets.gen.dart';
import '../../widgets/movie_row.dart';
import '../../widgets/search_field.dart';
import '../../widgets/tv_show_row.dart';
import 'banner.dart';
import 'bloc/home_bloc.dart';
import 'index_and_offset.dart';
import 'slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(homeRepository: homeRepository),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  // Focus nodes for navigation items (6 nav items)
  final List<FocusNode> _navFocusNodes = List.generate(navIndexCount, (_) => FocusNode());

  // Focus nodes for content sections (banner btn, slider, movies, tv shows)
  final List<FocusNode> _sectionFocusNodes = List.generate(sectionIndexCount, (_) => FocusNode());

  final FocusNode playButtonFocus = FocusNode();
  final FocusNode bookmarkButtonFocus = FocusNode();
  final FocusNode nextSliderButtonFocus = FocusNode();
  final FocusNode prevSliderButtonFocus = FocusNode();

  final FocusNode movieShowMoreButtonFocus = FocusNode();
  final FocusNode tvShowShowMoreButtonFocus = FocusNode();

  final ScrollController _scrollController = ScrollController();

  // Create a properly initialized PageController
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadData());

    // Remove the PageController listener as it might cause conflicts with key navigation
    // We'll rely solely on the bloc for slider navigation

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Get initial state from Bloc
        final initialState = context.read<HomeBloc>().state;
        if (initialState.focusedNavIndex >= 0) {
          _navFocusNodes[initialState.focusedNavIndex].requestFocus();
        }
      }
    });

    // Add listeners to focus nodes to update BLoC state
    for (int i = 0; i < _navFocusNodes.length; i++) {
      final index = i;
      _navFocusNodes[i].addListener(() {
        if (_navFocusNodes[index].hasFocus) {
          context.read<HomeBloc>().add(HomeNavFocused(index));
        }
      });
    }
    for (int i = 0; i < _sectionFocusNodes.length; i++) {
      final index = i;
      _sectionFocusNodes[i].addListener(() {
        if (_sectionFocusNodes[index].hasFocus) {
          context.read<HomeBloc>().add(HomeSectionFocused(index));
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in _navFocusNodes) {
      node.dispose();
    }
    for (var node in _sectionFocusNodes) {
      node.dispose();
    }
    playButtonFocus.dispose();
    bookmarkButtonFocus.dispose();
    nextSliderButtonFocus.dispose();
    prevSliderButtonFocus.dispose();
    movieShowMoreButtonFocus.dispose();
    tvShowShowMoreButtonFocus.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, BuildContext context) {
    // Only process key down events to avoid duplicate processing
    if (event is KeyDownEvent) {
      context.read<HomeBloc>().add(HomeKeyPressed(event.logicalKey));
    }
  }

  // Make scrolling more reliable
  void _scrollToOffset(double offset) {
    if (!_scrollController.hasClients) return;

    // Directly jump to the position for more reliability
    if (offset == sliderSectionOffset) {
      // For slider section, ensure visibility with a slight buffer
      _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
    } else {
      // For other sections, use smooth animation
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // Handle navigation focus
        if (state.focusedNavIndex >= 0) {
          if (!_navFocusNodes[state.focusedNavIndex].hasFocus) {
            _navFocusNodes[state.focusedNavIndex].requestFocus();
          }
        } else if (state.focusedSectionIndex >= 0) {
          if (!_sectionFocusNodes[state.focusedSectionIndex].hasFocus) {
            _sectionFocusNodes[state.focusedSectionIndex].requestFocus();
          }
        }

        // Handle slider action buttons focus
        if (state.focusedSliderActionBtnIndex == playSliderActionBtnIndex) {
          if (!playButtonFocus.hasFocus) {
            playButtonFocus.requestFocus();
          }
        } else if (state.focusedSliderActionBtnIndex == bookmarkSliderActionBtnIndex) {
          if (!bookmarkButtonFocus.hasFocus) {
            bookmarkButtonFocus.requestFocus();
          }
        }

        // Handle slider navigation buttons focus
        if (state.focusedSlideNavigationBtnIndex == sliderNextNavigationBtnIndex) {
          if (!nextSliderButtonFocus.hasFocus) {
            nextSliderButtonFocus.requestFocus();
          }
        } else if (state.focusedSlideNavigationBtnIndex == sliderPrevNavigationBtnIndex) {
          if (!prevSliderButtonFocus.hasFocus) {
            prevSliderButtonFocus.requestFocus();
          }
        }

        // Ensure scrolling happens for any slider or nav button focus
        if (state.scrollToOffset != null) {
          // Specifically handle slider section scrolling for buttons
          bool isSliderButtonFocused = (state.focusedSectionIndex == sliderSectionIndex &&
              (state.focusedSliderActionBtnIndex >= 0 ||
                  state.focusedSlideNavigationBtnIndex >= 0));

          if (isSliderButtonFocused && state.scrollToOffset != sliderSectionOffset) {
            // Force slider section scrolling when any slider button is focused
            _scrollToOffset(sliderSectionOffset);
          } else {
            _scrollToOffset(state.scrollToOffset!);
          }
        }

        // Handle slider page changes
        if ((state is HomeLoaded ||
            state is HomeTvShowsLoaded ||
            state is HomeSlidesLoaded ||
            state is HomeMoviesLoaded)) {
          if (_pageController.hasClients) {
            // Ensure the slider animates to the correct page
            final targetPage = state.sliderIndex;
            final currentPage = _pageController.page?.round() ?? 0;

            if (targetPage != currentPage) {
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        }

        // Handle "show more" button focus
        if (state.isShowMoreMoviesFocused) {
          if (!movieShowMoreButtonFocus.hasFocus) {
            movieShowMoreButtonFocus.requestFocus();
          }
        } else if (state.isShowMoreTvShowsFocused) {
          if (!tvShowShowMoreButtonFocus.hasFocus) {
            tvShowShowMoreButtonFocus.requestFocus();
          }
        }
      },
      // Add buildWhen for better performance (optional but recommended)
      buildWhen: (previous, current) {
        // Rebuild only when relevant data changes, not just focus/scroll
        return current is! HomeInitial; // Example: avoid rebuilding on initial
        // Add more specific conditions based on what _buildBody uses
      },
      builder: (context, homeState) {
        return Scaffold(
          body: KeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKeyEvent: (event) => _handleKeyEvent(event, context),
            child: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _buildBody(context, homeState),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState homeState) {
    List<MovieModel> latestMovies = [];
    List<TvShowModel> popularTvShows = [];
    Map<int, String> moviePosters = {};
    Map<int, String> tvShowPosters = {};

    // Assign data based on the actual state type
    if (homeState is HomeMoviesLoaded) {
      latestMovies = homeState.trendingMovies;
    } else if (homeState is HomeTvShowsLoaded) {
      latestMovies = homeState.trendingMovies;
      popularTvShows = homeState.trendingTvShows;
      moviePosters = homeState.moviePosters;
    } else if (homeState is HomeLoaded) {
      latestMovies = homeState.trendingMovies;
      popularTvShows = homeState.trendingTvShows;
      moviePosters = homeState.moviePosters;
      tvShowPosters = homeState.tvShowPosters;
    }

    if (homeState is HomeLoading || homeState is HomeInitial) {
      return const Center(child: CircularProgressIndicator()); //todo: create proper shimmer here
    } else if (homeState is HomeError) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('خطا: ${homeState.errorMessage ?? "خطای ناشناخته!"}'),
          TextButton(
              autofocus: true,
              onPressed: () {
                BlocProvider.of<HomeBloc>(context).add(HomeLoadData());
              },
              child: Text('تلاش مجدد!'))
        ],
      ));
    } else {
      if (homeState is HomeLoaded && latestMovies.isEmpty && popularTvShows.isEmpty) {
        return const Center(child: Text('محتوایی برای نمایش وجود ندارد.'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildNavigationItem(context, 'خانه',
                    isFocused: homeState.focusedNavIndex == homeNavIndex,
                    isSelected: true,
                    focusNode: _navFocusNodes[homeNavIndex],
                    index: homeNavIndex),
                _buildNavigationItem(context, 'نشان‌شده‌ها',
                    isFocused: homeState.focusedNavIndex == bookmarkNavIndex,
                    isSelected: false,
                    focusNode: _navFocusNodes[bookmarkNavIndex],
                    index: bookmarkNavIndex),
                _buildNavigationItem(context, 'توسعه‌دهندگان',
                    isFocused: homeState.focusedNavIndex == developersNavIndex,
                    isSelected: false,
                    focusNode: _navFocusNodes[developersNavIndex],
                    index: developersNavIndex),
                _buildNavigationItem(context, 'درباره ما',
                    isFocused: homeState.focusedNavIndex == aboutNavIndex,
                    isSelected: false,
                    focusNode: _navFocusNodes[aboutNavIndex],
                    index: aboutNavIndex),
                _buildNavigationItem(context, 'تنظیمات',
                    isFocused: homeState.focusedNavIndex == settingNavIndex,
                    isSelected: false,
                    focusNode: _navFocusNodes[settingNavIndex],
                    index: settingNavIndex),
                Spacer(),
                SearchField(
                    isFocused: homeState.focusedNavIndex == searchNavIndex,
                    focusNode: _navFocusNodes[searchNavIndex],
                    index: searchNavIndex),
                Spacer(),
                Assets.images.logo.image(height: 38),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                /// Announcement banner
                AnnouncementBanner(
                  focusNode: _sectionFocusNodes.length > sectionIndexCount
                      ? _sectionFocusNodes[announcementSectionIndex]
                      : FocusNode(),
                  isFocused: homeState.focusedSectionIndex == announcementSectionIndex,
                ),

                /// Featured Content Slider
                const SizedBox(height: 24),
                ContentSlider(
                  items: homeState.sliderItems,
                  focusNode: _sectionFocusNodes.length > sectionIndexCount
                      ? _sectionFocusNodes[sliderSectionIndex]
                      : FocusNode(),
                  isFocused: homeState.focusedSectionIndex == sliderSectionIndex,
                  playBtnFN: playButtonFocus,
                  bookmarkBtnFN: bookmarkButtonFocus,
                  nextBtnFN: nextSliderButtonFocus,
                  prevBtnFN: prevSliderButtonFocus,
                  slideActionFocusIndex: homeState.focusedSliderActionBtnIndex,
                  slideNavigationFocusIndex: homeState.focusedSlideNavigationBtnIndex,
                  currentSliderIndex: homeState.sliderIndex,
                  pageController: _pageController,
                  onPageChanged: (index) {
                    // Report the page change back to the Bloc
                    if (index != homeState.sliderIndex) {
                      context.read<HomeBloc>().add(HomeSliderIndexChanged(index));
                    }
                  },
                ),

                const SizedBox(height: 24),

                /// Latest Movies Section
                if (latestMovies.isNotEmpty)
                  _buildContentSection(
                    context,
                    title: 'جدیدترین فیلم‌ها',
                    focusNode: _sectionFocusNodes[moviesSectionIndex],
                    isFocused: homeState.focusedSectionIndex == moviesSectionIndex,
                    isBtnFocused: homeState.isShowMoreMoviesFocused,
                    showMoreBtnFN: movieShowMoreButtonFocus,
                    child: MovieRow(
                      movies: latestMovies,
                      posterPaths: moviePosters,
                      // isFocused: homeState.focusedSectionIndex == moviesSectionIndex,
                      isFocused: homeState.isMovieItemsFocused,
                    ),
                  ),

                /// Popular TV Shows Section
                if (popularTvShows.isNotEmpty &&
                    (homeState is HomeTvShowsLoaded || homeState is HomeLoaded))
                  _buildContentSection(
                    context,
                    title: 'سریال‌های محبوب',
                    focusNode: _sectionFocusNodes[tvShowsSectionIndex],
                    isFocused: homeState.focusedSectionIndex == tvShowsSectionIndex,
                    isBtnFocused: homeState.isShowMoreTvShowsFocused,
                    showMoreBtnFN: tvShowShowMoreButtonFocus,
                    child: TvShowRow(
                      tvShows: popularTvShows,
                      posterPaths: tvShowPosters,
                      // isFocused: homeState.focusedSectionIndex == tvShowsSectionIndex,
                      isFocused: homeState.isTvShowItemsFocused,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title, {
    required bool isFocused,
    required bool isSelected,
    required FocusNode focusNode,
    required int index,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          border: Border.all(
              width: 1,
              color: isFocused ? Theme.of(context).colorScheme.primary : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: isFocused || isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context, {
    required FocusNode focusNode,
    required bool isFocused,
    required bool isBtnFocused,
    required Widget child,
    required String title,
    required FocusNode showMoreBtnFN,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Container(
        decoration: BoxDecoration(
          border:
              isFocused ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isFocused ? Theme.of(context).colorScheme.primary : Colors.white,
                    ),
                  ),
                  Focus(
                    focusNode: showMoreBtnFN,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isBtnFocused
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                            width: 1,
                            color: isBtnFocused
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'مشاهده همه',
                        style: TextStyle(
                          color: isBtnFocused ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: isBtnFocused ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
