// screens/admin/support_tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideease1/providers/admin_provider.dart';
import 'package:rideease1/models/support_ticket.dart';
import 'package:intl/intl.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  TicketStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Support Tickets'), centerTitle: true),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [null, ...TicketStatus.values].map((status) {
            final label = status == null ? 'ALL' : status.name.toUpperCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: _filter == status,
                onSelected: (_) {
                  setState(() => _filter = status);
                  context.read<AdminProvider>().loadTickets(status: status);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (admin.tickets.isEmpty) {
          return const Center(child: Text('No tickets found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: admin.tickets.length,
          itemBuilder: (_, i) {
            final t = admin.tickets[i];
            return Card(
              child: ListTile(
                title: Text(t.subject),
                subtitle: Text(
                    'From: ${t.userName} • ${DateFormat('MMM dd').format(t.createdAt)}'),
                trailing: Chip(label: Text(t.status.name.toUpperCase())),
                onTap: () => _showDialog(t),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialog(SupportTicket ticket) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ticket.subject),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.description),
              const SizedBox(height: 16),
              if (ticket.status != TicketStatus.resolved)
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Resolution',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('Close')),
          if (ticket.status != TicketStatus.resolved)
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(_);
                final ok = await context
                    .read<AdminProvider>()
                    .resolveTicket(ticket.id, controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Resolved' : 'Failed')),
                );
              },
              child: const Text('Resolve'),
            ),
        ],
      ),
    );
  }
}
