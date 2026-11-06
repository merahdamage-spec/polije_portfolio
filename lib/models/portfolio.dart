class Portfolio {
  final int? id;
  final String title;
  final String category;
  final String technology;
  final String description;
  final String? imagePath;
  final String createdAt;

  const Portfolio({
    this.id,
    required this.title,
    required this.category,
    required this.technology,
    required this.description,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'category': category,
        'technology': technology,
        'description': description,
        'imagePath': imagePath,
        'createdAt': createdAt,
      };

  factory Portfolio.fromMap(Map<String, dynamic> m) => Portfolio(
        id: m['id'] == null ? null : int.parse('${m['id']}'),
        title: m['title'] as String,
        category: m['category'] as String,
        technology: m['technology'] as String,
        description: m['description'] as String,
        imagePath: m['imagePath'] as String?,
        createdAt: (m['createdAt'] ?? '') as String,
      );
}
