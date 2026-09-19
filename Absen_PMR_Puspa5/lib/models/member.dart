class Member {
  const Member({
    this.id,
    required this.name,
    required this.className,
    required this.phone,
    this.createdAt,
  });

  final int? id;
  final String name;
  final String className;
  final String phone;
  final String? createdAt;

  Member copyWith({int? id, String? name, String? className, String? phone}) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'class_name': className,
        'phone': phone,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory Member.fromMap(Map<String, Object?> map) => Member(
        id: map['id'] as int?,
        name: map['name'] as String? ?? '',
        className: map['class_name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        createdAt: map['created_at'] as String?,
      );
}
