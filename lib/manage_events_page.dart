
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy data model for an Event
class Event {
  final String eventName;
  final DateTime eventDate;

  Event({required this.eventName, required this.eventDate});
}

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  // Dummy data for events
  final List<Event> _events = [
    Event(eventName: 'Annual Sports Day', eventDate: DateTime(2024, 1, 20)),
    Event(eventName: 'Tech Fest 2024', eventDate: DateTime(2024, 2, 15)),
    Event(eventName: 'Cultural Night', eventDate: DateTime(2024, 3, 10)),
  ];

  void _addEvent() {
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Event Name')),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2025),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Date'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final eventName = nameController.text;
                if (eventName.isNotEmpty && selectedDate != null) {
                  setState(() {
                    _events.add(Event(eventName: eventName, eventDate: selectedDate!));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editing ${event.eventName}')));
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${event.eventName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _events.remove(event);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${event.eventName} deleted')));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Events', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: _events.length,
        itemBuilder: (context, index) => _buildEventCard(_events[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              child: const Icon(Icons.event, color: Colors.pink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.eventName, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(event.eventDate.toLocal().toString().split(' ')[0], style: GoogleFonts.lato(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editEvent(event), tooltip: 'Edit'),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(event), tooltip: 'Delete'),
          ],
        ),
      ),
    );
  }
}
