import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alimento.dart';

/// Guarda y lee los alimentos en Cloud Firestore.
/// Cada usuario tiene los suyos en: usuarios/{uid}/alimentos
/// Las pantallas lo usan igual que antes: agregar, eliminar,
/// actualizarCantidad y los totales.
class AlimentoService extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> _coleccion;

  // Copia local de lo que hay en Firestore, para que las pantallas
  // puedan contar y filtrar rápido.
  List<Alimento> _alimentos = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _suscripcion;

  /// Último error de Firestore (null si todo va bien).
  String? ultimoError;

  AlimentoService({required String uid})
    : _coleccion = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('alimentos') {
    // Escucha la colección: cada vez que algo cambia en Firestore,
    // la lista se actualiza sola y las pantallas se redibujan.
    _suscripcion = _coleccion.snapshots().listen(
      (snapshot) {
        _alimentos = snapshot.docs
            .map((doc) => Alimento.fromMap(doc.id, doc.data()))
            .toList();
        ultimoError = null;
        notifyListeners();
      },
      onError: (Object error) {
        ultimoError = error.toString();
        debugPrint('Error leyendo alimentos de Firestore: $error');
        notifyListeners();
      },
    );
  }

  List<Alimento> get alimentos => List.unmodifiable(_alimentos);

  int get total => _alimentos.length;

  int get totalBuenEstado =>
      _alimentos.where((a) => a.estado == EstadoAlimento.buenEstado).length;

  int get totalPorVencer =>
      _alimentos.where((a) => a.estado == EstadoAlimento.proximoVencer).length;

  int get totalVencidos =>
      _alimentos.where((a) => a.estado == EstadoAlimento.vencido).length;

  Future<void> agregar(Alimento alimento) async {
    try {
      await _coleccion.doc(alimento.id).set(alimento.toMap());
    } catch (error) {
      ultimoError = error.toString();
      debugPrint('Error guardando alimento en Firestore: $error');
      notifyListeners();
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _coleccion.doc(id).delete();
    } catch (error) {
      ultimoError = error.toString();
      debugPrint('Error eliminando alimento en Firestore: $error');
      notifyListeners();
    }
  }

  Future<void> actualizarCantidad(Alimento alimento, int cantidad) async {
    if (cantidad < 1) return;

    try {
      await _coleccion.doc(alimento.id).update({'cantidad': cantidad});
    } catch (error) {
      ultimoError = error.toString();
      debugPrint('Error actualizando cantidad en Firestore: $error');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
