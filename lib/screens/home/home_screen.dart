import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freemovie_android_tv/widgets/field.dart';

import '../../data/model/movie.dart';
import '../../data/model/tv_show.dart';
import '../../data/repo/home_repo.dart';
import '../../gen/assets.gen.dart';
import '../../widgets/movie_row.dart';
import '../../widgets/tv_show_row.dart';
import '../settings/settings_screen.dart';
import 'bloc/home_bloc.dart';

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
  final List<FocusNode> _navFocusNodes = List.generate(6, (_) => FocusNode());

  // Focus nodes for content sections (2 sections: movies, tv shows)
  final List<FocusNode> _sectionFocusNodes = List.generate(2, (_) => FocusNode());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadData());

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
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is KeyDownEvent) {
      context.read<HomeBloc>().add(HomeKeyPressed(event.logicalKey));
    }
  }

  void _scrollToOffset(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
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
      return const Center(child: CircularProgressIndicator());
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
          // Header Row
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
                Field(
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
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 72),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Assets.images.icons.infoFill.svg(),
                      SizedBox(width: 12),
                      Text('بیانیه سلب مسئولیت', style: TextStyle(fontSize: 12)),
                      Container(
                          height: 3,
                          width: 3,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white60)),
                      Flexible(
                        child: Text(
                            ' این وب‌سایت فقط اطلاعات فیلم و سریال را نمایش می‌دهد و هیچ محتوایی را میزبانی نمی‌کند. اطلاعات از APIهای عمومی و لینک‌های دانلود از الماس مووی دریافت می‌شود',
                            style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Row(
                            spacing: 8,
                            children: [
                              Text('اطلاعات بیشتر', style: TextStyle(fontSize: 11)),
                              Icon(Icons.chevron_right)
                            ],
                          ))
                    ],
                  ),
                ),

                // Latest Movies Section
                if (latestMovies.isNotEmpty)
                  _buildContentSection(
                    context,
                    focusNode: _sectionFocusNodes[0],
                    isFocused: homeState.focusedSectionIndex == 0,
                    child: MovieRow(
                      title: 'جدیدترین فیلم‌ها',
                      movies: latestMovies,
                      posterPaths: moviePosters,
                      isFocused: homeState.focusedSectionIndex == 0,
                    ),
                  ),
                // Popular TV Shows Section
                if (popularTvShows.isNotEmpty &&
                    (homeState is HomeTvShowsLoaded || homeState is HomeLoaded))
                  _buildContentSection(
                    context,
                    focusNode: _sectionFocusNodes[1],
                    isFocused: homeState.focusedSectionIndex == 1,
                    child: TvShowRow(
                      title: 'سریال‌های محبوب',
                      tvShows: popularTvShows,
                      posterPaths: tvShowPosters,
                      isFocused: homeState.focusedSectionIndex == 1,
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Handle navigation based on index
        // todo: move to bloc
        if (index == 4) {
          // Navigate to settings
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        }
        // Handle other navigation items...
      },
      child: Focus(
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
