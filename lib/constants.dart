import 'package:flutter/material.dart';

const Color kPrimary = Color.fromARGB(255, 56, 112, 202);
const Color kSecondary = Color.fromARGB(255, 27, 18, 153);
const Color kAccent = Color(0xFFF2A900);

const LinearGradient kGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const List<String> kCategories = [
  'Aplikasi Mobile',
  'Website',
  'Desain UI/UX',
  'IoT / Hardware',
  'Data & AI',
  'Lainnya',
];

const List<String> kTechnologies = [
  'Flutter',
  'Laravel',
  'React',
  'Python',
  'Arduino',
  'Figma',
  'Lainnya',
];

String formatDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '-';
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}
