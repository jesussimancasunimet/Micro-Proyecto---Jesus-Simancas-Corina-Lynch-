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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const PantallaInicio(),
    );
  }
}

/// 🌟 PANTALLA DE INICIO CON LOGO Y ANIMACIÓN
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacionLogo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animacionLogo = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaAhorcado()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 400, 800)).transform(Offset.zero) == null
          ? Colors.blueAccent
          : Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animacionLogo,
                child: const Icon(Icons.psychology_alt_rounded,
                    color: Colors.white, size: 120),
              ),
              const SizedBox(height: 20),
              const Text(
                'El Ahorcado 🎯',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Corina Lynch & Jesús Simancas\nMicroproyecto 💻',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🧩 PANTALLA PRINCIPAL DEL JUEGO
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
        if (palabra.split('').every((l) => letrasAdivinadas.contains(l))) {
          partidasGanadas++;
          _guardarEstadisticas();
          _mostrarDialogo('¡Ganaste! 🎉', 'Adivinaste la palabra "$palabra"');
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
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('El Ahorcado 🎯'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
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
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Ganadas: $partidasGanadas 🏆',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Perdidas: $partidasPerdidas 💀',
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
          style: const TextStyle(
              fontSize: 32,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)),
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
            backgroundColor: usada ? Colors.grey.shade400 : Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white),
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
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white),
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

    canvas.drawLine(Offset(20, size.height - 20),
        Offset(size.width - 20, size.height - 20), paint);
    canvas.drawLine(const Offset(50, 20), Offset(50, size.height - 20), paint);
    canvas.drawLine(const Offset(50, 20), const Offset(150, 20), paint);
    canvas.drawLine(const Offset(150, 20), const Offset(150, 50), paint);

    if (errores > 0) canvas.drawCircle(const Offset(150, 70), 20, paint);
    if (errores > 1) canvas.drawLine(const Offset(150, 90), const Offset(150, 140), paint);
    if (errores > 2) canvas.drawLine(const Offset(150, 100), const Offset(130, 120), paint);
    if (errores > 3) canvas.drawLine(const Offset(150, 100), const Offset(170, 120), paint);
    if (errores > 4) canvas.drawLine(const Offset(150, 140), const Offset(130, 170), paint);
    if (errores > 5) canvas.drawLine(const Offset(150, 140), const Offset(170, 170), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}