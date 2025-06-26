import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../services/gemini_service.dart';
import '../../utils/markdown_utils.dart';
import '../profile/profile_screen.dart';

class AIChatScreen extends StatefulWidget {
  static const routeName = '/ai_chat';
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _messages = ['Hello! How can I assist you today?'];
  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();
  bool _isLoading = false;
  List<String> _previousSearches = [];

  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _loadPreviousSearches();
  }

  Future<void> _loadPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('previous_searches') ?? [];
    setState(() => _previousSearches = data);
  }

  Future<void> _saveSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_previousSearches.contains(query)) {
      _previousSearches.insert(0, query);
      if (_previousSearches.length > 50) {
        _previousSearches = _previousSearches.sublist(0, 50);
      }
      await prefs.setStringList('previous_searches', _previousSearches);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(text);
      _controller.clear();
      _isLoading = true;
    });

    await _saveSearch(text);
    final reply = await _gemini.sendPrompt(text);

    setState(() {
      _isLoading = false;
      _messages.add(reply);
    });
  }

  final List<String> _models = [
    '4TY Math',
    '4TY Code',
    '4TY General',
    '4TY FAQ',
    '4TY Webtech',
    '4TY HLPL2',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).copyWith(disabledColor: Colors.grey.shade400);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildPreviousSearchesDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Text(
                '4TY',
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalised AI assistant for Unideb student',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    if (i == _messages.length && _isLoading) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(right: 80),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final msg = _messages[i];
                    final isUser = i.isOdd;
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isUser ? 80 : 0,
                          right: isUser ? 0 : 80,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stripMd(msg),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Send a message…',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: Colors.white,
        onPressed: () {},
        child: const Text(
          '4TY',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
              ),
              IconButton(
                icon: const Icon(Icons.model_training_outlined),
                onPressed: _showModelPicker,
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.history_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () =>
                    Navigator.pushNamed(context, ProfileScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModelPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for models…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (q) {},
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _models.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => ListTile(
                  title: Text(_models[i]),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedModel = _models[i];
                      _messages.clear();
                      _messages.add('Welcome to ${_models[i]} Chatbot');
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildPreviousSearchesDrawer() => Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Previous Searches',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _previousSearches.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(_previousSearches[i]),
                    onTap: () {
                      Navigator.pop(context);
                      _sendMessage(_previousSearches[i]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
