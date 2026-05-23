class Post {
  final String id;
  final String userId;
  final String type; // 'lost' or 'found'
  final String title;
  final String description;
  final String location;
  final String? imageUrl;
  final String category;
  final String status; // 'open' or 'resolved'
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
    required this.category,
    required this.status,
    required this.createdAt,
  });

  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  bool get isResolved => status == 'resolved';

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'lost',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? 'Other',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'category': category,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    String? category,
    String? status,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
