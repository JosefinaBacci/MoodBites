import 'package:flutter/material.dart';
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
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedDateTime = dateTime;
    });
  }

  Future<void> _saveCapsule() async {
    final message = _messageController.text.trim();
    final unlockAt = _selectedDateTime;

    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    if (unlockAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select unlock date and time')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _model.createTimeCapsule(message, unlockAt);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Time capsule created!')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving capsule: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Capsule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message for the future',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No date/time selected'
                        : 'Unlock at: ${_selectedDateTime!.toLocal()}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick Date & Time'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveCapsule,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Capsule'),
            ),
          ],
        ),
      ),
    );
  }
}
