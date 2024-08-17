import 'package:flutter/material.dart';
import 'package:ocr/Tools/util.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserGesture extends StatefulWidget {
  const UserGesture({super.key});

  @override
  _UserGestureState createState() => _UserGestureState();
}

class _UserGestureState extends State<UserGesture> {
  bool _isLoading = false;
  AuthProvider? authProvider;
  List<dynamic>? users;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    await authProvider?.getAllUsers();
    users = authProvider!.users;

    checkTokenExpiration(authProvider!);

    setState(() => _isLoading = false);
  }

  void _showUserForm({Map<String, dynamic>? userData}) {
    if (userData == null) {
      showDialog(
          context: context,
          builder: (context) => UserCreateForm(onSave: _fetchUsers));
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              UserEditForm(userData: userData, onSave: _fetchUsers));
    }
  }

  void _confirmDeleteUser(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3F8),
        title: const Text(
          "Confirmar eliminación",
          style: TextStyle(color: Color(0xC3000022)),
        ),
        content: const Text(
          "¿Está seguro que desea eliminar este usuario?",
          style: TextStyle(color: Color(0xC3000022)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xC3000022)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteUser(id);
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Color(0xC3000022)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    if (id != 0) {
      final success = await authProvider?.deleteUser(id);
      if (success!) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color(0xFFFFF3F8),
            content: Text(
              'Usuario eliminado con éxito',
              style: TextStyle(color: Color(0xC3000022)),
            )));
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color(0xFFFFF3F8),
            content: Text(
              'Error al eliminar el usuario',
              style: TextStyle(color: Color(0xC3000022)),
            )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xFFFFF3F8),
          content: Text(
            'ID de usuario inválido',
            style: TextStyle(color: Color(0xC3000022)),
          )));
    }
  }

  void checkTokenExpiration(AuthProvider provider) {
    if (provider.expiredToken) {
      provider.handleTokenExpiration();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  String isAdminOrManager(String value) {
    return value == 'Admin' ? 'Administrador' : 'Gestor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              backgroundColor: Color(0xC3000022),
            ))
          : ListView(
              children: [
                const Text(
                  "   Usuarios",
                  style: TextStyle(
                      color: AppColors.negro,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.naranja,
                          textStyle: TextStyle(color: AppColors.blanco)),
                      onPressed: () => _showUserForm(),
                      child: const Text(
                        'Agregar Usuario',
                        style: TextStyle(color: AppColors.blanco),
                      ),
                    ),
                  ),
                ),
                ...authProvider!.users.map(
                  (user) => Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          user['name'] +
                              ' ' +
                              user['last_name'] +
                              ' : ' +
                              isAdminOrManager(user['user_type']),
                          style: const TextStyle(color: Color(0xC3000022)),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: const TextStyle(color: Color(0xC3000022)),
                        ),
                        trailing: PopupMenuButton<String>(
                          color: const Color(0xFFFFF3F8),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showUserForm(userData: user);
                            } else if (value == 'delete') {
                              _confirmDeleteUser(user['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  'Editar',
                                  style: TextStyle(color: Color(0xC3000022)),
                                )),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Color(0xC3000022)),
                                )),
                          ],
                        ),
                      )),
                )
              ],
            ),
    );
  }
}

class UserCreateForm extends StatefulWidget {
  final Function onSave;

  const UserCreateForm({super.key, required this.onSave});

  @override
  _UserCreateFormState createState() => _UserCreateFormState();
}

class _UserCreateFormState extends State<UserCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  String _userType = 'Admin';
  String isAdminOrManager(String value) {
    return value == 'Admin' ? 'Administrador' : 'Gestor';
  }

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmationVisible = false;

  bool validateUserData() {
    // Obtén los valores de los controladores
    String name = _nameController.text.trim();
    String lastname = _lastnameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String passwordConfirmation = _passwordConfirmationController.text.trim();

    // Verifica que todos los campos estén llenos
    if (name.isEmpty ||
        lastname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.mensajError,
          content: Text(
            'Todos los campos son obligatorios.',
            style: TextStyle(color: Color(0xC3000022)),
          )));
      return false; // Devuelve false si hay campos vacíos
    }

    // Verifica que la contraseña tenga al menos 10 caracteres
    if (password.length <= 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.mensajError,
          content: Text(
            'La contraseña debe tener al menos 8 caracteres.',
            style: TextStyle(color: Color(0xC3000022)),
          )));
      return false; // Devuelve false si la contraseña es demasiado corta
    }

    // Verifica que la contraseña y la confirmación sean iguales
    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.mensajError,
          content: Text(
            'Las contraseñas deben coincidir.',
            style: TextStyle(color: Color(0xC3000022)),
          )));
      return false; // Devuelve false si las contraseñas no coinciden
    }

    return true; // Devuelve true si todas las validaciones pasan
  }

  void _handleSubmit() async {
    bool? success;

    if (validateUserData()) {
      Map<String, String> userData = {
        'name': _nameController.text,
        'lastname': _lastnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordConfirmationController.text,
        'user_type': _userType,
      };

      success = await Provider.of<AuthProvider>(context, listen: false)
          .registerUser(userData);
      if (success) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: AppColors.mensajExito,
            content: Text(
              'Usuario guardado exitosamente',
              style: TextStyle(color: Color(0xC3000022)),
            )));
      } else {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: AppColors.mensajError,
            content: Text(
              'Hubo un error al guardar el usuario',
              style: TextStyle(color: Color(0xC3000022)),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Apellido')),
            TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico')),
            TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible),
            TextFormField(
                controller: _passwordConfirmationController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordConfirmationVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordConfirmationVisible =
                            !_isPasswordConfirmationVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordConfirmationVisible),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFFFFF3F8),
              value: _userType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _userType = value;
                  });
                }
              },
              items: <String>['Admin', 'Manager']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    isAdminOrManager(value),
                    style: const TextStyle(color: Color(0xC3000022)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    textStyle: TextStyle(color: AppColors.blanco)),
                child: const Text(
                  'Crear Usuario',
                  style: TextStyle(color: AppColors.blanco),
                )),
          ],
        ),
      ),
    );
  }
}

class UserEditForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onSave;

  const UserEditForm({super.key, required this.userData, required this.onSave});

  @override
  _UserEditFormState createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = 'Admin';
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _lastnameController.text = widget.userData['last_name'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _userType = widget.userData['user_type'] ?? 'Admin';
  }

  String isAdminOrManager(String value) {
    return value == 'Admin' ? 'Administrador' : 'Gestor';
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> userData = {
        'name': _nameController.text,
        'last_name': _lastnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'user_type': _userType,
      };

      final bool update =
          await Provider.of<AuthProvider>(context, listen: false)
              .updateUser(widget.userData['id'], userData);

      if (update) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.mensajExito,
          content: Text('Perfil actualizado correctamente',
              style: TextStyle(color: Color(0xC3000022))),
        ));
      } else {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.mensajError,
          content: Text('Error actualizando el perfil',
              style: TextStyle(color: Color(0xC3000022))),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Apellido')),
            TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico')),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña (opcional)',
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
              obscureText: _obscureText,
            ),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.blanco,
              value: _userType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _userType = value;
                  });
                }
              },
              items: <String>['Admin', 'Manager']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    isAdminOrManager(value),
                    style: const TextStyle(color: Color(0xC3000022)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    textStyle: TextStyle(color: AppColors.blanco)),
                onPressed: _handleUpdate,
                child: const Text('Actualizar Usuario',
                    style: TextStyle(color: AppColors.blanco))),
          ],
        ),
      ),
    );
  }
}
