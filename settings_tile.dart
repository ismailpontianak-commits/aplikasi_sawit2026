import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        child: Row(
          children: [
            // ================= ICON =================
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: const Color(0xFF3568C9),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Icon(icon, color: Colors.white, size: 22),
            ),

            const SizedBox(width: 14),

            // ================= TEXT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),

                    Text(
                      subtitle!,

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ================= TRAILING =================
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),

                child: Text(
                  trailingText!,

                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3568C9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
