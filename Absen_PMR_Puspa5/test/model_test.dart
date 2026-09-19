import 'package:absen_pmr_puspa5/models/member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('member serializes and restores its core fields', () {
    const member = Member(name: 'Alya', className: 'XI IPA 1', phone: '');
    final restored = Member.fromMap(member.toMap());

    expect(restored.name, 'Alya');
    expect(restored.className, 'XI IPA 1');
    expect(restored.phone, isEmpty);
  });
}
