import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/model/movie.dart';
import 'movie_card.dart';

class MovieRow extends StatefulWidget {
  final String title;
  final List<MovieModel> movies;
  final bool isFocused;
  final Map<int, String>? posterPaths;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    this.isFocused = false,
    this.posterPaths,
  });

  @override
  State<MovieRow> createState() => _MovieRowState();
}

class _MovieRowState extends State<MovieRow> {
  // The index of the currently focused movie card
  int _focusedIndex = 0;

  // Flag to prevent multiple focus events
  bool _processingFocusEvent = false;

  late List<FocusNode> _cardFocusNodes;
  final ScrollController _scrollController = ScrollController();

  // Parent focus node for the entire row
  final FocusNode _rowFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  @override
  void didUpdateWidget(MovieRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If focused state changes, update focus nodes
    if (widget.isFocused != oldWidget.isFocused) {
      _updateFocus();
    }

    // Recreate focus nodes if movie list changes
    if (widget.movies.length != oldWidget.movies.length) {
      _disposeFocusNodes();
      _setupFocusNodes();
    }
  }

  void _setupFocusNodes() {
    _cardFocusNodes = List.generate(widget.movies.length, (_) => FocusNode());

    // Add listeners to focus nodes to prevent auto-focus issues
    for (int i = 0; i < _cardFocusNodes.length; i++) {
      final index = i;
      _cardFocusNodes[i].addListener(() {
        if (_cardFocusNodes[index].hasFocus && !_processingFocusEvent && widget.isFocused) {
          setState(() {
            _focusedIndex = index;
          });
        }
      });
    }
  }

  void _disposeFocusNodes() {
    for (var node in _cardFocusNodes) {
      node.dispose();
    }
  }

  void _updateFocus() {
    if (widget.isFocused) {
      // When row becomes focused, focus the current card
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_cardFocusNodes.isNotEmpty) {
          _processingFocusEvent = true;
          _cardFocusNodes[_focusedIndex].requestFocus();
          Timer(const Duration(milliseconds: 100), () {
            _processingFocusEvent = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rowFocusNode.dispose();
    _disposeFocusNodes();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!widget.isFocused || event is! KeyDownEvent || _processingFocusEvent) return;

    _processingFocusEvent = true;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_focusedIndex < widget.movies.length - 1) {
        setState(() {
          _focusedIndex++;
        });
        _cardFocusNodes[_focusedIndex].requestFocus();
        _scrollToFocusedItem();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_focusedIndex > 0) {
        setState(() {
          _focusedIndex--;
        });
        _cardFocusNodes[_focusedIndex].requestFocus();
        _scrollToFocusedItem();
      }
    }

    Timer(const Duration(milliseconds: 100), () {
      _processingFocusEvent = false;
    });
  }

  void _scrollToFocusedItem() {
    if (_scrollController.hasClients) {
      final itemPosition = _focusedIndex * 150.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollOffset = itemPosition - (screenWidth / 2) + 75;

      _scrollController.animateTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 16, top: 24),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.isFocused ? const Color(0xFF6A1B9A) : Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 434 / devicePixelRatio,
          child: KeyboardListener(
            focusNode: _rowFocusNode,
            onKeyEvent: _handleKeyEvent,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                final String? posterUrl = widget.posterPaths?[movie.id];

                return Focus(
                  focusNode: _cardFocusNodes[index],
                  canRequestFocus: widget.isFocused,
                  onFocusChange: (hasFocus) {
                    if (hasFocus && widget.isFocused && !_processingFocusEvent) {
                      _processingFocusEvent = true;
                      setState(() {
                        _focusedIndex = index;
                      });
                      _scrollToFocusedItem();
                      Timer(const Duration(milliseconds: 100), () {
                        _processingFocusEvent = false;
                      });
                    }
                  },
                  child: MovieCard(
                    movie: movie,
                    posterUrl: posterUrl,
                    isFocused: widget.isFocused && index == _focusedIndex,
                    onTap: () {
                      _processingFocusEvent = true;
                      setState(() {
                        _focusedIndex = index;
                      });
                      _cardFocusNodes[index].requestFocus();
                      Timer(const Duration(milliseconds: 100), () {
                        _processingFocusEvent = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
