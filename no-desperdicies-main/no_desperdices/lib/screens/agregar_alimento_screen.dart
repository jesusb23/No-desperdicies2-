import 'package:flutter/material.dart';

import '../models/alimento.dart';
import '../services/alimento_service.dart';

class AgregarAlimentoScreen extends StatefulWidget {
  final AlimentoService servicio;

  const AgregarAlimentoScreen({super.key, required this.servicio});

  @override
  State<AgregarAlimentoScreen> createState() => _AgregarAlimentoScreenState();
}

class _AgregarAlimentoScreenState extends State<AgregarAlimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');

  String _categoria = 'Frutas';

  DateTime _fechaCompra = DateTime.now();
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Future<void> _seleccionarFecha(bool esCompra) async {
    final fechaInicial = esCompra ? _fechaCompra : _fechaVencimiento;

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: esCompra
          ? 'Selecciona la fecha de compra'
          : 'Selecciona la fecha de vencimiento',
    );

    if (fecha != null && mounted) {
      setState(() {
        if (esCompra) {
          _fechaCompra = fecha;
        } else {
          _fechaVencimiento = fecha;
        }
      });
    }
  }

  void _guardarAlimento() {
    if (!_formKey.currentState!.validate()) return;

    final compra = DateTime(
      _fechaCompra.year,
      _fechaCompra.month,
      _fechaCompra.day,
    );

    final vencimiento = DateTime(
      _fechaVencimiento.year,
      _fechaVencimiento.month,
      _fechaVencimiento.day,
    );

    if (vencimiento.isBefore(compra)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de vencimiento no puede ser anterior '
            'a la fecha de compra.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final alimento = Alimento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      categoria: _categoria,
      cantidad: int.parse(_cantidadController.text.trim()),
      fechaCompra: _fechaCompra,
      fechaVencimiento: _fechaVencimiento,
    );

    widget.servicio.agregar(alimento);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Alimento registrado correctamente!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar alimento')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.eco_outlined,
                color: Color(0xFF159957),
                size: 52,
              ),
              const SizedBox(height: 8),
              const Text(
                'Nuevo alimento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Completa los datos del producto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del alimento',
                  hintText: 'Ej. Manzanas',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del alimento.';
                  }

                  if (value.trim().length < 2) {
                    return 'Escribe al menos 2 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items:
                    const [
                      'Frutas',
                      'Verduras',
                      'Lácteos',
                      'Carnes',
                      'Granos',
                      'Otros',
                    ].map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _categoria = valor);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ej. 2',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final cantidad = int.tryParse(value ?? '');

                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingresa un entero mayor que cero.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              _SelectorFecha(
                titulo: 'Fecha de compra',
                fecha: _formatearFecha(_fechaCompra),
                alPresionar: () => _seleccionarFecha(true),
              ),
              const SizedBox(height: 14),
              _SelectorFecha(
                titulo: 'Fecha de vencimiento',
                fecha: _formatearFecha(_fechaVencimiento),
                alPresionar: () => _seleccionarFecha(false),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _guardarAlimento,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar alimento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorFecha extends StatelessWidget {
  final String titulo;
  final String fecha;
  final VoidCallback alPresionar;

  const _SelectorFecha({
    required this.titulo,
    required this.fecha,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: titulo,
          prefixIcon: const Icon(Icons.calendar_month),
          suffixIcon: const Icon(Icons.edit_calendar),
          border: const OutlineInputBorder(),
        ),
        child: Text(fecha),
      ),
    );
  }
}
