class AIStructuredResponse {
  final String category;
  final String title;
  final String summary;
  final String content;
  final List<String> tags;
  final double confidence;
  final bool isUncertain;

  // Optional structured details
  final String? date;
  final String? time;
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
  final String? programmingLanguage;
  final String? priority;
  final String? dueDate;
  final String rawJson;

  AIStructuredResponse({
    required this.category,
    required this.title,
    required this.summary,
    required this.content,
    required this.tags,
    this.confidence = 1.0,
    this.isUncertain = false,
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
    this.programmingLanguage,
    this.priority,
    this.dueDate,
    required this.rawJson,
  });
}
