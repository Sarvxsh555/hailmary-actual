class TBCenter {
  final String name;
  final double lat;
  final double lon;
  final String type; // "dots" | "govt"
  final String city;

  const TBCenter({
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,
    required this.city,
  });

  factory TBCenter.fromJson(Map<String, dynamic> json) {
    return TBCenter(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      type: (json['type'] as String?) ?? 'govt',
      city: (json['city'] as String?) ?? '',
    );
  }

  bool get isDots => type == 'dots';
}
