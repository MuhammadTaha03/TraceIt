class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Anonymous',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
