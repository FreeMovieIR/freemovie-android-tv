part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeLoadData extends HomeEvent {}

final class HomeKeyPressed extends HomeEvent {
  final LogicalKeyboardKey logicalKey;

  const HomeKeyPressed(this.logicalKey);

  @override
  List<Object?> get props => [logicalKey];
}

final class HomeNavFocused extends HomeEvent {
  final int navIndex;

  const HomeNavFocused(this.navIndex);

  @override
  List<Object?> get props => [navIndex];
}

final class HomeSectionFocused extends HomeEvent {
  final int sectionIndex;

  const HomeSectionFocused(this.sectionIndex);

  @override
  List<Object?> get props => [sectionIndex];
}
