class DailyLogEntry {
  final DateTime date;
  bool worked;
  String location;
  String description;
  String ticketNumber;
  double hours;
  double kmsRegular;
  double kmsTowing;
  double kmsRegRate;
  double kmsTowRate;
  double truckRate;
  double otherCharges;

  DailyLogEntry({
    required this.date,
    this.worked = true,
    this.location = '',
    this.description = '',
    this.ticketNumber = '',
    this.hours = 0,
    this.kmsRegular = 0,
    this.kmsTowing = 0,
    this.kmsRegRate = 0,
    this.kmsTowRate = 0,
    this.truckRate = 0,
    this.otherCharges = 0,
  });

  DailyLogEntry copyWith({
    DateTime? date,
    bool? worked,
    String? location,
    String? description,
    String? ticketNumber,
    double? hours,
    double? kmsRegular,
    double? kmsTowing,
    double? kmsRegRate,
    double? kmsTowRate,
    double? truckRate,
    double? otherCharges,
  }) => DailyLogEntry(
    date: date ?? this.date,
    worked: worked ?? this.worked,
    location: location ?? this.location,
    description: description ?? this.description,
    ticketNumber: ticketNumber ?? this.ticketNumber,
    hours: hours ?? this.hours,
    kmsRegular: kmsRegular ?? this.kmsRegular,
    kmsTowing: kmsTowing ?? this.kmsTowing,
    kmsRegRate: kmsRegRate ?? this.kmsRegRate,
    kmsTowRate: kmsTowRate ?? this.kmsTowRate,
    truckRate: truckRate ?? this.truckRate,
    otherCharges: otherCharges ?? this.otherCharges,
  );
}