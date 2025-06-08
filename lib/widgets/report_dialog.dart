import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  final TextEditingController customReasonController = TextEditingController();

  @override
  void dispose() {
    customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarningMessage(),
                    
                    const SizedBox(height: 16),
                    
                    // Report options
                    _buildReportOption(
                      icon: Icons.block,
                      iconColor: Colors.red,
                      title: 'Konten tidak pantas/vulgar',
                      subtitle: 'Konten mengandung unsur vulgar, tidak senonoh, atau tidak pantas',
                      value: 'Konten tidak pantas/vulgar',
                    ),

                    _buildReportOption(
                      icon: Icons.campaign,
                      iconColor: Colors.orange,
                      title: 'Spam atau konten berulang',
                      subtitle: 'Konten yang diposting berulang kali atau merupakan spam',
                      value: 'Spam atau konten berulang',
                    ),

                    _buildReportOption(
                      icon: Icons.error,
                      iconColor: Colors.red[700]!,
                      title: 'Informasi palsu/menyesatkan',
                      subtitle: 'Konten mengandung informasi yang tidak benar atau menyesatkan',
                      value: 'Informasi palsu/menyesatkan',
                    ),

                    _buildReportOption(
                      icon: Icons.sentiment_very_dissatisfied,
                      iconColor: Colors.red[800]!,
                      title: 'Ujaran kebencian/diskriminasi',
                      subtitle: 'Konten mengandung ujaran kebencian atau diskriminasi',
                      value: 'Ujaran kebencian/diskriminasi',
                    ),

                    _buildReportOption(
                      icon: Icons.school,
                      iconColor: Colors.blue,
                      title: 'Melanggar aturan kampus',
                      subtitle: 'Konten melanggar aturan atau kebijakan kampus',
                      value: 'Melanggar aturan kampus',
                    ),

                    _buildReportOption(
                      icon: Icons.more_horiz,
                      iconColor: Colors.grey[600]!,
                      title: 'Lainnya',
                      subtitle: 'Alasan lain yang tidak tercantum di atas',
                      value: 'Lainnya',
                    ),

                    // Custom reason text field (shown when "Lainnya" is selected)
                    if (selectedReason == 'Lainnya') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customReasonController,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan alasan Anda...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Final warning message
                    _buildFinalWarning(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.flag,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Laporkan Postingan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Pilih alasan yang paling sesuai untuk melaporkan postingan ini:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning,
            color: Colors.orange[700],
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Peringatan:\nLaporan palsu atau penyalahgunaan fitur pelaporan dapat mengakibatkan sanksi pada akun Anda.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: selectedReason == null ? null : () {
              String finalReason = selectedReason!;
              if (selectedReason == 'Lainnya' && customReasonController.text.trim().isNotEmpty) {
                finalReason = customReasonController.text.trim();
              }
              Navigator.pop(context, finalReason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey,
            ),
            child: const Text(
              'Kirim Laporan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedReason == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => selectedReason = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.red.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: selectedReason,
                onChanged: (value) => setState(() => selectedReason = value),
                activeColor: Colors.red,
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.red[700] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
