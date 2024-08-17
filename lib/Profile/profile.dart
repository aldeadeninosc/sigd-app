import 'package:flutter/material.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:ocr/Tools/util.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _lastname = '';
  String _email = '';
  String _password = '';
  bool _obscureText = true;
  bool _isLoading = false;
  Map<String, String>? user;
  AuthProvider? authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    authProvider?.getCurrentUser();
    user = authProvider!.currentUser;

    checkTokenExpiration(authProvider);

    if (user != null) {
      setState(() {
        _name = user!['name']!;
        _lastname = user!['last_name']!;
        _email = user!['email']!;
        _isLoading = false;
      });
    }
  }

  void checkTokenExpiration(dynamic provider) {
    if (provider.expiredToken) {
      provider.handleTokenExpiration();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final bool updated =
          await authProvider.updateUser(int.parse(user!['id']!), {
        'name': _name,
        'last_name': _lastname,
        'email': _email,
        'password': _password,
      });

      if (updated) {
        await authProvider.getCurrentUser();
        _loadUserData();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xFFFFF3F8),
          content: Text('Perfil actualizado correctamente',
              style: TextStyle(color: Color(0xC3000022))),
        ));
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xFFFFF3F8),
          content: Text('Error actualizando el perfil',
              style: TextStyle(color: Color(0xC3000022))),
        ));
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // Color de fondo del diálogo
          borderRadius: BorderRadius.circular(30), // Bordes redondeados
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Sombra
              blurRadius: 10,
              offset: const Offset(0, 5), // Desplazamiento de la sombra
            ),
          ],
        ),
        child: _buildProfileForm());
  }

  Widget _buildProfileForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Perfil',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.negro),
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(color: AppColors.negro),
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su nombre' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                style: const TextStyle(color: AppColors.negro),
                initialValue: _lastname,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su apellido' : null,
                onSaved: (value) => _lastname = value!,
              ),
              TextFormField(
                style: const TextStyle(color: AppColors.negro),
                initialValue: _email,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) => value!.isEmpty
                    ? 'Por favor, ingrese su correo electrónico'
                    : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                initialValue: _password,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Alterna el estado
                      });
                    },
                  ),
                ),
                obscureText: _obscureText, // Controla la visibilidad
                validator: (value) {
                  if (value!.isNotEmpty && value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Bordes redondeados
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                        color: AppColors.blanco,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
