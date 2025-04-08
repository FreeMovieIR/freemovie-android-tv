import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freemovie_android_tv/widgets/shimmers.dart';

import '../../gen/assets.gen.dart';
import 'index_and_offset.dart';

/// Model for slider items
class SliderItem {
  final int id;
  final String title;
  final String overview;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final String type; // 'movie' or 'tv'

  SliderItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.type,
  });
}

/// Content slider widget
class ContentSlider extends StatelessWidget {
  final List<SliderItem> items;
  final FocusNode focusNode;
  final bool isFocused;
  final FocusNode playBtnFN;
  final FocusNode bookmarkBtnFN;
  final FocusNode nextBtnFN;
  final FocusNode prevBtnFN;
  final int slideActionFocusIndex;
  final int slideNavigationFocusIndex;
  final int currentSliderIndex;
  final PageController pageController;

  const ContentSlider(
      {super.key,
      required this.items,
      required this.focusNode,
      required this.isFocused,
      required this.playBtnFN,
      required this.bookmarkBtnFN,
      required this.nextBtnFN,
      required this.prevBtnFN,
      required this.slideActionFocusIndex,
      required this.slideNavigationFocusIndex,
      required this.currentSliderIndex,
      required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Page View for slides
          Container(
            decoration: BoxDecoration(
              border: isFocused
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 350,
            child: PageView.builder(
              controller: pageController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildSlide(
                    context: context,
                    item: item,
                    playBtnFN: playBtnFN,
                    bookmarkBtnFN: bookmarkBtnFN,
                    nextBtnFN: nextBtnFN,
                    prevBtnFN: prevBtnFN);
              },
            ),
          ),
          SizedBox(height: 8),
          Row(
            spacing: 12,
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              // Previous button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                child: Focus(
                  focusNode: prevBtnFN,
                  child: Container(
                      height: 24,
                      width: 24,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D293D),
                        border: Border.all(
                            width: 2,
                            color: slideNavigationFocusIndex == sliderPrevNavigationBtnIndex
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Assets.images.icons.rightIcon.svg()),
                ),
              ),
              // Dot indicators
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentSliderIndex == index ? Color(0xFF90A1B9) : Color(0xFF1D293D),
                    ),
                  ),
                ),
              ),

              // Next button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                child: Focus(
                  focusNode: nextBtnFN,
                  child: Container(
                      height: 24,
                      width: 24,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D293D),
                        border: Border.all(
                            width: 2,
                            color: slideNavigationFocusIndex == sliderNextNavigationBtnIndex
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Assets.images.icons.leftIcon.svg()),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSlide({
    required BuildContext context,
    required SliderItem item,
    required FocusNode playBtnFN,
    required FocusNode bookmarkBtnFN,
    required FocusNode nextBtnFN,
    required FocusNode prevBtnFN,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: item.backdropPath != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(item.backdropPath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: item.backdropPath == null
          ? defBoxShim(width: 500, height: 400)
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Release date and score
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(
                        item.releaseDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type == 'movie' ? 'فیلم' : 'سریال',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Overview
                  Text(
                    item.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Focus(
                        focusNode: playBtnFN,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            //TODO
                          },
                          child: Container(
                            height: 36,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(180),
                              border: Border.all(
                                  width: 2,
                                  color: slideActionFocusIndex == playSliderActionBtnIndex
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(Icons.live_tv, size: 20),
                                Text(
                                  'تماشا',
                                  style: TextStyle(
                                    fontWeight: slideActionFocusIndex == playSliderActionBtnIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Focus(
                        focusNode: bookmarkBtnFN,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            //TODO
                          },
                          child: Container(
                            height: 36,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(100),
                              border: Border.all(
                                  width: 2,
                                  color: slideActionFocusIndex == bookmarkSliderActionBtnIndex
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(Icons.bookmark_border_rounded, size: 20),
                                Text(
                                  'نشان کردن',
                                  style: TextStyle(
                                    // fontSize: 10,
                                    fontWeight:
                                        slideActionFocusIndex == bookmarkSliderActionBtnIndex
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
