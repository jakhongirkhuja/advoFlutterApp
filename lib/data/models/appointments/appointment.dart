class Appointment {
  final int id;
  final String lawyerName;
  final String lawyerTitle;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final String consultationType;
  final String topic;
  final double rating;
  final int experienceYears;
  final int? reviewsCount;
  final String? avatarUrl;
  final String? countdownTime;
  final String? meetingUrl;

  const Appointment({
    required this.id,
    required this.lawyerName,
    required this.lawyerTitle,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.consultationType,
    required this.topic,
    required this.rating,
    required this.experienceYears,
    this.reviewsCount,
    this.avatarUrl,
    this.countdownTime,
    this.meetingUrl,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final lawyer = json['lawyer'] is Map
        ? Map<String, dynamic>.from(json['lawyer'] as Map)
        : const <String, dynamic>{};
    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    return Appointment(
      id: _asInt(json['id']),
      lawyerName: (lawyer['full_name'] ?? json['lawyer_name'] ?? '').toString(),
      lawyerTitle: (lawyer['title'] ?? json['lawyer_title'] ?? 'lawyer')
          .toString(),
      dateLabel: _formatDate(
        (json['date'] ?? json['appointment_date'] ?? '').toString(),
      ),
      timeLabel: (json['start_time'] ?? json['time_label'] ?? '').toString(),
      status: _statusKey(rawStatus),
      consultationType: _consultationKey(
        (json['reception_type'] ?? json['consultation_type'] ?? '').toString(),
      ),
      topic: (json['service_name'] ?? json['topic'] ?? '').toString(),
      rating: _asDouble(lawyer['rating_avg'] ?? json['rating']),
      experienceYears: _asInt(
        lawyer['experience_years'] ?? json['experience_years'],
      ),
      reviewsCount: _asInt(lawyer['rating_count'] ?? json['reviews_count']),
      avatarUrl: (lawyer['avatar_url'] ?? json['avatar_url'])?.toString(),
      countdownTime: _countdown(json['remaining_seconds']),
      meetingUrl: json['meeting_url']?.toString(),
    );
  }

  static String _statusKey(String status) {
    if (status == 'cancelled') return 'filter_cancelled';
    if (status == 'completed') return 'filter_past';
    return 'filter_upcoming';
  }

  static String _consultationKey(String value) {
    return value == 'video' ? 'video_consultation' : 'in_person';
  }

  static String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(parsed.day)}.${two(parsed.month)}.${parsed.year}';
  }

  static String? _countdown(dynamic value) {
    final seconds = _asInt(value);
    if (seconds <= 0) return null;
    final duration = Duration(seconds: seconds);
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(duration.inHours)} : '
        '${two(duration.inMinutes.remainder(60))} : '
        '${two(duration.inSeconds.remainder(60))}';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
