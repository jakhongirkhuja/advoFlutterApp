import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _typing = false;
  Timer? _replyTimer;
  String? _pendingPath;
  String? _pendingName;

  static const suggestions = [
    'Advokatlar kerak',
    'Huquqiy maslahat kerak',
    'Hujjat tayyorlash',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _replyTimer?.cancel();
    super.dispose();
  }

  void _send([String? suggestion]) {
    final text = (suggestion ?? _input.text).trim();
    if ((text.isEmpty && _pendingPath == null) || _typing) return;
    final pendingPath = _pendingPath;
    final pendingName = _pendingName;
    _input.clear();
    setState(() {
      _messages.add(
        _ChatMessage(
          text.isEmpty ? (pendingName ?? 'Fayl') : text,
          true,
          file: pendingPath != null,
          filePath: pendingPath,
        ),
      );
      _pendingPath = null;
      _pendingName = null;
      _typing = true;
    });
    _toBottom();
    _replyTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          _ChatMessage('Sizga mos advokatlarni topdim:', false, lawyers: true),
        );
      });
      _toBottom();
    });
  }

  Future<void> _attach() async {
    final type = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 272,
          padding: const EdgeInsets.only(bottom: 72,left: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AttachmentOption(
                    icon: 'assets/icons/camera_alt_outlined.svg',
                    label: 'Kamera',
                    onTap: () => Navigator.pop(context, 'Kamera'),
                  ),
                  _AttachmentOption(
                    icon: 'assets/icons/photo_outlined.svg',
                    label: 'Rasm',
                    onTap: () => Navigator.pop(context, 'Rasm'),
                  ),
                  _AttachmentOption(
                    icon: 'assets/icons/insert_drive_file_outlined.svg',
                    label: 'Fayl',
                    onTap: () => Navigator.pop(context, 'Fayl'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (type == null || !mounted) return;
    if (type == 'Kamera') {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null || !mounted) return;
      setState(() {
        _pendingPath = image.path;
        _pendingName = image.name;
      });
      return;
    }
    final file = await openFile(
      acceptedTypeGroups: type == 'Rasm'
          ? const [
              XTypeGroup(
                label: 'Images',
                extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
              ),
            ]
          : const [],
    );
    if (file == null || !mounted) return;
    setState(() {
      _pendingPath = file.path;
      _pendingName = file.name;
    });
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  void _newChat() {
    _replyTimer?.cancel();
    setState(() {
      _messages.clear();
      _typing = false;
      _pendingPath = null;
      _pendingName = null;
    });
  }

  Future<void> _showHistory() async {
    final selected = await showDialog<_HistoryItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eski suhbatlar'),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              _HistoryTile(
                item: _HistoryItem(
                  'Mehnat huquqi bo‘yicha maslahat',
                  '12.09.2026',
                ),
              ),
              _HistoryTile(
                item: _HistoryItem('Advokat qidirish', '08.09.2026'),
              ),
              _HistoryTile(
                item: _HistoryItem('Shartnoma tayyorlash', '01.09.2026'),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _messages
        ..clear()
        ..add(_ChatMessage(selected.title, true))
        ..add(
          const _ChatMessage(
            'Suhbat davom ettirildi. Savolingizni yozishingiz mumkin.',
            false,
          ),
        );
    });
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 54),
              child: Column(
                children: [
                  Expanded(
                    child: _messages.isEmpty
                        ? _Welcome(onSuggestion: _send)
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                            itemCount: _messages.length + (_typing ? 1 : 0),
                            itemBuilder: (_, index) => index == _messages.length
                                ? const _TypingBubble()
                                : _MessageBubble(message: _messages[index]),
                          ),
                  ),
                  _Composer(
                    controller: _input,
                    onAttach: _attach,
                    onSend: _send,
                    pendingPath: _pendingPath,
                    onRemovePending: () => setState(() {
                      _pendingPath = null;
                      _pendingName = null;
                    }),
                  ),
                ],
              ),
            ),
            HeaderScreen(
              title: 'ADVO AI',
              firstActionIconPath: 'assets/icons/plus.svg',
              secondActionIconPath: 'assets/icons/history.svg',
              onBackTap: () => Navigator.maybePop(context),
              onFirstActionTap: _newChat,
              onSecondActionTap: _showHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool user;
  final bool file;
  final bool lawyers;
  final String? filePath;

  const _ChatMessage(
    this.text,
    this.user, {
    this.file = false,
    this.lawyers = false,
    this.filePath,
  });
}

