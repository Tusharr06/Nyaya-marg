import 'package:flutter/material.dart';

class KnowYourRightsHub extends StatefulWidget {
  const KnowYourRightsHub({super.key});

  @override
  State<KnowYourRightsHub> createState() => _KnowYourRightsHubState();
}

class _KnowYourRightsHubState extends State<KnowYourRightsHub> {
  int? expandedIndex;

  final List<Map<String, dynamic>> categories = [
    {
      "title": "Equality & Non-Discrimination",
      "subtitle": "Equal rights for all citizens",
      "details": "Articles 14–18 prevent discrimination by caste, religion, race, gender, and place of birth. Ensures equal opportunity in jobs and education. SC/ST (Prevention of Atrocities) Act provides special protection.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.balance,
    },
    {
      "title": "Freedom & Liberty",
      "subtitle": "Express yourself freely",
      "details": "Articles 19–22 guarantee freedom of speech, movement, association, and privacy. Includes rights in family life, marriage, and protection against unlawful arrest.",
      "color": const Color(0xFF112250),
      "icon": Icons.flight_takeoff,
    },
    {
      "title": "Protection from Exploitation",
      "subtitle": "Safety against abuse",
      "details": "Articles 23–24 protect from trafficking, forced labor, and child labor. Includes Domestic Violence Act, workplace harassment laws, and maternity protection rights.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.shield,
    },
    {
      "title": "Justice & Self-Defense",
      "subtitle": "Legal remedies available",
      "details": "Articles 32–35 provide constitutional remedies and court access. Right to self-defense under IPC Sections 96–106. Consumer Protection Act for refunds and compensation.",
      "color": const Color(0xFF112250),
      "icon": Icons.gavel,
    },
    {
      "title": "Cultural Freedom",
      "subtitle": "Preserve your heritage",
      "details": "Articles 25–30 protect cultural, educational, and religious freedoms. Rights for minorities to conserve language and culture. Freedom to establish educational institutions.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.auto_stories,
    },
    {
      "title": "Citizenship Rights",
      "subtitle": "Know your nationality laws",
      "details": "Covers Indian citizenship rules, nationality laws, simplified immigration under 2025 Bill, and Right to Information Act for government transparency.",
      "color": const Color(0xFF112250),
      "icon": Icons.badge,
    },
    {
      "title": "Right to Education",
      "subtitle": "Free education for children",
      "details": "Article 21A ensures free and compulsory education for children aged 6-14 years. Right to Education Act mandates quality standards and teacher qualifications.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.school,
    },
    {
      "title": "Labor Rights",
      "subtitle": "Fair treatment at work",
      "details": "Minimum wage laws, working hours regulations, safe working conditions, and protection against unfair dismissal. Includes maternity benefits and provident fund rights.",
      "color": const Color(0xFF112250),
      "icon": Icons.work,
    },
    {
      "title": "Consumer Protection",
      "subtitle": "Your rights as a buyer",
      "details": "Right to safety, information, choice, and redressal. Protection against defective products, unfair trade practices, and right to seek compensation.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.shopping_cart,
    },
    {
      "title": "Digital Rights",
      "subtitle": "Privacy in the digital age",
      "details": "Data protection laws, right to privacy online, protection against cyber crimes, and regulations on data collection and usage by companies.",
      "color": const Color(0xFF112250),
      "icon": Icons.smartphone,
    },
    {
      "title": "Environmental Rights",
      "subtitle": "Clean air and water",
      "details": "Right to a healthy environment, protection against pollution, access to clean water and air, and right to participate in environmental decisions.",
      "color": const Color(0xFFE0C58F),
      "icon": Icons.eco,
    },
    {
      "title": "Health Rights",
      "subtitle": "Access to healthcare",
      "details": "Right to health under Article 21, emergency medical care, mental health protection, and access to affordable medicines and treatment.",
      "color": const Color(0xFF112250),
      "icon": Icons.health_and_safety,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E9),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lightbulb, color: Color(0xFF112250), size: 28),
            SizedBox(width: 8),
            Text(
              "Know Your Rights Hub",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF112250),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: (categories.length / 2).ceil(),
          itemBuilder: (context, rowIndex) {
            final firstIndex = rowIndex * 2;
            final secondIndex = firstIndex + 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildCard(categories[firstIndex], firstIndex),
                    ),
                    const SizedBox(width: 12),
                    if (secondIndex < categories.length)
                      Expanded(
                        child: _buildCard(categories[secondIndex], secondIndex),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> category, int index) {
    final isExpanded = expandedIndex == index;
    final isDark = category["color"] == const Color(0xFF112250);

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: category["color"],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category["icon"] as IconData,
                  color: isDark ? Colors.white : const Color(0xFF112250),
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      category["title"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                category["subtitle"],
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category["details"],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}