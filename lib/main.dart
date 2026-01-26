
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CollegeManagementApp());
}

class CollegeManagementApp extends StatelessWidget {
  const CollegeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Indigo
          brightness: Brightness.light,
          primary: const Color(0xFF273C9A), // Indigo
          secondary: const Color(0xFFFFC107), // Amber
          surface: const Color(0xFFF5F7FA), // Light Grey
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
          headlineSmall: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF3F51B5)], // White to Indigo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.4, // Zoom in on the logo
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SIPNA COET ',
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF3F51B5), // Indigo
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _roles = [
    {'name': 'Admin', 'icon': Icons.admin_panel_settings, 'color': Colors.indigo.shade800},
    {'name': 'Faculty', 'icon': Icons.supervisor_account, 'color': Colors.indigo.shade600},
    {'name': 'Parent', 'icon': Icons.family_restroom, 'color': const Color(0xFF3F51B5)},
  ];

  final List<Map<String, dynamic>> _notifications = [
    {'text': 'New circular regarding summer vacation.', 'color': const Color(0xFF3F51B5)},
    {'text': 'Exam schedule for all branches has been updated.', 'color': const Color(0xFF3F51B5)},
    {'text': 'Results for the 1st internal test are out.', 'color': const Color(0xFF3F51B5)},
    {'text': "Workshop on 'Future of AI' on 25th July.", 'color': const Color(0xFF3F51B5)},
  ];

  bool _animate = false;
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Trigger the animation shortly after the widget is built
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _animate = true);
    });
    
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _notifications.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.surface, const Color(0xFFE9EBEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _roles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return AnimatedOpacity(
                          opacity: _animate ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500 + (index * 150)),
                          curve: Curves.easeIn,
                          child: _RoleCard(
                            role: _roles[index]['name'],
                            icon: _roles[index]['icon'],
                            color: _roles[index]['color'],
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  _buildNotificationSlider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/logo.png', height: 60),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIPNA COET',
                    style: GoogleFonts.lato(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                  Text(
                    'Welcome to College Portal',
                    style: GoogleFonts.lato(
                      fontSize: 18, 
                      color: Colors.black54
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSlider() {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: _notifications.length,
        onPageChanged: (int page) {
          if (mounted) {
            setState(() {
              _currentPage = page;
            });
          }
        },
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _notifications[index]['text'],
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _notifications[index]['color'],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String role;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isHovering ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FilledButton(
        onHover: (hovering) {
          setState(() {
            _isHovering = hovering;
          });
        },
        style: FilledButton.styleFrom(
          backgroundColor: _isHovering ? widget.color.withAlpha(230) : widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          elevation: _isHovering ? 12 : 6,
          shadowColor: _isHovering ? Colors.black.withAlpha(128) : Colors.black.withAlpha(51),
        ),
        onPressed: widget.onTap,
        child: Row(
          children: [
            Icon(widget.icon, size: 40, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                widget.role,
                style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
             Icon(Icons.arrow_forward_ios, color: Colors.white.withAlpha(204)),
          ],
        ),
      ),
    );
  }
}
