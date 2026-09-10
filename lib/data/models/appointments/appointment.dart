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
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      lawyerName: json['lawyer_name'] as String,
      lawyerTitle: json['lawyer_title'] as String,
      dateLabel: json['date_label'] as String,
      timeLabel: json['time_label'] as String,
      status: json['status'] as String,
      consultationType: json['consultation_type'] as String,
      topic: json['topic'] as String,
      rating: (json['rating'] as num).toDouble(),
      experienceYears: json['experience_years'] as int,
    );
  }
}
