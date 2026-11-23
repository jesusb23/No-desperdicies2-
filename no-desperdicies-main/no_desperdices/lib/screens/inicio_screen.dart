import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/alimento_service.dart';
import '../widgets/tarjeta_resumen.dart';
import 'agregar_alimento_screen.dart';
import 'mis_alimentos_screen.dart';

class InicioScreen extends StatelessWidget {
  final AlimentoService servicio;

  const InicioScreen({super.key, required this.servicio});

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: servicio,
      builder: (context, child) {
        final correo = FirebaseAuth.instance.currentUser?.email ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text(correo, style: const TextStyle(fontSize: 14)),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () => _cerrarSesion(context),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF138A50), Color(0xFF35B875)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.eco, color: Colors.white, size: 42),
                      SizedBox(height: 12),
                      Text(
                        'No Desperdicies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cuida tus alimentos, ahorra dinero '
                        'y ayuda al planeta.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Resumen de tu despensa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TarjetaResumen(
                        numero: servicio.totalBuenEstado.toString(),
                        titulo: 'Buen estado',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TarjetaResumen(
                        numero: servicio.totalPorVencer.toString(),
                        titulo: 'Por vencer',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TarjetaResumen(
                        numero: servicio.totalVencidos.toString(),
                        titulo: 'Vencidos',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  '¿Qué deseas hacer?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _OpcionInicio(
                  icono: Icons.add_circle_outline,
                  titulo: 'Registrar alimento',
                  descripcion: 'Agrega un producto a tu despensa',
                  alPresionar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgregarAlimentoScreen(servicio: servicio),
                      ),
                    );
                  },
                ),

                _OpcionInicio(
                  icono: Icons.kitchen_outlined,
                  titulo: 'Mis alimentos',
                  descripcion: 'Consulta productos y vencimientos',
                  alPresionar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MisAlimentosScreen(servicio: servicio),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                if (servicio.totalPorVencer + servicio.totalVencidos > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Revisa los alimentos próximos a vencer '
                            'y consúmelos primero para evitar desperdicios.',
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                Text(
                  '${servicio.total} alimentos registrados',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OpcionInicio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback alPresionar;

  const _OpcionInicio({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF159957).withValues(alpha: 0.12),
          child: Icon(icono, color: const Color(0xFF159957)),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
        onTap: alPresionar,
      ),
    );
  }
}
