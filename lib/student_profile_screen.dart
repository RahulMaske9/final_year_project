import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  // Dummy Data for the profile
  final Map<String, dynamic> studentProfile = const {
    'profilePictureUrl': '', // Placeholder for URL
    'fullName': 'Alice Wonderland',
    'studentId': 'SW-101',
    'currentClass': '10th Grade - Section A',
    'dateOfBirth': '15-Aug-2008',
    'phoneNumber': '+1-234-567-8900',
    'email': 'alice.w@school.com',
    'facultyAdvisor': 'Mr. Smith',
    'enrolledSubjects': [
      'Mathematics',
      'Physics',
      'Chemistry',
      'English Literature',
      'History',
      'Physical Education',
    ],
    'parentName': 'John Wonderland',
    'parentContact': '+1-098-765-4321',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: 'Academic Information',
              icon: Icons.school_outlined,
              details: {
                'Current Class': studentProfile['currentClass'],
                'Faculty Advisor': studentProfile['facultyAdvisor'],
              },
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: 'Personal Details',
              icon: Icons.person_outline,
              details: {
                'Date of Birth': studentProfile['dateOfBirth'],
                'Phone': studentProfile['phoneNumber'],
                'Email': studentProfile['email'],
              },
            ),
             const SizedBox(height: 20),
            _buildSubjectsCard(context),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: 'Parent/Guardian Information',
              icon: Icons.family_restroom_outlined,
              details: {
                'Name': studentProfile['parentName'],
                'Contact': studentProfile['parentContact'],
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.person, size: 60),
          // backgroundImage: NetworkImage(studentProfile['profilePictureUrl']), // Use this when URL is available
        ),
        const SizedBox(height: 12),
        Text(
          studentProfile['fullName'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Student ID: ${studentProfile['studentId']}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required Map<String, String> details}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.black54)),
                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

   Widget _buildSubjectsCard(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                const Text('Enrolled Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...studentProfile['enrolledSubjects'].map<Widget>((subject) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                 children: [
                   Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                   const SizedBox(width: 8),
                   Text(subject, style: const TextStyle(fontSize: 15)),
                 ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
