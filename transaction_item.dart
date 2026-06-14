import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final String name;
  final String address;
  final String netto;

  const TransactionItem({
    super.key,
    required this.name,
    required this.address,
    required this.netto,
  });

  String get initials {
    if (name.trim().isEmpty) {
      return "?";
    }

    final parts = name.trim().split(' ');

    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [
          // ================= AVATAR =================
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: AppColors.avatarBlue,

              shape: BoxShape.circle,
            ),

            child: Center(
              child: Text(
                initials,

                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ================= CENTER =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ================= NAME =================
                Text(
                  name.trim().isEmpty ? 'Tanpa Nama' : name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 4),

                // ================= DATE =================
                Text(
                  address,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ================= RIGHT =================
          Row(
            children: [
              Text(
                netto,

                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 4),

              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.lightGrey,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
