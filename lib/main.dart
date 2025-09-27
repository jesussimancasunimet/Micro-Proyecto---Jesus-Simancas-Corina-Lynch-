import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AhorcadoApp());
}

class AhorcadoApp extends StatelessWidget {
  const AhorcadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Ahorcado 🎯',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const PantallaAhorcado(),
    );
  }
}

class PantallaAhorcado extends StatefulWidget {
  const PantallaAhorcado({super.key});

  @override
  State<PantallaAhorcado> createState() => _PantallaAhorcadoState();
}

class _PantallaAhorcadoState extends State<PantallaAhorcado> {
  final List<String> palabras = [
    'flutter',
    'ahorcado',
    'universidad',
    'venezuela',
    'codigo',
    'pantalla',
    'computadora',
    'telefono',
    'proyecto',
    'programacion'
  ];

  String palabra = '';
  List<String> letrasAdivinadas = [];
  int errores = 0;
  int partidasGanadas = 0;
  int partidasPerdidas = 0;

  @override
  void initState() {
    super.initState();
    _nuevaPartida();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      partidasGanadas = prefs.getInt('ganadas') ?? 0;
      partidasPerdidas = prefs.getInt('perdidas') ?? 0;
    });
  }

  Future<void> _guardarEstadisticas() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('ganadas', partidasGanadas);
    prefs.setInt('perdidas', partidasPerdidas);
  }

  void _nuevaPartida() {
    final random = Random();
    palabra = palabras[random.nextInt(palabras.length)].toUpperCase();
    letrasAdivinadas.clear();
    errores = 0;
    setState(() {});
  }

  void _letraSeleccionada(String letra) {
    setState(() {
      if (palabra.contains(letra)) {
        letrasAdivinadas.add(letra);
        if (palabra.split('').every((letraPalabra) => letrasAdivinadas.contains(letraPalabra))) {
          partidasGanadas++;
          _guardarEstadisticas();
          _mostrarDialogo('¡Ganaste! 🎉', 'Felicidades, adivinaste la palabra "$palabra"');
        }
      } else {
        errores++;
        if (errores == 6) {
          partidasPerdidas++;
          _guardarEstadisticas();
          _mostrarDialogo('Perdiste 💀', 'La palabra era "$palabra"');
        }
      }
    });
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nuevaPartida();
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECFF),
      appBar: AppBar(
        title: const Text('El Ahorcado 🎯'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _estadisticas(),
            _dibujoAhorcado(),
            _palabraOculta(),
            _teclado(),
            _botonesAccion(),
          ],
        ),
      ),
    );
  }

  Widget _estadisticas() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Ganadas: $partidasGanadas 🏆', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Perdidas: $partidasPerdidas 💀', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _palabraOculta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: palabra
          .split('')
          .map((letra) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          letrasAdivinadas.contains(letra) ? letra : '_',
          style: const TextStyle(fontSize: 32, letterSpacing: 2),
        ),
      ))
          .toList(),
    );
  }

  Widget _teclado() {
    const letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: letras.split('').map((letra) {
        final usada = letrasAdivinadas.contains(letra) || errores >= 6;
        return ElevatedButton(
          onPressed: usada ? null : () => _letraSeleccionada(letra),
          style: ElevatedButton.styleFrom(
            backgroundColor: usada ? Colors.grey.shade400 : Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(letra, style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
    );
  }

  Widget _botonesAccion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _nuevaPartida,
          icon: const Icon(Icons.refresh),
          label: const Text('Nueva partida'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            setState(() {
              partidasGanadas = 0;
              partidasPerdidas = 0;
            });
          },
          icon: const Icon(Icons.delete),
          label: const Text('Reiniciar estadísticas'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _dibujoAhorcado() {
    return CustomPaint(
      size: const Size(200, 200),
      painter: AhorcadoPainter(errores),
    );
  }
}

class AhorcadoPainter extends CustomPainter {
  final int errores;
  AhorcadoPainter(this.errores);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Base
    canvas.drawLine(Offset(20, size.height - 20), Offset(size.width - 20, size.height - 20), paint);
    // Poste
    canvas.drawLine(const Offset(50, 20), Offset(50, size.height - 20), paint);
    // Brazo
    canvas.drawLine(const Offset(50, 20), const Offset(150, 20), paint);
    // Cuerda
    canvas.drawLine(const Offset(150, 20), const Offset(150, 50), paint);

    if (errores > 0) canvas.drawCircle(const Offset(150, 70), 20, paint); // Cabeza
    if (errores > 1) canvas.drawLine(const Offset(150, 90), const Offset(150, 140), paint); // Cuerpo
    if (errores > 2) canvas.drawLine(const Offset(150, 100), const Offset(130, 120), paint); // Brazo izq
    if (errores > 3) canvas.drawLine(const Offset(150, 100), const Offset(170, 120), paint); // Brazo der
    if (errores > 4) canvas.drawLine(const Offset(150, 140), const Offset(130, 170), paint); // Pierna izq
    if (errores > 5) canvas.drawLine(const Offset(150, 140), const Offset(170, 170), paint); // Pierna der
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}