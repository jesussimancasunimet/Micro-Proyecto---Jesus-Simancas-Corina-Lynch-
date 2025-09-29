// VER ESTE LINK AL TERMINAR https://drive.google.com/file/d/1WlJnwOTvOzjKMj6SCLt-wZ8LF37Q3MvV/view?usp=drivesdk



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
      title: 'El Ahorcado 🎯', // Se pone la barra que da el titulo
      debugShowCheckedModeBanner: false,
      theme: ThemeData( // Tema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Arial', // Fuente
      ),
      home: const PantallaInicio(),
    );
  }
}

// 🌟 Pantalla de inicio con animación
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeLogo; // Le da sombrita
  late Animation<double> _fadeTitulo; // Le da la animacion
  late Animation<double> _fadeAutores; // Animacion
  late Animation<double> _fadeBoton; // Se desaparece

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _fadeLogo = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _fadeTitulo = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    _fadeAutores = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
    );

    _fadeBoton = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeLogo,
              child: Container(
                width: 120, // Ancho
                height: 120, // Alto
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeTitulo,
              child: const Text(
                'EL AHORCADO 🎯',
                style: TextStyle(
                    fontSize: 32, // Tamano de fuente
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 15),
            FadeTransition(
              opacity: _fadeAutores,
              child: const Text(
                'Corina Lynch y Jesús Simancas\nMicroproyecto',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeBoton, // Hace el efecto
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PantallaAhorcado()),
                  );
                },
                child: const Text(
                  'JUGAR', // Titulo
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎮 Pantalla principal del juego
class PantallaAhorcado extends StatefulWidget {
  const PantallaAhorcado({super.key});

  @override
  State<PantallaAhorcado> createState() => _PantallaAhorcadoState();
}

class _PantallaAhorcadoState extends State<PantallaAhorcado> {
  final List<String> palabras = [
    'FLUTTER', // Palabra escodiga 1
    'AHORCADO', // Palabra escodiga 2
    'UNIVERSIDAD', // Palabra escodiga 3
    'VENEZUELA', // Palabra escodiga 4
    'CODIGO', // Palabra escodiga 5
    'PANTALLA', // Palabra escodiga 6
    'COMPUTADORA', // Palabra escodiga 7
    'TELEFONO', // Palabra escodiga 8
    'PROYECTO', // Palabra escodiga 9
    'PROGRAMACION' // Palabra escodiga 10
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
    palabra = palabras[random.nextInt(palabras.length)];
    letrasAdivinadas.clear();
    errores = 0;
    setState(() {});
  }

  void _letraSeleccionada(String letra) {
    setState(() {
      if (palabra.contains(letra)) {
        letrasAdivinadas.add(letra);
        if (palabra
            .split('')
            .every((l) => letrasAdivinadas.contains(l))) {
          partidasGanadas++;
          _guardarEstadisticas();
          _mostrarDialogo('¡Ganaste! 🎉',
              'Felicidades, adivinaste la palabra "$palabra"');
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('El Ahorcado 🎯'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
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
        color: Colors.blueAccent.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Ganadas: $partidasGanadas 🏆',
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('Perdidas: $partidasPerdidas 💀',
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          letrasAdivinadas.contains(letra) ? letra : '_',
          style: const TextStyle(
              fontSize: 32, letterSpacing: 2),
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
        final usada =
            letrasAdivinadas.contains(letra) || errores >= 6;
        return ElevatedButton(
          onPressed: usada ? null : () => _letraSeleccionada(letra),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            usada ? Colors.grey.shade400 : Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
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
            foregroundColor: Colors.white,
          ),
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
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
          ),
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
      ..color = Colors.blueGrey
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Base y estructura
    canvas.drawLine(
        Offset(20, size.height - 20),
        Offset(size.width - 20, size.height - 20),
        paint);
    canvas.drawLine(const Offset(50, 20), Offset(50, size.height - 20), paint);
    canvas.drawLine(const Offset(50, 20), const Offset(150, 20), paint);
    canvas.drawLine(const Offset(150, 20), const Offset(150, 50), paint);

    // Cuerpo
    if (errores > 0) canvas.drawCircle(const Offset(150, 70), 20, paint);
    if (errores > 1)
      canvas.drawLine(const Offset(150, 90), const Offset(150, 140), paint);
    if (errores > 2)
      canvas.drawLine(const Offset(150, 100), const Offset(130, 120), paint);
    if (errores > 3)
      canvas.drawLine(const Offset(150, 100), const Offset(170, 120), paint);
    if (errores > 4)
      canvas.drawLine(const Offset(150, 140), const Offset(130, 170), paint);
    if (errores > 5)
      canvas.drawLine(const Offset(150, 140), const Offset(170, 170), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Corina Lynch y Jesus Simancas