class _ChatHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ChatHeader({required this.onBack});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
    child: Row(
      children: [
        _HeaderButton(Icons.chevron_left, onBack),
        const Spacer(),
        const Text(
          'ADVO AI',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _HeaderButton(Icons.add, () {}),
        const SizedBox(width: 7),
        _HeaderButton(Icons.history, () {}),
      ],
    ),
  );
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 17)),
    ),
  );
}

class _HistoryItem {
  final String title;
  final String date;

  const _HistoryItem(this.title, this.date);
}

class _HistoryTile extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: const CircleAvatar(
      backgroundColor: Color(0xFFE8F2FF),
      child: Icon(
        Icons.chat_bubble_outline,
        color: AppTheme.primaryBlue,
        size: 18,
      ),
    ),
    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(item.date, style: const TextStyle(fontSize: 11)),
    onTap: () => Navigator.pop(context, item),
  );
}

class _Welcome extends StatelessWidget {
  final ValueChanged<String> onSuggestion;

  const _Welcome({required this.onSuggestion});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF67B4FF), Color(0xFF287FF0)],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(height: 9),
          const Text('ADVO AI', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          const Text(
            'Savollaringizga tezkor va tushunarli javoblar oling.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _AiChatScreenState.suggestions
                .map(
                  (text) => ActionChip(
                    label: Text(text, style: const TextStyle(fontSize: 11)),
                    avatar: const Icon(Icons.gavel, size: 14),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    onPressed: () => onSuggestion(text),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (message.lawyers) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.text, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          const _LawyerCard(),
          const SizedBox(height: 6),
          const _LawyerCard(),
        ],
      );
    } else if (message.file && message.filePath != null) {
      content = _FileAttachment(message: message);
    } else {
      content = RichText(
        text: TextSpan(
          text: message.file ? '📎 ${message.text}' : message.text,
          style: TextStyle(
            color: message.user ? Colors.white : const Color(0xFF172033),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      );
    }
    return Align(
      alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .80,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.user ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: content,
      ),
    );
  }
}

class _LawyerCard extends StatelessWidget {
  const _LawyerCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(7),

    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 74,
          height: 74,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.pageBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.network(
            'ssets/images/default_user.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 74,
              height: 74,
              color: AppTheme.avatarBackground,
              alignment: Alignment.center,
              child: Image.asset('assets/images/default_user.jpg'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Javohir Mamatov',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0F172A),
                ),
              ),
              Wrap(
                children: [
                  const Text(
                    'Yuridik maslahatchi',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textChoco,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.pageBackground,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '5 yil tajriba',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textChoco,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/star.svg'),
                  const SizedBox(width: 4),
                  Text(
                    '4.6',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '(89 ta sharh)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xff475569),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        '•••',
        style: TextStyle(color: AppTheme.primaryBlue, letterSpacing: 3),
      ),
    ),
  );
}

class _FileAttachment extends StatelessWidget {
  final _ChatMessage message;

  const _FileAttachment({required this.message});

  Future<void> _open() async {
    await launchUrl(
      Uri.file(message.filePath!),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = message.filePath!;
    final isImage = RegExp(
      r'\.(png|jpe?g|gif|webp)$',
      caseSensitive: false,
    ).hasMatch(path);
    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            )
          else
            const Icon(Icons.insert_drive_file_outlined, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final String? pendingPath;
  final VoidCallback onRemovePending;

  const _Composer({
    required this.controller,
    required this.onAttach,
    required this.onSend,
    required this.pendingPath,
    required this.onRemovePending,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
    child: Container(
      height: pendingPath == null ? 48 : 164,
      padding: pendingPath == null
          ? const EdgeInsets.fromLTRB(12, 4, 4, 4)
          : const EdgeInsets.fromLTRB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF2B7FFF), width: 1),
        borderRadius: BorderRadius.circular(54),
      ),
      child: Column(
        children: [
          if (pendingPath != null)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(pendingPath!),
                        width: 102,
                        height: 102,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 102,
                          height: 102,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.insert_drive_file_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: InkWell(
                        onTap: onRemovePending,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: onAttach,
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: const InputDecoration(
                      hintText: 'Bo‘sh qoldiring',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      size: 22,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _AttachmentOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F6FC),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(icon),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xff0F172A))),
        ],
      ),
    ),
  );
}
