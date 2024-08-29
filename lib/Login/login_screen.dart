import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ocr/Tools/util.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool _obscureText = true;

  void login(String email, String password) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(email, password);
      if (success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        setState(() {
          errorMessage =
              'Error en el login. Por favor, verifica tus credenciales';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      setState(() {
        errorMessage = 'Ha ocurrido un error. Inténtalo de nuevo más tarde.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth > 800) {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondoA.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: AppColors.azul
                        .withOpacity(0.5), // Capa negra con 30% de opacidad
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(125.0),
                            child: Container(
                              padding: const EdgeInsets.all(35.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    15.0), // Bordes circulares
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.naranja),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Correo',
                                      hintStyle: TextStyle(
                                        color: AppColors.azul,
                                      ),
                                      prefixIcon: Icon(Icons.email,
                                          color: AppColors.azul),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Contraseña',
                                      hintStyle: const TextStyle(
                                        color: AppColors.azul,
                                      ),
                                      prefixIcon: const Icon(Icons.lock,
                                          color: AppColors.azul),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      suffixIconColor: AppColors.azul,
                                    ),
                                    obscureText: _obscureText,
                                  ),
                                  const SizedBox(
                                      height: 20), //------------------
                                  if (errorMessage.isNotEmpty)
                                    Text(
                                      errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  if (isLoading)
                                    const CircularProgressIndicator(),
                                  if (!isLoading)
                                    GestureDetector(
                                      onTap: () => {
                                        login(emailController.text.toString(),
                                            passwordController.text.toString())
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          color: AppColors.naranja,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Ingresar',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )),
                      Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/logoBlanco.png',
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondoA.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: AppColors.azul
                        .withOpacity(0.5), // Capa negra con 30% de opacidad
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/logoBlanco.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            height: 180,
                          ),
                          const SizedBox(height: 5),
                          Card(
                            color: Colors.white,
                            elevation: 4, // Sombra de la tarjeta
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.naranja),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Correo',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.azul,
                                      ),
                                      prefixIcon: Icon(Icons.email,
                                          color: AppColors.azul),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  TextField(
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Contraseña',
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.azul,
                                      ),
                                      prefixIcon: const Icon(Icons.lock,
                                          color: AppColors.azul),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      suffixIconColor: AppColors.azul,
                                    ),
                                    obscureText: _obscureText,
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  if (errorMessage.isNotEmpty)
                                    Text(
                                      errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  if (isLoading)
                                    const CircularProgressIndicator(),
                                  if (!isLoading)
                                    GestureDetector(
                                      onTap: () => {
                                        login(emailController.text.toString(),
                                            passwordController.text.toString())
                                      },
                                      child: Container(
                                        height: 60,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                          color: AppColors.naranja,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Ingresar',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //),
              ],
            );
          }
        },
      ),
    );
  }
}
