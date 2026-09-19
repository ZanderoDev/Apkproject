class Attendance {
  const Attendance({
    this.id,
    required this.memberId,
    required this.memberName,
    required this.className,
    required this.date,
    this.checkIn,
    this.checkOut,
  });

  final int? id;
  final int memberId;
  final String memberName;
  final String className;
  final String date;
  final String? checkIn;
  final String? checkOut;

  Map<String, Object?> toMap() => {
        'id': id,
        'member_id': memberId,
        'date': date,
        'check_in': checkIn,
        'check_out': checkOut,
      };

  factory Attendance.fromMap(Map<String, Object?> map) => Attendance(
        id: map['id'] as int?,
        memberId: map['member_id'] as int,
        memberName: map['member_name'] as String? ?? 'Anggota',
        className: map['class_name'] as String? ?? '-',
        date: map['date'] as String? ?? '',
        checkIn: map['check_in'] as String?,
        checkOut: map['check_out'] as String?,
      );
}
