import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freemovie_android_tv/widgets/shimmers.dart';

import '../data/model/tv_show.dart';

class TvShowCard extends StatelessWidget {
  final TvShowModel tvShow;
  final bool isFocused;
  final VoidCallback? onTap;
  final String? posterUrl;

  const TvShowCard({
    super.key,
    required this.tvShow,
    this.isFocused = false,
    this.onTap,
    this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isFocused ? 5 : 16,
        ),
        width: 140,
        height: isFocused ? 210 : 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withAlpha(125),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              posterUrl == null
                  ? defBoxShim(
                      width: 140,
                      height: isFocused ? 210 : 190,
                    )
                  : Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => defBoxShim(
                          width: 140,
                          height: isFocused ? 210 : 190,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.error, size: 30),
                          ),
                        ),
                      ),
                    ),

              // Gradient overlay for text visibility
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black..withAlpha(200),
                      ],
                    ),
                  ),
                ),
              ),

              // TV show info
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TV show name
                    Text(
                      tvShow.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Rating, year, and seasons
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tvShow.vote.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Text(
                        //   '${tvShow.firstAirDate.substring(0, 4)} • ${tvShow.seasons} ${tvShow.seasons > 1 ? 'فصل' : 'فصل'}',
                        //   style: const TextStyle(
                        //     color: Colors.white70,
                        //     fontSize: 10,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              // Focus indicator
              if (isFocused)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF6A1B9A),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
