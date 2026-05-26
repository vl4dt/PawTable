import 'dart:math';
import 'package:flutter/material.dart';

/// Swipe action — defines a single action triggered by swiping
class SwipeAction {
  /// Icon for the action
  final IconData icon;

  /// Background color for the action
  final Color backgroundColor;

  /// Label text (shown on tap)
  final String label;

  /// Callback when action is triggered
  final VoidCallback onTap;

  const SwipeAction({
    required this.icon,
    required this.backgroundColor,
    this.label = '',
    required this.onTap,
  });
}

/// Swipeable list item — supports horizontal swipe to reveal actions
///
/// Usage:
/// ```dart
/// SwipeableItem(
///   child: MyListItem(),
///   actions: [
///     SwipeAction(
///       icon: Icons.delete,
///       backgroundColor: Colors.red,
///       label: 'Delete',
///       onTap: () => deleteItem(),
///     ),
///     SwipeAction(
///       icon: Icons.archive,
///       backgroundColor: Colors.blue,
///       label: 'Archive',
///       onTap: () => archiveItem(),
///     ),
///   ],
/// )
/// ```
class SwipeableItem extends StatefulWidget {
  /// The content widget
  final Widget child;

  /// List of swipe actions (shown on left and right swipes)
  final List<SwipeAction> leftActions;

  /// List of swipe actions (shown on right swipe)
  final List<SwipeAction> rightActions;

  /// Sensitivity threshold for triggering actions (0.0 to 1.0)
  final double sensitivity;

  /// Callback when item is tapped (when no swipe happened)
  final VoidCallback? onTap;

  /// Callback when swipe is dismissed without action
  final VoidCallback? onDismiss;

  const SwipeableItem({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.sensitivity = 0.4,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<SwipeableItem> createState() => _SwipeableItemState();
}

class _SwipeableItemState extends State<SwipeableItem>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isDragging = false;
  double? _startDragOffset;
  final double _threshold = 8; // Minimum drag distance to start tracking

  @override
  Widget build(BuildContext context) {
    final leftActions = widget.leftActions;
    final rightActions = widget.rightActions;
    final maxActionWidth = _getMaxActionWidth(leftActions, rightActions);

    return SizedBox(
      height: _getPreferredSize(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background actions (visible when swiped)
          if (_dragOffset.abs() > _threshold)
            Positioned.fill(
              child: _buildActionBackground(
                context,
                actions: _dragOffset < 0 ? leftActions : rightActions,
                side: _dragOffset < 0 ? SwipeSide.left : SwipeSide.right,
                maxWidth: maxActionWidth,
              ),
            ),

          // Draggable content
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: widget.onTap,
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startDragOffset = details.globalPosition.dx;
    _isDragging = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startDragOffset == null) return;

    final dx = details.globalPosition.dx - _startDragOffset!;

    // Only start tracking after threshold
    if (!_isDragging && dx.abs() < _threshold) return;

    if (!_isDragging) {
      _isDragging = true;
    }

    setState(() {
      _dragOffset = dx.clamp(
        -_getMaxActionWidth(widget.leftActions, widget.rightActions),
        _getMaxActionWidth(widget.leftActions, widget.rightActions),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final maxActionWidth = _getMaxActionWidth(
      widget.leftActions,
      widget.rightActions,
    );
    final threshold = maxActionWidth * widget.sensitivity;

    if (_dragOffset.abs() >= threshold) {
      // Trigger the action
      final actions =
          _dragOffset < 0 ? widget.leftActions : widget.rightActions;
      if (actions.isNotEmpty) {
        actions.first.onTap();
      }
    }

    _animateBack();
    _isDragging = false;
    _startDragOffset = null;
  }

  AnimationController? _controller;

  void _animateBack() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragOffset = 0;
        });
        _controller?.dispose();
        _controller = null;
      }
    });

    _controller!.forward();
  }

  double _getMaxActionWidth(
      List<SwipeAction> left, List<SwipeAction> right) {
    final allActions = [...left, ...right];
    if (allActions.isEmpty) return 0;

    // Approximate action width based on icon + label
    double maxW = 0;
    for (final action in allActions) {
      final labelWidth = action.label.isEmpty
          ? 48
          : action.label.length * 12.0;
      maxW = max(maxW, 48 + labelWidth + 16);
    }
    return maxW;
  }

  double _getPreferredSize(BuildContext context) {
    final height = 56.0;
    return height;
  }

  Widget _buildActionBackground(
    BuildContext context, {
    required List<SwipeAction> actions,
    required SwipeSide side,
    required double maxWidth,
  }) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: side == SwipeSide.left
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: actions.map((action) {
          return Expanded(
            child: _ActionButton(
              action: action,
              maxWidth: maxWidth,
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum SwipeSide { left, right }

class _ActionButton extends StatelessWidget {
  final SwipeAction action;
  final double maxWidth;

  const _ActionButton({
    required this.action,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        color: action.backgroundColor,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              color: Colors.white,
              size: 20,
            ),
            if (action.label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Swipeable list builder — for building lists with swipe actions
class SwipeableList extends StatelessWidget {
  final List<SwipeAction> Function(int) leftActionsBuilder;
  final List<SwipeAction> Function(int) rightActionsBuilder;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final void Function(int)? onItemTap;

  const SwipeableList({
    super.key,
    required this.itemCount,
    required this.leftActionsBuilder,
    required this.rightActionsBuilder,
    required this.itemBuilder,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final child = itemBuilder(context, index);
        final leftActions = leftActionsBuilder(index);
        final rightActions = rightActionsBuilder(index);

        if (leftActions.isEmpty && rightActions.isEmpty) {
          return child;
        }

        return SwipeableItem(
          leftActions: leftActions,
          rightActions: rightActions,
          onTap: onItemTap != null ? () => onItemTap!(index) : null,
          child: child,
        );
      },
    );
  }
}
