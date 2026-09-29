import 'dart:convert';

/// Represents a captured item in SnapNote AI.
class CaptureItem {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imagePath; // Path to original screenshot stored locally

  // AI & Processing Metadata
  final String category; // note, event, reminder, task, read_later, idea, shopping, code, place
  final String originalCategory; // Preserved original AI category
  final String title;
  final String summary;
  final String content;
  final List<String> tags;
  final double confidence;
  final bool isUncertain;
  final String status; // 'pending_ai', 'processing', 'completed', 'failed', 'needs_review'
  final String? errorMessage;
  final String? aiJsonPayload; // Raw AI json response string for history/debugging

  // Specific Structured Fields
  final String? date; // YYYY-MM-DD
  final String? time; // HH:mm
  final String? endDate;
  final String? endTime;
  final String? location;
  final String? address;
  final String? city;
  final String? country;
  final String? url;
  final List<String> people;
  final String? productName;
  final String? price;
  final String? currency;
  final String? store;
  final bool isPurchased;
  final String? programmingLanguage;
  final String? priority; // 'low', 'medium', 'high'
  final String? dueDate;
  final bool isCompleted;
  final bool isRead;

  CaptureItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
    required this.category,
    required this.originalCategory,
    required this.title,
    required this.summary,
    required this.content,
    required this.tags,
    this.confidence = 1.0,
    this.isUncertain = false,
    this.status = 'completed',
    this.errorMessage,
    this.aiJsonPayload,
    this.date,
    this.time,
    this.endDate,
    this.endTime,
    this.location,
    this.address,
    this.city,
    this.country,
    this.url,
    this.people = const [],
    this.productName,
    this.price,
    this.currency,
    this.store,
    this.isPurchased = false,
    this.programmingLanguage,
    this.priority,
    this.dueDate,
    this.isCompleted = false,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_path': imagePath,
      'category': category,
      'original_category': originalCategory,
      'title': title,
      'summary': summary,
      'content': content,
      'tags': jsonEncode(tags),
      'confidence': confidence,
      'is_uncertain': isUncertain ? 1 : 0,
      'status': status,
      'error_message': errorMessage,
      'ai_json_payload': aiJsonPayload,
      'date': date,
      'time': time,
      'end_date': endDate,
      'end_time': endTime,
      'location': location,
      'address': address,
      'city': city,
      'country': country,
      'url': url,
      'people': jsonEncode(people),
      'product_name': productName,
      'price': price,
      'currency': currency,
      'store': store,
      'is_purchased': isPurchased ? 1 : 0,
      'programming_language': programmingLanguage,
      'priority': priority,
      'due_date': dueDate,
      'is_completed': isCompleted ? 1 : 0,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory CaptureItem.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    return CaptureItem(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      imagePath: map['image_path'] as String,
      category: map['category'] as String? ?? 'note',
      originalCategory: map['original_category'] as String? ?? (map['category'] as String? ?? 'note'),
      title: map['title'] as String? ?? 'Untitled Capture',
      summary: map['summary'] as String? ?? '',
      content: map['content'] as String? ?? '',
      tags: parseList(map['tags']),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1.0,
      isUncertain: (map['is_uncertain'] as int?) == 1,
      status: map['status'] as String? ?? 'completed',
      errorMessage: map['error_message'] as String?,
      aiJsonPayload: map['ai_json_payload'] as String?,
      date: map['date'] as String?,
      time: map['time'] as String?,
      endDate: map['end_date'] as String?,
      endTime: map['end_time'] as String?,
      location: map['location'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      url: map['url'] as String?,
      people: parseList(map['people']),
      productName: map['product_name'] as String?,
      price: map['price'] as String?,
      currency: map['currency'] as String?,
      store: map['store'] as String?,
      isPurchased: (map['is_purchased'] as int?) == 1,
      programmingLanguage: map['programming_language'] as String?,
      priority: map['priority'] as String?,
      dueDate: map['due_date'] as String?,
      isCompleted: (map['is_completed'] as int?) == 1,
      isRead: (map['is_read'] as int?) == 1,
    );
  }

  CaptureItem copyWith({
    String? category,
    String? title,
    String? summary,
    String? content,
    List<String>? tags,
    double? confidence,
    bool? isUncertain,
    String? status,
    String? errorMessage,
    String? aiJsonPayload,
    String? date,
    String? time,
    String? endDate,
    String? endTime,
    String? location,
    String? address,
    String? city,
    String? country,
    String? url,
    List<String>? people,
    String? productName,
    String? price,
    String? currency,
    String? store,
    bool? isPurchased,
    String? programmingLanguage,
    String? priority,
    String? dueDate,
    bool? isCompleted,
    bool? isRead,
  }) {
    return CaptureItem(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      imagePath: imagePath,
      category: category ?? this.category,
      originalCategory: originalCategory,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      tags: tags ?? List.from(this.tags),
      confidence: confidence ?? this.confidence,
      isUncertain: isUncertain ?? this.isUncertain,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      aiJsonPayload: aiJsonPayload ?? this.aiJsonPayload,
      date: date ?? this.date,
      time: time ?? this.time,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      url: url ?? this.url,
      people: people ?? List.from(this.people),
      productName: productName ?? this.productName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      store: store ?? this.store,
      isPurchased: isPurchased ?? this.isPurchased,
      programmingLanguage: programmingLanguage ?? this.programmingLanguage,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isRead: isRead ?? this.isRead,
    );
  }
}
