import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Pantalla de registro de usuarios nuevos (Firebase Auth).
/// Al crear la cuenta correctamente, Firebase inicia sesión solo y
/// main.dart muestra la app; aquí solo se cierra esta pantalla.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _cargando = false;
  bool _ocultarContrasena = true;
  bool _ocultarConfirmar = true;
  String? _mensajeError;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  String _traducirError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'El registro con correo no está activado en Firebase.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      default:
        return 'No se pudo crear la cuenta (${e.code}).';
    }
  }

  Future<void> _registrar() async {
    setState(() => _mensajeError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correoController.text.trim(),
            password: _contrasenaController.text,
          );

      final nombre = _nombreController.text.trim();
      if (nombre.isNotEmpty) {
        await credencial.user?.updateDisplayName(nombre);
      }

      // Vuelve a la raíz: main.dart ya muestra la app con la sesión iniciada.
      if (mounted) Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _mensajeError = _traducirError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1,
                      color: Color(0xFF159957), size: 56),
                  const SizedBox(height: 12),
                  const Text(
                    'Regístrate',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Completa tus datos para crear tu cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Ingresa tu nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final correo = value?.trim() ?? '';
                      if (correo.isEmpty) return 'Ingresa tu correo.';
                      final valido = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(correo);
                      if (!valido) return 'Ingresa un correo válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _ocultarContrasena = !_ocultarContrasena,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una contraseña.';
                      }
                      if (value.length < 6) return 'Mínimo 6 caracteres.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmarController,
                    obscureText: _ocultarConfirmar,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_reset),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmar
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _ocultarConfirmar = !_ocultarConfirmar,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña.';
                      }
                      if (value != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),
                  if (_mensajeError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _mensajeError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _cargando ? null : _registrar,
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crear cuenta'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cargando ? null : () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
