import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/logger_service.dart';
import '../../core/sound_service.dart';

/// [LoginScreen] proporciona una interfaz inmersiva y moderna para iniciar sesión.
/// Ahora soporta autenticación mediante contraseña (creación automática en primer uso).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    soundService.startBackgroundMusic();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      
      try {
        await ref.read(authViewModelProvider.notifier).login(
          username, 
          password, 
          rememberMe: _rememberMe,
        );
        soundService.playConfirmSound();
      } catch (e) {
        if (!mounted) return;
        soundService.playErrorSound();
        // Limpiamos el texto 'Exception: ' para mostrar algo amigable al usuario
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        LoggerService.e('LoginScreen - Falló la autenticación: $errorMsg');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authViewModelProvider);
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          // Un fondo con un gradiente sutil y moderno
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.4),
              colorScheme.surface,
              colorScheme.tertiaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícono principal animado con efecto de respiración
                  Semantics(
                    label: 'Logotipo de DreamList, un corazón',
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
                      .fadeIn(duration: 600.ms)
                      .shimmer(delay: 2000.ms, duration: 1500.ms),
                  const SizedBox(height: 24),
                  
                  // Títulos
                  Text(
                    'DreamList',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión o regístrate',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 48),

                  // Caja de entrada - Usuario
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      hintText: 'Ej. luis123',
                      prefixIcon: const Icon(Icons.person_pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceTint.withOpacity(0.08),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingresa tu usuario.';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 letras.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                  const SizedBox(height: 16),

                  // Caja de entrada - Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa o crea tu contraseña',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceTint.withOpacity(0.08),
                      // Estilos extra para foco
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido para proteger tu wishlist.';
                      }
                      if (value.length < 4) {
                        return 'La contraseña debe tener al menos 4 caracteres.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _login(),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                  const SizedBox(height: 8),

                  // Recordar sesión
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    },
                    title: const Text('Recordar sesión'),
                    subtitle: const Text('Mantén tu sesión activa al reabrir la app.'),
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    activeColor: colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: 32),

                  // Botón de Acceso
                  FilledButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: authState.isLoading
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : Text(
                          'Comenzar',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
