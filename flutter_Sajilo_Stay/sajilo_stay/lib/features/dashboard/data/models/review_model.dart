import 'package:sajilo_stay/features/dashboard/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.reviewerName,
    required super.reviewerInitial,
    required super.rating,
    required super.comment,
    required super.date,
  });

  /// Parses a review from `GET /hotels/:id/reviews`.
  /// Backend shape: { _id, rating, comment, createdAt, reviewerName }
  factory ReviewModel.fromApiJson(Map<String, dynamic> json) {
    final name = (json['reviewerName'] as String?)?.trim();
    final displayName = (name == null || name.isEmpty) ? 'Guest' : name;
    final created = DateTime.tryParse(json['createdAt']?.toString() ?? '');

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      reviewerName: displayName,
      reviewerInitial: displayName.substring(0, 1).toUpperCase(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: created != null ? _relative(created) : '',
    );
  }

  static String _relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    }
    return 'Just now';
  }
}
