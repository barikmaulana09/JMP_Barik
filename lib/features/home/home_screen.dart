import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/survey_repository.dart';
import '../../widgets/network_status_chip.dart';
import '../about/about_screen.dart';
import '../stores/daftar_toko_screen.dart';
import '../stores/form_toko_screen.dart';
import '../history/riwayat_screen.dart'; // ← Sudah ada, pastikan import ini

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storeRepo = StoreRepository();
  final _surveyRepo = SurveyRepository();

  String _namaPetugas = '';
  int _totalToko = 0;
  int _totalKunjunganBulanIni = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalToko = await _storeRepo.count();
      final totalKunjungan = await _surveyRepo.countThisMonth();
      if (!mounted) return;
      setState(() {
        _namaPetugas = prefs.getString(AppConstants.keyLoggedInNama) ?? '';
        _totalToko = totalToko;
        _totalKunjunganBulanIni = totalKunjungan;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 11) return Icons.wb_sunny_outlined;
    if (hour < 15) return Icons.wb_cloudy_outlined;
    if (hour < 18) return Icons.light_mode_outlined;
    return Icons.nightlight_round_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Survey Produk'),
        actions: [
          const NetworkStatusChip(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreetingSection(),
            const SizedBox(height: 28),
            _buildStatCards(),
            const SizedBox(height: 32),
            _buildShortcutSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getGreetingIcon(), color: Colors.amber.shade300, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _namaPetugas.isEmpty ? '...' : _namaPetugas,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.toLongDisplay(DateFormatter.todayDb()),
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _UniqueStatCard(
            icon: Icons.storefront_rounded,
            label: 'Total Toko',
            value: _isLoading ? '...' : '$_totalToko',
            gradientColors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.7)],
            decorationIcon: Icons.layers_outlined,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _UniqueStatCard(
            icon: Icons.task_alt_rounded,
            label: 'Kunjungan',
            subtitle: 'Bulan Ini',
            value: _isLoading ? '...' : '$_totalKunjunganBulanIni',
            gradientColors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.7)],
            decorationIcon: Icons.trending_up_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // ── Tombol: Daftar Toko ──
        _EyeCatchingButton(
          icon: Icons.store_mall_directory_rounded,
          label: 'Lihat Daftar Toko',
          subtitle: 'Cari & kelola data toko klien',
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.75)],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DaftarTokoScreen()),
            );
            _loadData();
          },
        ),
        const SizedBox(height: 14),

        // ── Tombol: Tambah Toko ──
        _EyeCatchingButton(
          icon: Icons.add_business_rounded,
          label: 'Tambah Toko Baru',
          subtitle: 'Daftarkan toko klien baru',
          gradient: LinearGradient(
            colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.75)],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormTokoScreen()),
            );
            _loadData();
          },
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════
        //  ← SHORTCUT BARU: RIWAYAT SURVEI
        // ═══════════════════════════════════════════════════
        _EyeCatchingButton(
          icon: Icons.history_rounded,
          label: 'Riwayat Survei',
          subtitle: 'Lihat semua kunjungan & edit data',
          gradient: LinearGradient(
            colors: [const Color(0xFF5C6BC0), const Color(0xFF5C6BC0).withValues(alpha: 0.75)],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiwayatScreen()),
            );
            _loadData();
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGET: KARTU STATISTIK UNIK
// ══════════════════════════════════════════════════════════
class _UniqueStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String value;
  final List<Color> gradientColors;
  final IconData decorationIcon;

  const _UniqueStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.decorationIcon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Opacity(
              opacity: 0.1,
              child: Icon(decorationIcon, size: 72, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGET: TOMBOL EYE-CATCHING
// ══════════════════════════════════════════════════════════
class _EyeCatchingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _EyeCatchingButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (gradient.colors[0]).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}