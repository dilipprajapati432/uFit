import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  int _aiTokens = 3;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    AdService.loadRewardedAd();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final tokens = await AdService.getAiTokens();
    if (mounted) setState(() => _aiTokens = tokens);
  }

  void _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('coach_messages');
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _messages.addAll(decoded.map((e) => Map<String, String>.from(e)));
      } catch (e) {
        // Ignore parsing errors
      }
    }

    if (_messages.isEmpty) {
      _messages.add({
        "role": "assistant",
        "content": "Hi there! 👋 I'm uFit AI. How can I help you reach your fitness goals today?",
        "animate": "true",
      });
      _saveMessages();
    } else {
      // Remove animate flag from old messages so they don't pop in every time
      for (var m in _messages) {
        m.remove('animate');
      }
    }
    
    if (mounted) {
      setState(() {});
      // Scroll to bottom after initial render
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        }
      });
    }
  }

  void _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = _messages.length > 50 ? _messages.sublist(_messages.length - 50) : _messages;
    prefs.setString('coach_messages', jsonEncode(toSave));
  }

  Future<void> _processMessage(String text) async {
    _textCtrl.clear();
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _saveMessages();
    _scrollToBottom();

    final response = await AiService.chatWithCoach(_messages);
    
    if (mounted) {
      setState(() {
        _messages.add({"role": "assistant", "content": response, "animate": "true"});
        _isLoading = false;
      });
      _saveMessages();
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    final isPremium = ref.read(premiumProvider);

    if (isPremium) {
      await _processMessage(text);
      return;
    }

    // Not premium, check tokens
    if (_aiTokens > 0) {
      await AdService.useAiToken();
      await _loadTokens(); // refresh count
      await _processMessage(text);
    } else {
      // Out of tokens, prompt to watch an ad
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.surface,
          title: const Row(
            children: [
              Icon(Icons.videocam_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Out of Free Messages'),
            ],
          ),
          content: const Text('You have used all your free AI tokens. Watch a short video ad to earn 3 more messages, or upgrade to Pro for unlimited, ad-free AI coaching.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAdToEarnTokens();
              },
              child: const Text('Watch Ad'),
            ),
          ],
        ),
      );
    }
  }

  void _showAdToEarnTokens() {
    setState(() => _isLoading = true);
    AdService.showRewardedAd(
      onRewardEarned: () async {
        await AdService.addAiTokens(3);
        await _loadTokens();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You earned 3 AI tokens!'), backgroundColor: AppColors.success),
          );
        }
      },
      onAdClosed: () {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                children: const [
                  TextSpan(text: 'u', style: TextStyle(color: Color(0xFFFF8552))),
                  TextSpan(text: 'Fit AI ✨'),
                ],
              ),
            ),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.electric_bolt, color: AppColors.primary, size: 12),
                    const SizedBox(width: 4),
                    Text('$_aiTokens', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _ChatBubble(
                  content: msg['content']!,
                  isUser: isUser,
                  shouldAnimateTyping: msg['animate'] == 'true',
                  onAnimationComplete: () {
                    if (msg['animate'] == 'true') {
                      msg['animate'] = 'false';
                      _scrollToBottom();
                    }
                  },
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypingIndicator(),
              ),
            ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask uFit AI...',
                hintStyle: TextStyle(color: context.textMuted),
                filled: true,
                fillColor: context.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 16),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool shouldAnimateTyping;
  final VoidCallback? onAnimationComplete;

  const _ChatBubble({
    required this.content, 
    required this.isUser, 
    this.shouldAnimateTyping = false,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    Widget bubble = Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : context.surface,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
        border: isUser ? null : Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: _TypewriterText(
        text: content,
        animate: shouldAnimateTyping,
        onFinished: onAnimationComplete,
        style: TextStyle(
          color: isUser ? Colors.white : context.text,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12, right: 8, left: 4),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.robot, color: Colors.white, size: 14),
              ),
            ),
            Flexible(child: bubble),
          ],
        ),
      );
    }
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool animate;
  final VoidCallback? onFinished;

  const _TypewriterText({
    required this.text, 
    required this.style, 
    this.animate = false, 
    this.onFinished,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _startTyping();
    } else {
      _displayedText = widget.text;
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_currentIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.text.substring(0, _currentIndex);
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          widget.onFinished?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: const Radius.circular(4),
        ),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0),
          const SizedBox(width: 4),
          _buildDot(200),
          const SizedBox(width: 4),
          _buildDot(400),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .fade(begin: 0.3, end: 1.0, duration: 400.ms, delay: delay.ms)
     .then()
     .fade(begin: 1.0, end: 0.3, duration: 400.ms)
     .then(delay: (800 - delay).ms);
  }
}
