
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Model for event data
class Event {
  String id;
  String title;
  String description;
  DateTime eventDate;
  TimeOfDay eventTime;

  Event({required this.id, required this.title, required this.description, required this.eventDate, required this.eventTime});
}

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  // Dummy data
  final List<Event> _events = [
    Event(id: 'E01', title: 'Annual Sports Day', description: 'The annual sports day will be held on the main ground. All students are invited to participate.', eventDate: DateTime.now().add(const Duration(days: 10)), eventTime: const TimeOfDay(hour: 9, minute: 0)),
    Event(id: 'E02', title: 'Science Exhibition', description: 'A science exhibition will be held in the auditorium. Students can showcase their projects.', eventDate: DateTime.now().add(const Duration(days: 20)), eventTime: const TimeOfDay(hour: 10, minute: 30)),
  ];

  void _addEvent(Event event) {
    setState(() {
      _events.add(event);
      _events.sort((a, b) => a.eventDate.compareTo(b.eventDate)); // Sort by date
    });
  }

  void _updateEvent(Event updatedEvent) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        _events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      }
    });
  }

  void _deleteEvent(String id) {
    setState(() {
      _events.removeWhere((event) => event.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Events', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: _events.isEmpty
          ? _buildEmptyState()
          : _buildEventList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No upcoming events',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${DateFormat('EEE, MMM d, yyyy').format(event.eventDate)} at ${event.eventTime.format(context)}\n${event.description}', maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () => _showEventFormDialog(event: event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(event),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the event: ${event.title}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
            onPressed: () {
              _deleteEvent(event.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${event.title} deleted successfully.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEventFormDialog({Event? event}) async {
    final isEditing = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    DateTime selectedDate = event?.eventDate ?? DateTime.now();
    TimeOfDay selectedTime = event?.eventTime ?? TimeOfDay.now();

    final formKey = GlobalKey<FormState>();

    // Function to pick date
    Future<void> pickDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null && pickedDate != selectedDate) {
        selectedDate = pickedDate;
      }
    }

    // Function to pick time
    Future<void> pickTime() async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (pickedTime != null && pickedTime != selectedTime) {
        selectedTime = pickedTime;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Event' : 'Create New Event'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()),
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                     maxLines: 3,
                     validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                            child: Text(DateFormat('yMMMMd').format(selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: pickTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder()),
                            child: Text(selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            FilledButton(
              child: Text(isEditing ? 'Update' : 'Create'),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                
                final newEvent = Event(
                  id: event?.id ?? DateTime.now().toIso8601String(),
                  title: titleController.text,
                  description: descriptionController.text,
                  eventDate: selectedDate,
                  eventTime: selectedTime,
                );

                if (isEditing) {
                  _updateEvent(newEvent);
                } else {
                  _addEvent(newEvent);
                }

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Event ${isEditing ? 'updated' : 'created'} successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
