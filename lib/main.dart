import 'package:flutter/material.dart';

import 'models/admin.dart';
import 'models/user_model.dart';
import 'services/admin_service.dart';
import 'services/user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen User & Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Data'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'User'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
            ],
          ),
        ),
        body: const TabBarView(children: [UserListPage(), AdminListPage()]),
      ),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<dynamic>> _usersFuture;
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _usersFuture = ApiService.getUsers();
  }

  Future<void> _openUser(int id) async {
    try {
      await ApiService.getUser(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => UserDetailPage(userId: id)),
      );
      if (mounted) setState(_loadUsers);
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  Future<void> _addUser() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const UserFormDialog(title: 'Tambah User'),
    );
    if (result == null) return;

    try {
      await ApiService.createUser(result.$1, result.$2);
      if (!mounted) return;
      setState(_loadUsers);
      _showMessage(context, 'User berhasil ditambahkan dengan ID 1578');
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID User untuk detail',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final id = int.tryParse(value);
                    if (id != null) _openUser(id);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Cari detail User',
                onPressed: () {
                  final id = int.tryParse(_idController.text);
                  if (id == null) {
                    _showMessage(context, 'Masukkan ID User yang valid');
                  } else {
                    _openUser(id);
                  }
                },
                icon: const Icon(Icons.search),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Tambah User',
                onPressed: _addUser,
                icon: const Icon(Icons.person_add),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _LoadError(
                  error: snapshot.error!,
                  onRetry: () => setState(_loadUsers),
                );
              }

              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Center(child: Text('Belum ada data User'));
              }
              return RefreshIndicator(
                onRefresh: () async => setState(_loadUsers),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = User.fromJson(
                      Map<String, dynamic>.from(users[index] as Map),
                    );
                    return ListTile(
                      leading: CircleAvatar(child: Text('${user.id}')),
                      title: Text(user.name),
                      subtitle: Text('${user.email}\n${user.city}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openUser(user.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  late Future<List<Admin>> _adminsFuture;
  final _idController = TextEditingController(text: '871');

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _loadAdmins() {
    _adminsFuture = AdminService.getAdmins();
  }

  Future<void> _openAdmin(int id) async {
    try {
      await AdminService.getAdmin(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AdminDetailPage(adminId: id)),
      );
      if (mounted) setState(_loadAdmins);
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  Future<void> _deleteAdmin(int id) async {
    final confirmed = await _confirmDelete(context, 'Admin ID $id');
    if (!confirmed) return;

    try {
      final deleted = await AdminService.deleteAdmin(id);
      if (!mounted) return;
      setState(_loadAdmins);
      _showMessage(
        context,
        deleted ? 'Admin ID $id berhasil dihapus' : 'Admin tidak ditemukan',
      );
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Admin untuk detail',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final id = int.tryParse(value);
                    if (id != null) _openAdmin(id);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Cari detail Admin',
                onPressed: () {
                  final id = int.tryParse(_idController.text);
                  if (id == null) {
                    _showMessage(context, 'Masukkan ID Admin yang valid');
                  } else {
                    _openAdmin(id);
                  }
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Admin>>(
            future: _adminsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _LoadError(
                  error: snapshot.error!,
                  onRetry: () => setState(_loadAdmins),
                );
              }
              final admins = snapshot.data ?? [];
              if (admins.isEmpty) {
                return const Center(child: Text('Belum ada data Admin'));
              }
              return RefreshIndicator(
                onRefresh: () async => setState(_loadAdmins),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${admin.id}')),
                      title: Text(admin.name),
                      subtitle: Text('${admin.email}\n${admin.department}'),
                      isThreeLine: true,
                      onTap: () => _openAdmin(admin.id),
                      trailing: IconButton(
                        tooltip: 'Hapus Admin',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteAdmin(admin.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.userId});

  final int userId;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _userFuture = ApiService.getUser(widget.userId).then(User.fromJson);
  }

  Future<void> _updateUser(User user) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => UserFormDialog(
        title: 'PUT - Perbarui User',
        name: user.name,
        email: user.email,
      ),
    );
    if (result == null) return;

    try {
      await ApiService.updateUser(widget.userId, result.$1, result.$2);
      if (!mounted) return;
      setState(_loadUser);
      _showMessage(context, 'Nama dan email User berhasil diperbarui');
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  Future<void> _patchUser(User user) async {
    try {
      await ApiService.patchUser(
        widget.userId,
        '${user.name} - Flutter Developer',
      );
      if (!mounted) return;
      setState(_loadUser);
      _showMessage(context, 'Nama User berhasil diubah dengan PATCH');
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await _confirmDelete(context, 'User ID ${widget.userId}');
    if (!confirmed) return;
    try {
      final deleted = await ApiService.deleteUser(widget.userId);
      if (!mounted) return;
      if (deleted) {
        Navigator.of(context).pop();
      } else {
        _showMessage(context, 'User tidak ditemukan');
      }
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail User ${widget.userId}')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              error: snapshot.error!,
              onRetry: () => setState(_loadUser),
            );
          }
          final user = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _DetailCard(
                title: user.name,
                fields: {
                  'ID': '${user.id}',
                  'Email': user.email,
                  'Kota': user.city,
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _updateUser(user),
                icon: const Icon(Icons.edit),
                label: const Text('PUT - Ubah nama dan email'),
              ),
              OutlinedButton.icon(
                onPressed: () => _patchUser(user),
                icon: const Icon(Icons.update),
                label: const Text('PATCH - Tambah Flutter Developer'),
              ),
              OutlinedButton.icon(
                onPressed: _deleteUser,
                icon: const Icon(Icons.delete_outline),
                label: const Text('DELETE User'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminDetailPage extends StatefulWidget {
  const AdminDetailPage({super.key, required this.adminId});

  final int adminId;

  @override
  State<AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  late Future<Admin> _adminFuture;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  void _loadAdmin() {
    _adminFuture = AdminService.getAdmin(widget.adminId);
  }

  Future<void> _deleteAdmin() async {
    final confirmed = await _confirmDelete(
      context,
      'Admin ID ${widget.adminId}',
    );
    if (!confirmed) return;
    try {
      final deleted = await AdminService.deleteAdmin(widget.adminId);
      if (!mounted) return;
      if (deleted) {
        Navigator.of(context).pop();
      } else {
        _showMessage(context, 'Admin tidak ditemukan');
      }
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Admin ${widget.adminId}')),
      body: FutureBuilder<Admin>(
        future: _adminFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              error: snapshot.error!,
              onRetry: () => setState(_loadAdmin),
            );
          }
          final admin = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _DetailCard(
                title: admin.name,
                fields: {
                  'ID': '${admin.id}',
                  'Email': admin.email,
                  'Departemen': admin.department,
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _deleteAdmin,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Admin'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({
    super.key,
    required this.title,
    this.name = '',
    this.email = '',
  });

  final String title;
  final String name;
  final String email;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) return;
    Navigator.of(context).pop((name, email));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.fields});

  final String title;
  final Map<String, String> fields;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 24),
            for (final entry in fields.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gagal memuat data: $error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String label) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi penghapusan'),
          content: Text('Hapus $label?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      ) ??
      false;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
