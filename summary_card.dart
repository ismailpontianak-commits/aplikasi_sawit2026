import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String totalValue;
  final String totalLabel;

  final String title1;
  final String value1;
  final IconData icon1;

  final String title2;
  final String value2;
  final IconData icon2;

  final String title3;
  final String value3;
  final IconData icon3;

  const SummaryCard({
    super.key,
    required this.totalValue,
    required this.totalLabel,
    required this.title1,
    required this.value1,
    required this.icon1,
    required this.title2,
    required this.value2,
    required this.icon2,
    required this.title3,
    required this.value3,
    required this.icon3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF3568C8),
                size: 18,
              ),

              const SizedBox(width: 6),

              const Expanded(
                child: Text(
                  "Ringkasan Hari Ini",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ================= CARD UTAMA =================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFF3568C8),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        totalValue,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "Total Bruto Masuk",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(icon: icon1, title: title1, value: value1),
              ),

              Container(width: 1, height: 42, color: Colors.grey.shade300),

              Expanded(
                child: _SummaryItem(icon: icon2, title: title2, value: value2),
              ),

              Container(width: 1, height: 42, color: Colors.grey.shade300),

              Expanded(
                child: _SummaryItem(icon: icon3, title: title3, value: value3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FB),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3568C8),
            ),
          ),
        ),
      ],
    );
  }
}
