import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'edit_entry_view.dart';
import '../presenter/journal_presenter.dart';

class JournalEntryDetailView extends StatefulWidget {
  final DateTime date;
  final String content;
  final String mood;
  final Map<String, dynamic>? fullEntry;

  const JournalEntryDetailView({
    super.key,
    required this.date,
    required this.content,
    required this.mood,
    this.fullEntry,
  });

  @override
  State<JournalEntryDetailView> createState() => _JournalEntryDetailViewState();
}

class _JournalEntryDetailViewState extends State<JournalEntryDetailView> {
  late final JournalPresenter _presenter;
  String? _foodRecommendation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _presenter = JournalPresenter();
    _loadFoodRecommendation();
  }

  Future<void> _loadFoodRecommendation() async {
    final recommendation = await _presenter.analyzeAndGetFood(
      widget.content,
      widget.mood,
    );
    setState(() {
      _foodRecommendation = recommendation;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM y').format(widget.date);

    return Scaffold(
      backgroundColor: const Color(0xFFD3DBDD),
      appBar: AppBar(
        title: const Text(
          'Entry Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 236, 232),
          ),
        ),
        backgroundColor: const Color(0xFF3B4D65),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 238, 236, 232),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF011C45),
              ),
            ),
            const SizedBox(height: 24),

            // Cuadro fijo con texto
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 238, 236, 232).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.content,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Color(0xFF011C45),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cuadro para Food Recommendation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 238, 236, 232).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Food Recommendation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011C45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _foodRecommendation ?? 'No recommendation available',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF3B4D65),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (widget.fullEntry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Edit Entry',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B4D65),
                    foregroundColor: Color.fromARGB(255, 238, 236, 232),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    final didUpdate = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEntryView(entry: widget.fullEntry!),
                      ),
                    );
                    if (didUpdate == true) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
