import 'package:flutter/material.dart';
import 'package:ocr/Tools/util.dart';
import 'package:ocr/Profile/profile.dart';
import 'package:provider/provider.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:ocr/Login/login_screen.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({Key? key}) : super(key: key);
  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  Map<String, String>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentUser(); // Obtener el usuario actual
    setState(() {
      user = authProvider.currentUser; // Almacenar el usuario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const Text(
                'Usuario',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.negro),
              ),
              user != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${user!['name']} ${user!['last_name']!}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.azul)),
                        const SizedBox(height: 8),
                        Text('${user!['user_type']}',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('${user!['email']}',
                            style: const TextStyle(fontSize: 14))
                      ],
                    )
                  : const Text('Error al cargar la información del usuario.'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => {
                  _showProfileDialog(context),
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.355,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.azul,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      'Editar Información',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.355,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                          color: AppColors.blanco,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ])));
  }
}

void _showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const Dialog(
        child: Profile(),
      );
    },
  );
}
