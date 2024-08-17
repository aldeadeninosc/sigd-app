import 'package:flutter/material.dart';
import 'package:ocr/Profile/profile.dart';
import 'package:ocr/Tools/tools.dart';
import 'package:ocr/UploadFile/upload_file.dart';
import 'package:ocr/UserGesture/user_gesture.dart';
import 'package:ocr/home/home.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:ocr/Tools/util.dart';
import 'package:ocr/Profile/profileDialog.dart';
import 'package:ocr/Info/info.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? userType;
  late final AuthProvider authProvider;

  Map<String, String>? user;

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const UploadFile(),
    const Tools(),
    const UserGesture(),
    const Info(),
    const Profile(),
  ];

  static final List<Widget> _widgetOptionsGestor = <Widget>[
    const Home(),
    const UploadFile(),
    const Tools(),
    const Info(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _initializeUser() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentUser();
    user = authProvider.currentUser;
    if (user != null) {
      setState(() {
        userType = user?['user_type'];
      });
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //if (kIsWeb && constraints.maxWidth > 800) {
        if (kIsWeb) {
          return WebMainScreen(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            userType: userType,
            user: user,
          );
        } else {
          return MobileMainScreen(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            userType: userType,
            user: user,
          );
        }
      },
    );
  }
}

class WebMainScreen extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String? userType;
  final Map<String, String>? user;

  const WebMainScreen({
    required this.selectedIndex,
    required this.onItemTapped,
    this.userType,
    this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onItemTapped: onItemTapped,
        userType: userType,
      ),
      appBar: AppBar(
        title: const Text('SIGD', style: TextStyle(color: AppColors.negro)),
        iconTheme: const IconThemeData(color: Color(0xFFFFF3F8)),
        backgroundColor: AppColors.fondo,
        actions: [
          _buildPopupMenu(context, user),
        ],
      ),
      body: Center(
        child: _MainScreenState._widgetOptions.elementAt(selectedIndex),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, Map<String, String>? user) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(right: 5),
        decoration: const BoxDecoration(
          color: AppColors.azul,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: AppColors.blanco),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const ProfileDialog();
          },
        );
      },
    );
  }

  void _navigateToProfile(BuildContext context) {
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState._onItemTapped(4);
    }
  }

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/');
  }
}

class MobileMainScreen extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String? userType;
  final Map<String, String>? user;

  const MobileMainScreen({
    required this.selectedIndex,
    required this.onItemTapped,
    this.userType,
    this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('SIGD', style: TextStyle(color: AppColors.negro)),
        iconTheme: const IconThemeData(color: Color(0xFFFFF3F8)),
        backgroundColor: AppColors.fondo,
        actions: [
          _buildPopupMenu(context),
        ],
      ),
      body: Center(
        child: userType == 'Admin'
            ? _MainScreenState._widgetOptions.elementAt(selectedIndex)
            : _MainScreenState._widgetOptionsGestor.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildBottomNavigationBarItem(Icons.home, 'Inicio'),
          _buildBottomNavigationBarItem(Icons.folder, 'Carpetas'),
          //_buildBottomNavigationBarItem(Icons.add_circle, 'Crear'),
          _buildBottomNavigationBarItem(Icons.widgets, 'Herramientas'),
          if (userType == 'Admin')
            _buildBottomNavigationBarItem(Icons.group, 'Gestión'),
          if (userType == 'Manager')
            _buildBottomNavigationBarItem(Icons.info_outline, 'Información'),
        ],
        currentIndex: selectedIndex,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.amarillo,
        unselectedItemColor: AppColors.azul,
        onTap: onItemTapped,
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(right: 5),
        decoration: const BoxDecoration(
          color: AppColors.azul,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: AppColors.blanco),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ProfileDialog();
          },
        );
      },
    );
  }

  void _navigateToProfile(BuildContext context) {
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState._onItemTapped(2);
    }
  }

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
        icon: Icon(icon), label: label, backgroundColor: AppColors.blanco);
  }
}

class AppDrawer extends StatefulWidget {
  final Function(int) onItemTapped;
  final String? userType;

  const AppDrawer({required this.onItemTapped, this.userType, super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int selectedIndex = 0; // Variable para rastrear el índice seleccionado

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.azul,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondoA.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: AppColors.azul
                        .withOpacity(0.5), // Capa azul con 50% de opacidad
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/logoBlanco.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Inicio', 0),
          _buildDrawerItem(context, Icons.folder, 'Carpetas', 1),
          _buildDrawerItem(context, Icons.widgets, 'Herramientas', 2),
          if (widget.userType == 'Admin')
            _buildDrawerItem(context, Icons.group, 'Gestión de usuario', 3),
          if (widget.userType == 'Manager')
            _buildDrawerItem(context, Icons.info_outline, 'Información', 4),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? AppColors.amarillo : AppColors.azul),
      title: Text(title, style: const TextStyle(color: AppColors.negro)),
      tileColor:
          isSelected ? AppColors.azul.withOpacity(0.2) : Colors.transparent,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        widget.onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
