import 'package:flutter/material.dart';

class TarjetaResumen extends StatelessWidget {
  final String numero;
  final String titulo;
  final Color color;

  const TarjetaResumen({
    super.key,
    required this.numero,
    required this.titulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        child: Column(
          children: [
            Text(
              numero,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
