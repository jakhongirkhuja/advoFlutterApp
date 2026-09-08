class ServiceCategory {
  final int id;
  final String title;
  final String iconPath;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.iconPath,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int,
      title: json['title'] as String,
      iconPath: json['icon_path'] as String,
    );
  }
}
