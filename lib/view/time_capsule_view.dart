import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/time_capsule_model.dart';
import '../presenter/time_capsule_presenter.dart';
import 'add_time_capsule_screen.dart';

class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({super.key});

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  final TimeCapsuleModel _model = TimeCapsuleModel();
  late final TimeCapsulePresenter _presenter;

  List<Map<String, dynamic>> _capsules = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter = TimeCapsulePresenter(
      model: _model,
      showLoading: () => setState(() => _isLoading = true),
      hideLoading: () => setState(() => _isLoading = false),
      showCapsules: (capsules) => setState(() {
        _capsules = capsules;
        _error = null;
      }),
      showError: (message) => setState(() => _error = message),
    );
    _presenter.loadCapsules();
  }

  void _showCapsuleDialog(String capsuleId, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your message from the past ✉️"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
              _presenter.openCapsule(capsuleId);
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} days';
    if (d.inHours > 0) return '${d.inHours} hours';
    if (d.inMinutes > 0) return '${d.inMinutes} minutes';
    return 'less than a minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time capsule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTimeCapsuleScreen()),
              );
              if (result == true) {
                _presenter.loadCapsules();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _capsules.isEmpty
          ? const Center(
              child: Text(
                "There is no time capsule to open yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _capsules.length,
              itemBuilder: (context, index) {
                final capsule = _capsules[index];
                final unlockAt = (capsule['unlockAt'] as Timestamp).toDate();
                final isUnlocked = capsule['isUnlocked'] as bool;
                final timeRemaining = capsule['timeRemaining'] as Duration;

                return ListTile(
                  title: isUnlocked
                      ? Text(capsule['message'])
                      : const Text("🔒 Capsule locked"),
                  subtitle: isUnlocked
                      ? const Text("¡You can open it!")
                      : Text("It unlocks in ${_formatDuration(timeRemaining)}"),
                  trailing: Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    color: isUnlocked ? Colors.green : Colors.grey,
                  ),
                  onTap: isUnlocked
                      ? () => _showCapsuleDialog(
                          capsule['id'],
                          capsule['message'],
                        )
                      : null,
                );
              },
            ),
    );
  }
}
