import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/model/tv_show.dart';
import 'tv_show_card.dart';

class TvShowRow extends StatefulWidget {
  final String title;
  final List<TvShowModel> tvShows;
  final bool isFocused;

  const TvShowRow({
    super.key,
    required this.title,
    required this.tvShows,
    this.isFocused = false,
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
          height: 220,
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
