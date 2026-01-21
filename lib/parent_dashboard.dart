import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/login_screen.dart';
import 'package:first_app/parent_attendance_screen.dart';
import 'package:first_app/parent_fee_status_screen.dart';
import 'package:first_app/parent_marks_screen.dart';
import 'package:first_app/student_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _selectedChildId;
  Map<String, dynamic>? _selectedChildData;

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Parent Portal', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('parentId', isEqualTo: _currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final childrenDocs = snapshot.data?.docs ?? [];

          if (childrenDocs.isEmpty) {
            return _buildEmptyState();
          }

          if (_selectedChildId == null || !childrenDocs.any((d) => d.id == _selectedChildId)) {
            _selectedChildId = childrenDocs.first.id;
            _selectedChildData = childrenDocs.first.data() as Map<String, dynamic>;
          } else {
            final selectedDoc = childrenDocs.firstWhere((d) => d.id == _selectedChildId);
            _selectedChildData = selectedDoc.data() as Map<String, dynamic>;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildWelcomeCard(childrenDocs),
                const SizedBox(height: 20),
                _buildDashboardSection(
                  title: 'Academic Progress',
                  tiles: [
                    _buildDashboardTile(
                      label: 'Attendance Record',
                      icon: Icons.check_circle_outline,
                      color: Colors.green.shade700,
                      onTap: () => _navigateTo(ParentAttendanceScreen(studentId: _selectedChildId!)),
                    ),
                    _buildDashboardTile(
                      label: 'Exam Results',
                      icon: Icons.emoji_events_outlined,
                      color: Colors.blue.shade800,
                      onTap: () => _navigateTo(ParentMarksScreen(studentId: _selectedChildId!)),
                    ),
                    _buildDashboardTile(
                      label: 'Assignments',
                      icon: Icons.assignment_outlined,
                      color: Colors.orange.shade800,
                      onTap: () => _showFeatureNotImplemented('Assignments'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDashboardSection(
                  title: 'Communication & Finance',
                  tiles: [
                    _buildDashboardTile(
                      label: 'Chat with Faculty',
                      icon: Icons.chat_bubble_outline,
                      color: Colors.pink.shade700,
                      onTap: () => _showFeatureNotImplemented('Faculty Chat'),
                    ),
                    _buildDashboardTile(
                      label: 'College Notices',
                      icon: Icons.campaign_outlined,
                      color: Colors.lightBlue.shade700,
                      onTap: () => _showFeatureNotImplemented('Notices'),
                    ),
                    _buildDashboardTile(
                      label: 'Fee Details',
                      icon: Icons.receipt_long_outlined,
                      color: Colors.purple.shade700,
                       onTap: () => _navigateTo(ParentFeeStatusScreen(studentId: _selectedChildId!)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(List<QueryDocumentSnapshot> childrenDocs) {
    // Ensure we have data before building the card
    if (_selectedChildData == null) return const SizedBox.shrink();

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Viewing Profile for:', style: GoogleFonts.lato(fontSize: 14, color: Colors.white70)),
                if (childrenDocs.length > 1)
                  DropdownButton<String>(
                    value: _selectedChildId,
                    dropdownColor: const Color(0xFF3F51B5),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
                    items: childrenDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['name'] ?? 'Child'),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      if (newId != null) {
                        setState(() => _selectedChildId = newId);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                 // ✅ HERO TAG FIX
                Hero(
                  tag: 'student_avatar_$_selectedChildId',
                   child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                     child: Text(
                       (_selectedChildData!['name'] ?? '?').isNotEmpty ? (_selectedChildData!['name'] ?? '?')[0] : '?',
                       style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                    ),
                                     ),), 
                const SizedBox(width: 16),
                Expanded(
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedChildData!['name'] ?? 'Unknown',
                        style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Class: ${_selectedChildData!['course'] ?? ''} • Sem ${_selectedChildData!['semester'] ?? ''}',
                        style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),), 
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  tooltip: 'View Full Profile',
                  onPressed: () {
                    if (_selectedChildId != null) {
                      _navigateTo(StudentDetailsScreen(
                        studentId: _selectedChildId!,
                        viewerRole: 'Parent',
                      ));
                    }
                  },
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildDashboardSection({required String title, required List<Widget> tiles}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) => tiles[index],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
            ],
          ),),);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No Student Linked', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please contact the administrator to link your child\'s profile.'),
        ],
      ),
    );
  }

  void _showFeatureNotImplemented(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName is not yet implemented.')),
    );
  }
}
