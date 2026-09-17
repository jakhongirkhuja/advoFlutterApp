// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import '../../../../core/localization/app_localizations.dart';
// import '../../../../core/theme/app_theme.dart';
// import '../../../widgets/custom_header.dart';
// import '../viewmodels/services_viewmodel.dart';
//
// class AiAssistantScreen extends StatefulWidget {
//   const AiAssistantScreen({super.key});
//
//   @override
//   State<AiAssistantScreen> createState() => _AiAssistantScreenState();
// }
//
// class _AiAssistantScreenState extends State<AiAssistantScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _sendMessage() {
//     if (_textController.text.trim().isNotEmpty) {
//       final vm = context.read<ServicesViewModel>();
//       vm.addAiMessage(AiMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         text: _textController.text,
//         type: AiMessageType.text,
//         isUser: true,
//         timestamp: DateTime.now(),
//       ));
//       _textController.clear();
//       setState(() {});
//       _scrollToBottom();
//     }
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null && mounted) {
//       final vm = context.read<ServicesViewModel>();
//       final path = result.files.single.path!;
//       final name = result.files.single.name;
//       final extension = name.split('.').last.toLowerCase();
//
//       AiMessageType type = AiMessageType.file;
//       if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
//         type = AiMessageType.image;
//       } else if (['mp4', 'mov', 'avi', 'mkv', '3gp'].contains(extension)) {
//         type = AiMessageType.video;
//       } else if (['mp3', 'm4a', 'wav', 'ogg'].contains(extension)) {
//         type = AiMessageType.audio;
//       }
//
//       vm.addAiMessage(AiMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         type: type,
//         fileUrls: [path],
//         fileName: name,
//         isUser: true,
//         timestamp: DateTime.now(),
//       ));
//       _scrollToBottom();
//     }
//   }
//
//   void _startRecording() {
//     context.read<ServicesViewModel>().startAiRecording();
//   }
//
//   void _stopRecording() {
//     context.read<ServicesViewModel>().stopAiRecording();
//     _scrollToBottom();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<ServicesViewModel>();
//     final localizations = AppLocalizations.of(context);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Column(
//         children: [
//
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(20),
//               itemCount: vm.aiMessages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessageItem(
//                   vm.aiMessages[index],
//                   localizations,
//                 );
//               },
//             ),
//           ),
//           _buildInputArea(vm, localizations),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageItem(
//     AiMessage message,
//     AppLocalizations? localizations,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!message.isUser)
//             Container(
//               margin: const EdgeInsets.only(right: 8, bottom: 4),
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(
//                 color: Color(0xFF0056B3),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
//             ),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
//               decoration: BoxDecoration(
//                 color: message.isUser ? const Color(0xFF0056B3) : Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(16),
//                   topRight: const Radius.circular(16),
//                   bottomLeft: Radius.circular(message.isUser ? 16 : 4),
//                   bottomRight: Radius.circular(message.isUser ? 4 : 16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (message.type == AiMessageType.audio)
//                     _AiAudioMessageBubble(message: message)
//                   else if (message.type == AiMessageType.video)
//                     _AiVideoMessageBubble(message: message)
//                   else if (message.type == AiMessageType.image)
//                     _buildImageItem(message)
//                   else if (message.type == AiMessageType.file)
//                     _buildFileItem(message, localizations)
//                   else
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Flexible(
//                           child: Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: Text(
//                               message.text,
//                               style: TextStyle(
//                                 color: message.isUser ? Colors.white : Colors.black87,
//                                 fontSize: 15,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Text(
//                           DateFormat('HH:mm').format(message.timestamp),
//                           style: TextStyle(
//                             color: message.isUser ? Colors.white70 : Colors.grey,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageItem(AiMessage message) {
//     if (message.fileUrls.isEmpty) return const SizedBox.shrink();
//     final url = message.fileUrls.first;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: url.startsWith('http')
//               ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
//               : Image.file(File(url), fit: BoxFit.cover),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           DateFormat('HH:mm').format(message.timestamp),
//           style: TextStyle(color: message.isUser ? Colors.white70 : Colors.grey, fontSize: 10),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFileItem(
//     AiMessage message,
//     AppLocalizations? localizations,
//   ) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(Icons.insert_drive_file, color: message.isUser ? Colors.white70 : Colors.grey, size: 20),
//         const SizedBox(width: 8),
//         Flexible(
//           child: Text(
//             message.fileName ?? (localizations?.translate('document') ?? 'Document'),
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(color: message.isUser ? Colors.white : Colors.black87, fontSize: 14),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           DateFormat('HH:mm').format(message.timestamp),
//           style: TextStyle(
//             color: message.isUser ? Colors.white70 : Colors.grey,
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInputArea(
//     ServicesViewModel vm,
//     AppLocalizations? localizations,
//   ) {
//     final bool isEmpty = _textController.text.trim().isEmpty;
//
//     return Padding(
//       padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _pickFile,
//             child: Container(
//               width: 44,
//               height: 44,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(44),
//                 color: Colors.white,
//               ),
//               child: SvgPicture.asset('assets/icons/link.svg'),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: TextField(
//                 controller: _textController,
//                 onChanged: (text) => setState(() {}),
//                 decoration: InputDecoration(
//                   hintText:
//                       localizations?.translate('type_message') ?? 'Type a message',
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
//                   hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
//                   border: InputBorder.none,
//                   isDense: true,
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           GestureDetector(
//             onTap: isEmpty ? null : _sendMessage,
//             onLongPress: isEmpty ? _startRecording : null,
//             onLongPressUp: isEmpty ? _stopRecording : null,
//             child: Container(
//               width: 48,
//               height: 48,
//               padding: isEmpty ? const EdgeInsets.all(8) : EdgeInsets.zero,
//               decoration: BoxDecoration(
//                 color: vm.isRecordingAi ? Colors.red : Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: vm.isRecordingAi
//                     ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10)]
//                     : null,
//               ),
//               child: isEmpty
//                   ? SvgPicture.asset(
//                       'assets/icons/micro.svg',
//                       width: 24, height: 24, fit: BoxFit.contain,
//                       colorFilter: vm.isRecordingAi ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
//                     )
//                   : Icon(
//                       Icons.send,
//                       color: AppTheme.primaryBlue,
//                       size: 24,
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AiAudioMessageBubble extends StatefulWidget {
//   final AiMessage message;
//   const _AiAudioMessageBubble({required this.message});
//
//   @override
//   State<_AiAudioMessageBubble> createState() => _AiAudioMessageBubbleState();
// }
//
// class _AiAudioMessageBubbleState extends State<_AiAudioMessageBubble> {
//   final _player = AudioPlayer();
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//     _player.setReleaseMode(ReleaseMode.stop);
//     _player.setAudioContext(AudioContext(
//       android: AudioContextAndroid(
//         usageType: AndroidUsageType.media,
//         contentType: AndroidContentType.music,
//         audioFocus: AndroidAudioFocus.gain,
//       ),
//       iOS: AudioContextIOS(
//         category: AVAudioSessionCategory.playAndRecord,
//         options: {
//           AVAudioSessionOptions.mixWithOthers,
//           AVAudioSessionOptions.defaultToSpeaker,
//         },
//       ),
//     ));
//     _player.onDurationChanged.listen((d) => setState(() => _duration = d));
//     _player.onPositionChanged.listen((p) => setState(() => _position = p));
//     _player.onPlayerComplete.listen((_) => setState(() => _isPlaying = false));
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
//
//   void _playPause() async {
//     try {
//       if (_isPlaying) {
//         await _player.pause();
//         setState(() => _isPlaying = false);
//       } else {
//         if (widget.message.fileUrls.isEmpty) return;
//         final url = widget.message.fileUrls.first;
//         Source source;
//         if (url.startsWith('http')) {
//           source = UrlSource(url);
//         } else {
//           if (!await File(url).exists()) return;
//           source = DeviceFileSource(url);
//         }
//         await _player.play(source);
//         setState(() => _isPlaying = true);
//       }
//     } catch (e) {
//       debugPrint('AI Audio Playback Error: $e');
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isMe = widget.message.isUser;
//     return SizedBox(
//       width: 250,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: _playPause,
//                 child: Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: isMe ? Colors.white24 : AppTheme.primaryBlue.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: isMe ? Colors.white : AppTheme.primaryBlue,
//                     size: 24,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     trackHeight: 2,
//                     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//                     activeTrackColor: isMe ? Colors.white : AppTheme.primaryBlue,
//                     inactiveTrackColor: isMe ? Colors.white24 : Colors.grey[300],
//                     thumbColor: isMe ? Colors.white : AppTheme.primaryBlue,
//                   ),
//                   child: Slider(
//                     value: _position.inSeconds.toDouble(),
//                     max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
//                     onChanged: (v) {
//                       _player.seek(Duration(seconds: v.toInt()));
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 48),
//                 child: Text(
//                   '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
//                   style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
//                 ),
//               ),
//               Text(
//                 DateFormat('HH:mm').format(widget.message.timestamp),
//                 style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AiVideoMessageBubble extends StatefulWidget {
//   final AiMessage message;
//   const _AiVideoMessageBubble({required this.message});
//
//   @override
//   State<_AiVideoMessageBubble> createState() => _AiVideoMessageBubbleState();
// }
//
// class _AiVideoMessageBubbleState extends State<_AiVideoMessageBubble> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   bool _isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initVideo();
//   }
//
//   void _initVideo() async {
//     try {
//       final url = widget.message.fileUrls.first;
//       if (url.startsWith('http')) {
//         _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
//       } else {
//         _videoController = VideoPlayerController.file(File(url));
//       }
//
//       await _videoController!.initialize();
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: false,
//         looping: false,
//         aspectRatio: _videoController!.value.aspectRatio,
//         placeholder: Container(color: Colors.black12),
//       );
//
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       debugPrint('AI Video Init Error: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return Container(
//         height: 150,
//         width: 250,
//         decoration: BoxDecoration(
//           color: Colors.black12,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Container(
//           height: 200,
//           width: 250,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Chewie(controller: _chewieController!),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           DateFormat('HH:mm').format(widget.message.timestamp),
//           style: TextStyle(color: widget.message.isUser ? Colors.white70 : Colors.grey, fontSize: 10),
//         ),
//       ],
//     );
//   }
// }
