class Claim {
  final String id;
  final String postId;
  final String claimantId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  Claim({
    required this.id,
    required this.postId,
    required this.claimantId,
    required this.status,
    required this.createdAt,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      claimantId: json['claimant_id'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'claimant_id': claimantId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Claim copyWith({
    String? id,
    String? postId,
    String? claimantId,
    String? status,
    DateTime? createdAt,
  }) {
    return Claim(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      claimantId: claimantId ?? this.claimantId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
