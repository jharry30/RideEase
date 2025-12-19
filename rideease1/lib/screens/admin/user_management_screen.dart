// screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/providers/admin_provider.dart';
import 'package:rideease1/models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _filter = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_loadUsers);
  }

  void _loadUsers() {
    context.read<AdminProvider>().loadUsers(
          userType: _filter == 'all' ? null : _filter,
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'rider', 'driver']
                  .map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label:
                              Text(type[0].toUpperCase() + type.substring(1)),
                          selected: _filter == type,
                          onSelected: (_) {
                            setState(() => _filter = type);
                            _loadUsers();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (admin.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: admin.users.length,
          itemBuilder: (_, i) {
            final user = admin.users[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.firstName[0])),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.email),
                trailing: Chip(
                  label: Text(user.isDriver ? 'Driver' : 'Rider'),
                  backgroundColor:
                      user.isDriver ? Colors.green[100] : Colors.blue[100],
                ),
                onTap: () => _showUserActions(user),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserActions(User user) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Suspend'),
              onTap: () => _suspendUser(user)),
          ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Activate'),
              onTap: () => _activateUser(user)),
        ],
      ),
    );
  }

  void _suspendUser(User user) async {
    final success = await context.read<AdminProvider>().suspendUser(user.id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Suspended' : 'Failed')));
  }

  void _activateUser(User user) async {
    final success = await context.read<AdminProvider>().activateUser(user.id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Activated' : 'Failed')));
  }
}
