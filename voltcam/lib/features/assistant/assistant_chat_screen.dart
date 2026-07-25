import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? language;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.language = 'FR',
  });
}

class AssistantChatScreen extends ConsumerStatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  ConsumerState<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends ConsumerState<AssistantChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedLanguage = 'FR'; // FR, EN, PIDGIN

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg-1',
      text: 'Bonjour ! Je suis l\'Assistant IA VoltCam. Je surveille en temps réel le réseau électrique et vos boîtiers IoT.\n\nPosez-moi une question en Français, English ou Pidgin !',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<String> _suggestedPrompts = [
    "Est-ce qu'il y a une coupure à Biyem-Assi ?",
    "What is my current risk level?",
    "Conseils pour mon réfrigérateur",
    "Light de chop for Akwa zone?",
  ];

  // Gemini API instance
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    const apiKey = 'AQ.Ab8RN6LdbolLASxZqLcFOIVVFHGKgO_sPgjvQrHOz47pQFCaYQ.';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system("Vous êtes l'Assistant IA VoltCam. Vous surveillez le réseau électrique au Cameroun. Si on vous pose une question en français, répondez en français. Si c'est en anglais, en anglais. Si c'est en pidgin, en pidgin (Camfranglais). Donnez des conseils de sécurité électrique, parlez de GridTrust et de Protect Mode."),
    );
    _chatSession = _model.startChat(history: []);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      language: _selectedLanguage,
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(userMsg.text));
      final responseText = response.text ?? "Désolé, je n'ai pas pu générer de réponse.";
      
      final aiMsg = ChatMessage(
        id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        language: _selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
            id: 'err-${DateTime.now().millisecondsSinceEpoch}',
            text: "Erreur IA : ${e.toString().replaceAll('AQ.Ab8RN6LdbolLASxZqLcFOIVVFHGKgO_sPgjvQrHOz47pQFCaYQ.', '[API_KEY_CACHÉE]')}",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('assistant_screen_scaffold'),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_rounded, color: AppColors.electricCyan, size: 24),
            SizedBox(width: 8),
            Text('Assistant IA VoltCam'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language_rounded, color: AppColors.electricCyan),
            onSelected: (lang) {
              setState(() {
                _selectedLanguage = lang;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Langue choisie : $lang')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'FR', child: Text('Français (FR)')),
              PopupMenuItem(value: 'EN', child: Text('English (EN)')),
              PopupMenuItem(value: 'PIDGIN', child: Text('Pidgin (Camfranglais)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector & Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: AppColors.electricCyan, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode IA : Multi-Lingue ($_selectedLanguage) — GridTrust AI Online',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const GlassBadge(
                    label: 'v2.4 Live',
                    fontSize: 10,
                    color: AppColors.successGreen,
                  ),
                ],
              ),
            ),
          ),

          // Message Bubbles List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Suggested Prompts Horizontal Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _suggestedPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(fontSize: 12, color: AppColors.electricCyan),
                    ),
                    backgroundColor: AppColors.surfaceLight.withOpacity(0.6),
                    side: const BorderSide(color: AppColors.electricCyan, width: 0.8),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Chat Input Row
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceLight,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Posez votre question sur le réseau...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.electricCyan),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.electricCyan,
                child: Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                fillColor: isUser ? AppColors.electricCyan : AppColors.surfaceLight,
                opacity: isUser ? 0.9 : 1.0,
                borderColor: isUser ? AppColors.electricCyan : AppColors.glassBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.voltYellow,
                child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
