import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final members = provider.searchMembers(_query);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openMemberForm(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Tambah'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            const Text(
              'Data Anggota',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            const Text(
              'Kelola anggota PMR Puspa 5.',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Cari nama atau kelas...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json', width: 110, height: 110),
                      const SizedBox(height: 12),
                      const Text('Belum ada data anggota', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      const Text('Tekan Tambah untuk membuat data baru.', style: TextStyle(color: AppTheme.muted)),
                    ],
                  ),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: List.generate(
                    members.length,
                    (index) => AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 360),
                      child: SlideAnimation(
                        verticalOffset: 24,
                        child: FadeInAnimation(child: _MemberTile(member: members[index])),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMemberForm(BuildContext context, {Member? member}) async {
    final name = TextEditingController(text: member?.name);
    final className = TextEditingController(text: member?.className);
    final phone = TextEditingController(text: member?.phone);
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member == null ? 'Tambah Anggota' : 'Edit Anggota',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const const SizedBox(height: 12),
                TextFormField(
                  controller: className,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Kelas wajib diisi'
                      : null,
                ),
                const const SizedBox(height: 12),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor telepon (opsional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await context.read<AppProvider>().saveMember(
                            id: member?.id,
                            name: name.text,
                            className: className.text,
                            phone: phone.text,
                          );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Simpan Anggota'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    name.dispose();
    className.dispose();
    phone.dispose();
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: AppTheme.crimson.withOpacity(.1),
          child: Text(
            member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
            style: const TextStyle(color: AppTheme.crimson, fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${member.className}${member.phone.isEmpty ? '' : ' • ${member.phone}'}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final state = context.findAncestorStateOfType<_MembersScreenState>();
              if (state != null) {
                await state._openMemberForm(context, member: member);
              }
            } else if (value == 'delete' && member.id != null) {
              await context.read<AppProvider>().removeMember(member.id!);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }
}
