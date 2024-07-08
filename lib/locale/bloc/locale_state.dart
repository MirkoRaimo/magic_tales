part of 'locale_bloc.dart';

@immutable
sealed class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}

final class LocaleInitial extends LocaleState {
  const LocaleInitial() : super(const Locale('en'));
}

final class LocaleChanged extends LocaleState {
  const LocaleChanged(super.locale);
}
