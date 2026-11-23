import 'package:flutter/material.dart';

import '../models/alimento.dart';
import '../services/alimento_service.dart';
import '../widgets/tarjeta_alimento.dart';
import 'agregar_alimento_screen.dart';

class MisAlimentosScreen extends StatefulWidget {
  final AlimentoService servicio;

  const MisAlimentosScreen({super.key, required this.servicio});

  @override
  State<MisAlimentosScreen> createState() => _MisAlimentosScreenState();
}

class _MisAlimentosScreenState extends State<MisAlimentosScreen> {
  final _busquedaController = TextEditingController();

  String _categoriaSeleccionada = 'Todas';

  final List<String> _categorias = [
    'Todas',
    'Frutas',
    'Verduras',
    'Lácteos',
    'Carnes',
    'Granos',
    'Otros',
  ];

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _eliminarAlimento(Alimento alimento) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alimento'),
          content: Text(
            '¿Deseas eliminar "${alimento.nombre}" de tu despensa?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true && mounted) {
      widget.servicio.eliminar(alimento.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${alimento.nombre} fue eliminado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.servicio,
      builder: (context, child) {
        final texto = _busquedaController.text.trim().toLowerCase();

        final alimentos = widget.servicio.alimentos.where((a) {
          final coincideNombre = a.nombre.toLowerCase().contains(texto);

          final coincideCategoria =
              _categoriaSeleccionada == 'Todas' ||
              a.categoria == _categoriaSeleccionada;

          return coincideNombre && coincideCategoria;
        }).toList()..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

        return Scaffold(
          appBar: AppBar(title: const Text('Mis alimentos')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AgregarAlimentoScreen(servicio: widget.servicio),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar alimento'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _busquedaController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar alimento...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _busquedaController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _busquedaController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _categorias.map((categoria) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(categoria),
                          selected: _categoriaSeleccionada == categoria,
                          onSelected: (_) {
                            setState(() {
                              _categoriaSeleccionada = categoria;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${alimentos.length} alimento(s)',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      const Icon(
                        Icons.sort,
                        size: 18,
                        color: Color(0xFF159957),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Por vencimiento',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: alimentos.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 55,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No hay alimentos para mostrar.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Registra un alimento o cambia '
                                  'los filtros de búsqueda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AgregarAlimentoScreen(
                                          servicio: widget.servicio,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Registrar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: alimentos.length,
                          itemBuilder: (context, index) {
                            final alimento = alimentos[index];

                            return TarjetaAlimento(
                              alimento: alimento,
                              alAumentar: () {
                                widget.servicio.actualizarCantidad(
                                  alimento,
                                  alimento.cantidad + 1,
                                );
                              },
                              alDisminuir: () {
                                if (alimento.cantidad > 1) {
                                  widget.servicio.actualizarCantidad(
                                    alimento,
                                    alimento.cantidad - 1,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La cantidad mínima es 1. '
                                        'Usa eliminar para quitarlo.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              alEliminar: () => _eliminarAlimento(alimento),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
