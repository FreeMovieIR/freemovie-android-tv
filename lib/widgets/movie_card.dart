import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freemovie_android_tv/widgets/shimmers.dart';

import '../data/model/movie.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final bool isFocused;
  final VoidCallback? onTap;
  final String? posterUrl;

  const MovieCard({
    super.key,
    required this.movie,
    this.isFocused = false,
    this.onTap,
    this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: isFocused ? 4 / devicePixelRatio : 12 / devicePixelRatio,
          vertical: isFocused ? 4 / devicePixelRatio : 16 / devicePixelRatio,
        ),
        width: isFocused ? 212 / devicePixelRatio : 196 / devicePixelRatio,
        height: isFocused ? 434 / devicePixelRatio : 410 / devicePixelRatio,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 / devicePixelRatio),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withAlpha(125),
                    blurRadius: 16 / devicePixelRatio,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 / devicePixelRatio),
          child: Column(
            children: [
              // Movie poster
              posterUrl == null
                  ? defBoxShim(
                      width: isFocused ? 212 / devicePixelRatio : 196 / devicePixelRatio,
                      height: 348 / devicePixelRatio,
                    )
                  : Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: posterUrl!,
                        fit: BoxFit.cover,
                        width: isFocused ? 212 / devicePixelRatio : 196 / devicePixelRatio,
                        height: 348 / devicePixelRatio,
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

              // Movie info
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie title
                    Text(
                      movie.originalTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.vote.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          movie.releaseDate.substring(0, 4),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // // Focus indicator
              // if (isFocused)
              //   Positioned(
              //     left: 0,
              //     right: 0,
              //     bottom: 0,
              //     top: 0,
              //     child: Container(
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: const Color(0xFF6A1B9A),
              //           width: 3,
              //         ),
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
