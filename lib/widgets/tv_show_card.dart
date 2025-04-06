import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/model/tv_show.dart';
import 'shimmers.dart';

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
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: _getWidth(),
        height: isFocused ? 310 : 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isFocused
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                )
              : null,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: posterUrl == null
                  ? defBoxShim(
                      width: _getWidth(),
                      height: _getHeight(),
                    )
                  : CachedNetworkImage(
                      imageUrl: posterUrl!,
                      fit: BoxFit.cover,
                      width: _getWidth(),
                      height: _getHeight(),
                      placeholder: (context, url) => defBoxShim(
                        width: _getWidth(),
                        height: _getHeight(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.error, size: 30),
                        ),
                      ),
                    ),
            ),

            // TV show info
            Padding(
              padding: isFocused ? EdgeInsets.only(left: 4) : EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: isFocused ? 6 : 8),
                  // TV show name
                  Text(
                    tvShow.originalTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tvShow.vote.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Container(
                          height: 3,
                          width: 3,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white60)),
                      Text(
                        tvShow.releaseDate.substring(0, 4),
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
          ],
        ),
      ),
    );
  }

  double _getWidth() => isFocused ? 170 : 160;

  double _getHeight() => isFocused ? 250 : 235;
}
