part of 'locale_bloc.dart';

@immutable
sealed class LocaleEvent {}

class ChangeLocale extends LocaleEvent {
  final String localeCode;
  ChangeLocale(this.localeCode);
}
