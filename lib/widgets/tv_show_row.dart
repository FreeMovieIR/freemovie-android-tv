import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/model/tv_show.dart';
import 'tv_show_card.dart';

class TvShowRow extends StatefulWidget {
  final String title;
  final List<TvShowModel> tvShows;
  final bool isFocused;
  final Map<int, String>? posterPaths;

  const TvShowRow({
    super.key,
    required this.title,
    required this.tvShows,
    this.isFocused = false,
    this.posterPaths,
  });

  @override
  State<TvShowRow> createState() => _TvShowRowState();
}

class _TvShowRowState extends State<TvShowRow> {
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
  void didUpdateWidget(TvShowRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused != oldWidget.isFocused) {
      _updateFocus();
    }

    if (widget.tvShows.length != oldWidget.tvShows.length) {
      _disposeFocusNodes();
      _setupFocusNodes();
    }
  }

  void _setupFocusNodes() {
    _cardFocusNodes = List.generate(widget.tvShows.length, (_) => FocusNode());

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
      if (_focusedIndex < widget.tvShows.length - 1) {
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

    // Reset the processing flag after a short delay
    Timer(const Duration(milliseconds: 100), () {
      _processingFocusEvent = false;
    });
  }

  void _scrollToFocusedItem() {
    if (_scrollController.hasClients) {
      final itemPosition = _focusedIndex * 200;
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollOffset = itemPosition - (screenWidth / 2) + 75;

      _scrollController.animateTo(
        scrollOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isFocused ? Theme.of(context).colorScheme.primary : Colors.white,
                ),
              ),
              TextButton(
                  onPressed: () {
                    // TODO: navigate to tv shows list
                  },
                  child: Row(
                    children: [
                      Text(
                        'مشاهده همه',
                        style: TextStyle(fontSize: 12),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ))
            ],
          ),
        ),
        SizedBox(
          height: 315,
          child: KeyboardListener(
            focusNode: _rowFocusNode,
            onKeyEvent: _handleKeyEvent,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.tvShows.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final tvShow = widget.tvShows[index];
                final String? posterUrl = widget.posterPaths?[tvShow.id];

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
                  child: TvShowCard(
                    tvShow: tvShow,
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
