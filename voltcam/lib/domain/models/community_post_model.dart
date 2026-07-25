import 'dart:convert';

class CommunityPostModel {
  final String id;
  final String authorUid;
  final String authorType; // e.g. USER, ADMIN, UTILITY
  final String type; // NEWS, REPORT, QUESTION, MAINTENANCE, ALERT, TIPS
  final String title;
  final String content;
  final String? zoneId;
  final String status; // PUBLISHED, DRAFT, HIDDEN
  final bool isOfficial;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const CommunityPostModel({
    required this.id,
    required this.authorUid,
    required this.authorType,
    required this.type,
    required this.title,
    required this.content,
    this.zoneId,
    required this.status,
    required this.isOfficial,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  CommunityPostModel copyWith({
    String? id,
    String? authorUid,
    String? authorType,
    String? type,
    String? title,
    String? content,
    String? zoneId,
    String? status,
    bool? isOfficial,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorUid: authorUid ?? this.authorUid,
      authorType: authorType ?? this.authorType,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      zoneId: zoneId ?? this.zoneId,
      status: status ?? this.status,
      isOfficial: isOfficial ?? this.isOfficial,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'authorType': authorType,
      'type': type,
      'title': title,
      'content': content,
      'zoneId': zoneId,
      'status': status,
      'isOfficial': isOfficial,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityPostModel.fromMap(Map<String, dynamic> map) {
    return CommunityPostModel(
      id: map['id'] as String? ?? '',
      authorUid: map['authorUid'] as String? ?? '',
      authorType: map['authorType'] as String? ?? 'USER',
      type: map['type'] as String? ?? 'REPORT',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      zoneId: map['zoneId'] as String?,
      status: map['status'] as String? ?? 'PUBLISHED',
      isOfficial: map['isOfficial'] as bool? ?? false,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommunityPostModel.fromJson(String source) =>
      CommunityPostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  String toString() {
    return 'CommunityPostModel(id: $id, authorUid: $authorUid, authorType: $authorType, type: $type, title: $title, content: $content, zoneId: $zoneId, status: $status, isOfficial: $isOfficial, likesCount: $likesCount, commentsCount: $commentsCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommunityPostModel &&
        other.id == id &&
        other.authorUid == authorUid &&
        other.authorType == authorType &&
        other.type == type &&
        other.title == title &&
        other.content == content &&
        other.zoneId == zoneId &&
        other.status == status &&
        other.isOfficial == isOfficial &&
        other.likesCount == likesCount &&
        other.commentsCount == commentsCount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        authorUid.hashCode ^
        authorType.hashCode ^
        type.hashCode ^
        title.hashCode ^
        content.hashCode ^
        zoneId.hashCode ^
        status.hashCode ^
        isOfficial.hashCode ^
        likesCount.hashCode ^
        commentsCount.hashCode ^
        createdAt.hashCode;
  }
}
