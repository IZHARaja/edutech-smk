import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static const List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Manajemen Role',
      'icon': Icons.people_alt_outlined,
      'summary': 'Kelola hak akses admin, guru, siswa, BK, wali kelas, dan piket.',
    },
    {
      'title': 'Master Data Sekolah',
      'icon': Icons.apartment_outlined,
      'summary': 'Atur jurusan, kelas, mapel, semester, dan kalender akademik.',
    },
    {
      'title': 'Pengaturan Firebase',
      'icon': Icons.settings_outlined,
      'summary': 'Pantau integrasi Auth, Firestore, Storage, dan notifikasi FCM.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;

    final bool isWideLayout = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal EduTech SMK'),
        backgroundColor: AppColors.roleAdmin,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AppAuthProvider>().logout(),
          ),
        ],
      ),
      drawer: isWideLayout ? null : Drawer(
        child: _AdminSidebar(
          selectedIndex: _selectedIndex,
          onSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Row(
        children: [
          if (isWideLayout)
            SizedBox(
              width: 280,
              child: _AdminSidebar(
                selectedIndex: _selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColors.roleAdmin.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.roleAdmin,
                            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Administrator',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Email: ${user?.email ?? '-'}'),
                                Text(
                                  'Role: ${user?.role.displayName}',
                                  style: const TextStyle(color: AppColors.roleAdmin, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _AdminContentPanel(item: _menuItems[_selectedIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('EduTech SMK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Admin Web Portal', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _AdminDashboardState._menuItems.length,
                itemBuilder: (context, index) {
                  final item = _AdminDashboardState._menuItems[index];
                  final bool selected = selectedIndex == index;

                  return ListTile(
                    selected: selected,
                    selectedTileColor: AppColors.roleAdmin.withOpacity(0.08),
                    leading: Icon(item['icon'] as IconData, color: selected ? AppColors.roleAdmin : AppColors.textSecondary),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.roleAdmin : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminContentPanel extends StatelessWidget {
  const _AdminContentPanel({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(item['summary'] as String, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _AdminStatCard(label: 'Total User', value: '1,284'),
            _AdminStatCard(label: 'Kelas Aktif', value: '36'),
            _AdminStatCard(label: 'Layanan Firebase', value: 'Auth / Firestore / FCM'),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Dummy Control Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Area ini disiapkan untuk daftar data, formulir pengelolaan, dan log integrasi sesuai menu yang dipilih.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
