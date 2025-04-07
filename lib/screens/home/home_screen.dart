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

  // Declare PageController
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadData());

    // Initialize PageController
    _pageController = PageController();

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
    _scrollController.dispose();
    // Dispose PageController
    _pageController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is KeyDownEvent || event is KeyUpEvent) {
      context.read<HomeBloc>().add(HomeKeyPressed(event.logicalKey));
    }
  }

  void _scrollToOffset(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      // Add listenWhen for better performance (optional but recommended)
      listenWhen: (previous, current) {
        return previous.scrollToOffset != current.scrollToOffset ||
            previous.focusedNavIndex != current.focusedNavIndex ||
            previous.focusedSectionIndex != current.focusedSectionIndex ||
            previous.sliderIndex != current.sliderIndex;
      },
      listener: (context, state) {
        // Request focus based on BLoC state
        if (state.focusedNavIndex >= 0) {
          if (!_navFocusNodes[state.focusedNavIndex].hasFocus) {
            _navFocusNodes[state.focusedNavIndex].requestFocus();
          }
        } else if (state.focusedSectionIndex >= 0) {
          if (!_sectionFocusNodes[state.focusedSectionIndex].hasFocus) {
            _sectionFocusNodes[state.focusedSectionIndex].requestFocus();
          }
        }

        // Handle scrolling based on BLoC state
        if (state.scrollToOffset != null) {
          _scrollToOffset(state.scrollToOffset!);
        }

        // Animate slider based on BLoC state's sliderIndex
        if ((state is HomeLoaded ||
            state is HomeTvShowsLoaded ||
            state is HomeSlidesLoaded ||
            state is HomeMoviesLoaded)) {
          final currentSliderIndex = state.sliderIndex;
          if (_pageController.hasClients && _pageController.page?.round() != currentSliderIndex) {
            _pageController.animateToPage(
              currentSliderIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
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
                    isFocused: homeState.focusedNavIndex == 0,
                    isSelected: true,
                    focusNode: _navFocusNodes[0],
                    index: 0),
                _buildNavigationItem(context, 'نشان‌شده‌ها',
                    isFocused: homeState.focusedNavIndex == 1,
                    isSelected: false,
                    focusNode: _navFocusNodes[1],
                    index: 1),
                _buildNavigationItem(context, 'توسعه‌دهندگان',
                    isFocused: homeState.focusedNavIndex == 2,
                    isSelected: false,
                    focusNode: _navFocusNodes[2],
                    index: 2),
                _buildNavigationItem(context, 'درباره ما',
                    isFocused: homeState.focusedNavIndex == 3,
                    isSelected: false,
                    focusNode: _navFocusNodes[3],
                    index: 3),
                _buildNavigationItem(context, 'تنظیمات',
                    isFocused: homeState.focusedNavIndex == 4,
                    isSelected: false,
                    focusNode: _navFocusNodes[4],
                    index: 4),
                Spacer(),
                SearchField(
                    isFocused: homeState.focusedNavIndex == 5,
                    focusNode: _navFocusNodes[5],
                    index: 5),
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
                  focusNode: _sectionFocusNodes.length > 4 ? _sectionFocusNodes[0] : FocusNode(),
                  isFocused: homeState.focusedSectionIndex == 0,
                ),

                /// Featured Content Slider
                const SizedBox(height: 24),
                ContentSlider(
                  items: homeState.sliderItems,
                  focusNode: _sectionFocusNodes.length > 4 ? _sectionFocusNodes[1] : FocusNode(),
                  isFocused: homeState.focusedSectionIndex == 1,
                  playBtnFN: playButtonFocus,
                  bookmarkBtnFN: bookmarkButtonFocus,
                  nextBtnFN: nextSliderButtonFocus,
                  prevBtnFN: prevSliderButtonFocus,
                  slideActionFocusIndex: homeState.focusedSliderActionBtnIndex,
                  slideNavigationFocusIndex: homeState.focusedSlideNavigationBtnIndex,
                  currentSliderIndex: homeState.sliderIndex,
                  pageController: _pageController,
                ),
                const SizedBox(height: 24),

                /// Latest Movies Section
                if (latestMovies.isNotEmpty)
                  _buildContentSection(
                    context,
                    focusNode: _sectionFocusNodes[2],
                    isFocused: homeState.focusedSectionIndex == 2,
                    child: MovieRow(
                      title: 'جدیدترین فیلم‌ها',
                      movies: latestMovies,
                      posterPaths: moviePosters,
                      isFocused: homeState.focusedSectionIndex == 2,
                    ),
                  ),

                /// Popular TV Shows Section
                if (popularTvShows.isNotEmpty &&
                    (homeState is HomeTvShowsLoaded || homeState is HomeLoaded))
                  _buildContentSection(
                    context,
                    focusNode: _sectionFocusNodes[3],
                    isFocused: homeState.focusedSectionIndex == 3,
                    child: TvShowRow(
                      title: 'سریال‌های محبوب',
                      tvShows: popularTvShows,
                      posterPaths: tvShowPosters,
                      isFocused: homeState.focusedSectionIndex == 3,
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
    required Widget child,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Container(
        decoration: BoxDecoration(
          border:
              isFocused ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
