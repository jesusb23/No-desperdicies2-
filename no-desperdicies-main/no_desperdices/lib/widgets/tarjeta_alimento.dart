import 'package:flutter/material.dart';

import '../models/alimento.dart';

class TarjetaAlimento extends StatelessWidget {
  final Alimento alimento;
  final VoidCallback alEliminar;
  final VoidCallback alAumentar;
  final VoidCallback alDisminuir;

  const TarjetaAlimento({
    super.key,
    required this.alimento,
    required this.alEliminar,
    required this.alAumentar,
    required this.alDisminuir,
  });

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String estadoTexto;

    switch (alimento.estado) {
      case EstadoAlimento.buenEstado:
        color = Colors.green;
        estadoTexto = 'Buen estado';
        break;

      case EstadoAlimento.proximoVencer:
        color = Colors.orange.shade800;
        estadoTexto = alimento.diasRestantes == 0
            ? 'Vence hoy'
            : 'Vence en ${alimento.diasRestantes} día(s)';
        break;

      case EstadoAlimento.vencido:
        color = Colors.red;
        estadoTexto = 'Vencido';
        break;
    }

    final fecha = alimento.fechaVencimiento;

    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(Icons.restaurant, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alimento.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alimento.categoria,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Cantidad: ${alimento.cantidad}'),
            const SizedBox(height: 4),
            Text(
              'Fecha de vencimiento: $fechaTexto',
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Text(
                  'Modificar cantidad:',
                  style: TextStyle(fontSize: 12),
                ),
                IconButton(
                  tooltip: 'Disminuir cantidad',
                  onPressed: alDisminuir,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  tooltip: 'Aumentar cantidad',
                  onPressed: alAumentar,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Eliminar alimento',
                  onPressed: alEliminar,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
