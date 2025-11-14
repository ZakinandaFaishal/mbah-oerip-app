import 'package:flutter/material.dart';
import '../theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _Header(),
            SizedBox(height: 12),
            _SectionCard(
              title: 'Kesan Selama Mengikuti Mata Kuliah',
              icon: Icons.emoji_emotions_outlined,
              child: Text(
                'Selama mengikuti mata kuliah Pemrograman Aplikasi Mobile (PAM), saya mendapatkan pengalaman '
                'transformatif serta pengetahuan fundamental dan praktis mengenai bagaimana sebuah aplikasi modern '
                'dirancang, dibangun, dan dioperasikan pada perangkat mobile. Mata kuliah ini berjalan dengan sangat '
                'menarik dan terasa cukup menantang, karena keseimbangan yang tepat antara penyampaian teori dan '
                'praktik langsung. Metode ini memungkinkan saya untuk tidak hanya "tahu", tetapi juga "bisa" '
                'mengimplementasikan alur kerja pengembangan aplikasi secara end-to-end, mulai dari ide hingga '
                'menjadi produk fungsional.',
                style: TextStyle(height: 1.5),
              ),
            ),
            SizedBox(height: 12),
            _SectionCard(
              title: 'Saran untuk Pengembangan Mata Kuliah',
              icon: Icons.lightbulb_outline,
              child: _SuggestionList(),
            ),
            SizedBox(height: 12),
            _SectionCard(
              title: 'Ucapan Terima Kasih',
              icon: Icons.favorite_border,
              child: Text(
                'Pada kesempatan ini, saya ingin mengucapkan terima kasih yang sebesar-besarnya kepada '
                'Bapak Bagus Muhammad Akbar, S.ST., M.Kom., selaku dosen pengampu. Bimbingan, kesabaran, dan '
                'penjelasan yang jelas serta terstruktur selama perkuliahan sangat membantu saya dalam memahami '
                'materi yang kompleks.\n\n'
                'Tidak lupa, saya juga berterima kasih kepada rekan-rekan dan teman-teman atas lingkungan belajar '
                'yang kolaboratif. Sesi diskusi, kerja sama, dan kesediaan untuk saling membantu, baik di dalam maupun '
                'di luar jam perkuliahan, membuat proses belajar yang menantang ini menjadi jauh lebih ringan, '
                'menyenangkan, dan bermakna.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryOrange.withOpacity(.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            CircleAvatar(
              backgroundColor: AppTheme.primaryOrange,
              child: Icon(Icons.rate_review, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Saran & kesan untuk mata kuliah Pemrograman Aplikasi Mobile',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList();

  @override
  Widget build(BuildContext context) {
    final suggestions = <String>[
      'Saran dari saya agar pada perkuliahan berikutnya diberikan lebih banyak contoh studi kasus yang mendekati kebutuhan pengembangan aplikasi di dunia nyata, serta kesempatan untuk melakukan mini project secara bertahap sehingga mahasiswa dapat lebih terarah dalam memahami alur pengembangan aplikasi dari awal hingga akhir. Dengan demikian, materi yang telah disampaikan tidak hanya dipahami secara teori, tetapi juga lebih maksimal dalam penerapannya.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s, style: const TextStyle(height: 1.5))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
