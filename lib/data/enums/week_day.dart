enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension WeekDayExtension on WeekDay {
  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case WeekDay.monday:
        return 'Lunes';
      case WeekDay.tuesday:
        return 'Martes';
      case WeekDay.wednesday:
        return 'Miércoles';
      case WeekDay.thursday:
        return 'Jueves';
      case WeekDay.friday:
        return 'Viernes';
      case WeekDay.saturday:
        return 'Sábado';
      case WeekDay.sunday:
        return 'Domingo';
    }
  }

  int get dayNumber {
    switch (this) {
      case WeekDay.monday:
        return DateTime.monday;
      case WeekDay.tuesday:
        return DateTime.tuesday;
      case WeekDay.wednesday:
        return DateTime.wednesday;
      case WeekDay.thursday:
        return DateTime.thursday;
      case WeekDay.friday:
        return DateTime.friday;
      case WeekDay.saturday:
        return DateTime.saturday;
      case WeekDay.sunday:
        return DateTime.sunday;
    }
  }
}