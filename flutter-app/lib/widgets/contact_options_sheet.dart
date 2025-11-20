import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/luxury_theme.dart';

class ContactOptionsSheet extends StatelessWidget {
  final String contactInfo;
  final String ownerName;

  const ContactOptionsSheet({
    super.key,
    required this.contactInfo,
    required this.ownerName,
  });

  String _formatPhoneForWhatsApp(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Ensure it starts with country code
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return cleaned;
    }
    if (cleaned.length == 10) {
      return '91$cleaned';
    }
    return cleaned;
  }

  Future<void> _makePhoneCall() async {
    final Uri telUri = Uri(scheme: 'tel', path: contactInfo);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }

  Future<void> _sendSMS() async {
    final Uri smsUri = Uri(scheme: 'sms', path: contactInfo);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> _openWhatsApp() async {
    final String formattedPhone = _formatPhoneForWhatsApp(contactInfo);
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhone');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LuxuryColors.mainBackground,
            LuxuryColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LuxuryColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: LuxuryColors.mainBackground,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Owner',
                      style: LuxuryTextStyles.h3.copyWith(
                        color: LuxuryColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ownerName,
                      style: LuxuryTextStyles.bodyLarge.copyWith(
                        color: LuxuryColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: LuxuryColors.mutedText),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Number Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LuxuryColors.mainBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LuxuryColors.primaryGold.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  color: LuxuryColors.primaryGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  contactInfo,
                  style: LuxuryTextStyles.bodyLarge.copyWith(
                    color: LuxuryColors.headingText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options Title
          Text(
            'Choose contact method',
            style: LuxuryTextStyles.bodyMedium.copyWith(
              color: LuxuryColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),

          // Call Button
          _ContactButton(
            icon: Icons.phone,
            label: 'Phone Call',
            subtitle: 'Make a direct call',
            color: Colors.green,
            onPressed: _makePhoneCall,
          ),
          const SizedBox(height: 12),

          // SMS Button
          _ContactButton(
            icon: Icons.message,
            label: 'Send SMS',
            subtitle: 'Send a text message',
            color: Colors.blue,
            onPressed: _sendSMS,
          ),
          const SizedBox(height: 12),

          // WhatsApp Button
          _ContactButton(
            icon: Icons.chat,
            label: 'WhatsApp',
            subtitle: 'Chat on WhatsApp',
            color: const Color(0xFF25D366),
            onPressed: _openWhatsApp,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: LuxuryTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LuxuryColors.headingText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: LuxuryTextStyles.bodySmall.copyWith(
                        color: LuxuryColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
