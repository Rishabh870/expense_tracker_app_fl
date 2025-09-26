import 'package:expense_tracker_app_fl/models/Settlement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/colors.dart';
import '../../providers/settlement_providers.dart';
import '../../utils/RequestMethod.dart';
import '../../widgets/CustomAvatar.dart';

import 'package:dio/dio.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

// Mock data model for settlement
class SettlementItem {
  final int id;
  final String name;
  final String? phoneNumber;
  final double amount;
  final String type; // "owes_me" or "i_owe"
  final String? profileImage;

  SettlementItem({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.amount,
    required this.type,
    this.profileImage,
  });
}

class SettlementScreen extends ConsumerStatefulWidget {
  const SettlementScreen({super.key});

  @override
  ConsumerState<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends ConsumerState<SettlementScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettlements();
  }

  Future<void> _loadSettlements() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(settlementProvider.notifier).loadSettlements();
    } catch (e) {
      _showSnackBar('Failed to load settlements: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 1️⃣ Download PDF only
  Future<File> _downloadPDF(SettlementSummary settlement) async {
    try {
      // Request storage permission
      // final status = await Permission.storage.request().isGranted;
      // if (!status) {
      //   _showSnackBar('Storage permission denied', Colors.red);
      //   return File(""); // fallback empty file
      // }

      // Download PDF from API
      final response = await privateDio.get(
        '/settlement/download/${settlement.person.id}',
        options: Options(responseType: ResponseType.bytes),
      );

      // Get storage directory
      final directory = await getExternalStorageDirectory();
      final filePath =
          '${directory!.path}/settlement_${settlement.person.name!.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      _showSnackBar('PDF downloaded: $filePath', Colors.green);
      return file;
    } catch (e) {
      _showSnackBar('Failed to download PDF: $e', Colors.red);
      return File(""); // always return a File
    }
  }

// 2️⃣ WhatsApp share
  Future<void> _sendWhatsApp(SettlementSummary settlement) async {
    if (settlement.person.phoneNumber == null) {
      _showSnackBar('Phone number not available', Colors.orange);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Download PDF
      final pdfFile = await _downloadPDF(settlement);

      // Message
      final message = settlement.direction == DirectionEnum.RECEIVE
          ? "Hi ${settlement.person.name}, you owe me ₹${settlement.amount.toStringAsFixed(2)}. PDF attached."
          : "Hi ${settlement.person.name}, I owe you ₹${settlement.amount.toStringAsFixed(2)}. PDF attached.";

      // Share PDF + message via WhatsApp or any app
      final params = ShareParams(
        text: message,
        files: [XFile(pdfFile.path)],
      );

      await SharePlus.instance.share(params);
    } catch (e) {
      _showSnackBar('Failed to share via WhatsApp: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }


// 3️⃣ Send Email via API
  Future<void> _sendEmail(SettlementSummary settlement) async {
    try {
      final response = await privateDio.post('/settlement/send-alert/${settlement.person.id}');
      if (response.statusCode == 200) {
        _showSnackBar('Email sent successfully', Colors.green);
      } else {
        _showSnackBar('Failed to send email', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to send email: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settlementsAsync = ref.watch(settlementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: settlementsAsync.when(
        data: (settlements) {
          if (settlements.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              return _buildSettlementCard(settlement);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Failed to load settlements: $err'),
        ),
      ),
    );
  }


  Widget _buildSettlementCard(SettlementSummary settlement) {
    final isReceive = settlement.direction == DirectionEnum.RECEIVE;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CustomAvatar(
            name: settlement.person.name ?? "",
            size: 50,
            textSize: 18,
            borderRadius: 8,
          ),
          const SizedBox(width: 16),

          // Middle column: Name, Phone, Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settlement.person.name ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settlement.person.phoneNumber ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  settlement.person.email ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,           // restrict to one line
                  overflow: TextOverflow.ellipsis, // show ... if text too long
                )

              ],
            ),
          ),

          // Right column: Amount + buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isReceive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), // light accent background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isReceive ? "RECEIVE" : "PAY"} ₹${settlement.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isReceive ? Colors.green : Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () {_sendWhatsApp(settlement);}, // WhatsApp
                    child: const Icon(
                      FontAwesomeIcons.whatsapp,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {_sendEmail(settlement);}, // notification
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {_downloadPDF(settlement);}, // download PDF
                    child: const Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

}
