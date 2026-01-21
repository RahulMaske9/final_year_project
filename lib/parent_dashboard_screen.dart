import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:first_app/parent_home_screen.dart';
import 'package:first_app/parent_academics_screen.dart';
import 'package:first_app/parent_attendance_screen.dart';
import 'package:first_app/parent_communication_screen.dart';
import 'package:first_app/parent_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedChildId;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: currentUserId == null
          ? const Center(child: Text('Error: Not logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .where('parentId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No student linked to this parent.'));
                }

                final childrenDocs = snapshot.data!.docs;
                if (_selectedChildId == null || !childrenDocs.any((doc) => doc.id == _selectedChildId)) {
                  _selectedChildId = childrenDocs.first.id;
                }
                final selectedChildData = childrenDocs.firstWhere((doc) => doc.id == _selectedChildId).data() as Map<String, dynamic>;

                // ✅ ARCHITECTURE FIX: Pass the student ID to relevant screens
                final screens = [
                  const ParentHomeScreen(),
                  ParentAcademicsScreen(studentId: _selectedChildId!),
                  ParentAttendanceScreen(studentId: _selectedChildId!),
                  const ParentCommunicationScreen(),
                  ParentProfileScreen(studentId: _selectedChildId!, studentData: selectedChildData),
                ];

                final titles = [
                  'Dashboard',
                  'Academics',
                  'Attendance',
                  'Communication',
                  'Profile for ${selectedChildData['name'] ?? ''}',
                ];

                return Scaffold(
                  appBar: AppBar(
                    title: Text(titles[_selectedIndex], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    actions: [
                      if (childrenDocs.length > 1)
                        _buildChildSelector(childrenDocs),
                    ],
                  ),
                  body: screens[_selectedIndex],
                  bottomNavigationBar: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Academics'),
                      BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Attendance'),
                      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Communicate'),
                      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Colors.grey,
                    showUnselectedLabels: true,
                    onTap: _onItemTapped,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChildSelector(List<QueryDocumentSnapshot> childrenDocs) {
    return DropdownButton<String>(
      value: _selectedChildId,
      dropdownColor: const Color(0xFF3F51B5),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
      underline: Container(),
      items: childrenDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(data['name'] ?? 'Child'),
        );
      }).toList(),
      onChanged: (newId) {
        if (newId != null) {
          setState(() => _selectedChildId = newId);
        }
      },
    );
  }
}
