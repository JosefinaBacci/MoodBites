import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- importar intl para formatear fechas
import '../model/time_capsule_model.dart';

class AddTimeCapsuleScreen extends StatefulWidget {
  const AddTimeCapsuleScreen({super.key});

  @override
  State<AddTimeCapsuleScreen> createState() => _AddTimeCapsuleScreenState();
}

class _AddTimeCapsuleScreenState extends State<AddTimeCapsuleScreen> {
  final _messageController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isSaving = false;
  final TimeCapsuleModel _model = TimeCapsuleModel();

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(
                0xFF3B4D65,
              ), // Azul grisáceo encabezado/selección
              onPrimary: const Color(0xFFD3DADC), // Beige texto selección
              onSurface: Colors.black87, // Texto general
            ),
            dialogBackgroundColor: const Color(0xFFFDF7EF), // Fondo beige claro
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                  0xFF3B4D65,
                ), // Botones azul grisáceo
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3B4D65),
              onPrimary: const Color(0xFFD3DADC),
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: const Color(0xFFFDF7EF),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B4D65),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveCapsule() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Complete all fields')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _model.createTimeCapsule(message, _selectedDateTime!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Time capsule created!')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3E55),
      body: Column(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 100),
            painter: EnvelopePainter(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFFDF7EF),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dear future me,",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3B4D65),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateTime,
                        child: Text(
                          _selectedDateTime == null
                              ? 'Pick date'
                              : '📅 ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!.toLocal())}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B4D65),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Write your message here...",
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _saveCapsule,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 160,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9DAC8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Send to the Future",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F3E55),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE9DAC8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
