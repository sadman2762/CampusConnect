// lib/screens/discussions/summary_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // If using Firebase Functions

class SummaryScreen extends StatefulWidget {
  final String prompt;
  const SummaryScreen({super.key, required this.prompt});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _summary = 'Generating summary...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('chatWithGemini');

      final result = await callable.call(<String, dynamic>{
        'prompt': 'Summarize the following discussion:\n\n${widget.prompt}',
      });

      final reply = result.data['reply'] as String?;
      setState(() {
        _summary = reply ?? 'No summary returned.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _summary = '❌ Failed to fetch summary.\n\nError: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4TY summarizer'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black87,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _summary,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 4TY - all rights reserved',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
