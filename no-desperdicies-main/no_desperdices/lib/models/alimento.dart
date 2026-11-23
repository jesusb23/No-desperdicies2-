import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoAlimento { buenEstado, proximoVencer, vencido }

class Alimento {
  final String id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final DateTime fechaCompra;
  final DateTime fechaVencimiento;

  const Alimento({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.fechaCompra,
    required this.fechaVencimiento,
  });

  /// Convierte el alimento en un mapa para guardarlo en Firestore.
  /// Son exactamente los mismos campos del formulario.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'fechaCompra': Timestamp.fromDate(fechaCompra),
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
    };
  }

  /// Crea un alimento a partir de un documento de Firestore.
  factory Alimento.fromMap(String id, Map<String, dynamic> map) {
    return Alimento(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      categoria: map['categoria'] as String? ?? 'Otros',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 1,
      fechaCompra: _leerFecha(map['fechaCompra']),
      fechaVencimiento: _leerFecha(map['fechaVencimiento']),
    );
  }

  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return DateTime.now();
  }

  int get diasRestantes {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final vencimiento = DateTime(
      fechaVencimiento.year,
      fechaVencimiento.month,
      fechaVencimiento.day,
    );

    return vencimiento.difference(hoy).inDays;
  }

  EstadoAlimento get estado {
    if (diasRestantes < 0) {
      return EstadoAlimento.vencido;
    }

    if (diasRestantes <= 3) {
      return EstadoAlimento.proximoVencer;
    }

    return EstadoAlimento.buenEstado;
  }

  Alimento copiarCon({int? cantidad}) {
    return Alimento(
      id: id,
      nombre: nombre,
      categoria: categoria,
      cantidad: cantidad ?? this.cantidad,
      fechaCompra: fechaCompra,
      fechaVencimiento: fechaVencimiento,
    );
  }
}
