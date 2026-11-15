import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n.dart';

const channel = MethodChannel('mm/native');
const brand = Color(0xFF439BFF);
const white = ColorFilter.mode(Colors.white, BlendMode.srcIn);

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const catIcons = {'Makanan': '🍜', 'Transport': '🛵', 'Tagihan': '💡', 'Belanja': '🛍️', 'Lain-lain': '🪙', 'Gaji': '💼'};
// Nama paket aplikasi bisa berbeda di tiap HP/versi. Cek dan sesuaikan bila label sumber tidak muncul.
const pkgNames = {
  'com.gojek.app': 'GoPay', 'com.gojek.gopay': 'GoPay', 'id.dana': 'DANA', 'ovo.id': 'OVO',
  'com.shopee.id': 'ShopeePay', 'id.co.bri.brimo': 'BRImo', 'com.bca': 'BCA mobile',
  'id.bmri.livin': 'Livin’', 'com.btpn.dc': 'Jenius',
};
final catRules = {
  'Makanan': RegExp(r'makan|minum|kopi|teh|es |bakso|nasi|snack|jajan|resto', caseSensitive: false),
  'Transport': RegExp(r'bensin|ojek|grab|gojek|parkir|tol|bus|kereta', caseSensitive: false),
  'Tagihan': RegExp(r'listrik|token|pulsa|internet|kos|cicil|air|bpjs', caseSensitive: false),
  'Belanja': RegExp(r'belanja|tokopedia|shopee|baju|beli', caseSensitive: false),
  'Gaji': RegExp(r'gaji|bonus|uang saku', caseSensitive: false),
};

String guess(String s) {
  for (final e in catRules.entries) {
    if (e.value.hasMatch(s)) return e.key;
  }
  return 'Lain-lain';
}

String rp(num n) {
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class Level {
  final Color bg, ink;
  final String label;
  const Level(this.bg, this.ink, this.label);
}

// Biru < 25%, hijau 25-59%, kuning 60-84%, merah >= 85% dari pemasukan.
Level levelFor(double p) {
  if (p >= 85) return const Level(Color(0xFFD93A3A), Colors.white, 'Hampir habis');
  if (p >= 60) return const Level(Color(0xFFE08A00), Colors.white, 'Mulai waspada');
  if (p >= 25) return const Level(Color(0xFF3FCB86), Color(0xFF0C2A1B), 'Terkendali');
  return const Level(brand, Color(0xFF0A1F3A), 'Sangat hemat');
}

class Tx {
  final String id, note, cat, src;
  final bool out;
  final int amt;
  final DateTime date;
  Tx({required this.id, required this.out, required this.amt, required this.note, required this.cat, required this.date, this.src = ''});
  Map<String, dynamic> toJson() =>
      {'id': id, 'out': out, 'amt': amt, 'note': note, 'cat': cat, 'src': src, 'date': date.toIso8601String()};
  factory Tx.fromJson(Map<String, dynamic> j) => Tx(
      id: j['id'], out: j['out'], amt: j['amt'], note: j['note'], cat: j['cat'], src: j['src'] ?? '', date: DateTime.parse(j['date']));
}

// "minuman 5000", "kopi 18rb", "gaji 3jt" -> jumlah + catatan
({int amt, String note})? parseQuick(String s) {
  final m = RegExp(r'(\d[\d.,]*)\s*(rb|ribu|k|jt|juta)?', caseSensitive: false).firstMatch(s);
  if (m == null) return null;
  final raw = m.group(1)!.replaceAll(RegExp(r'[.,](?=\d{3}\b)'), '').replaceAll(',', '.');
  var n = double.tryParse(raw);
  if (n == null || n == 0) return null;
  final u = (m.group(2) ?? '').toLowerCase();
  if (['rb', 'ribu', 'k'].contains(u)) n *= 1000;
  if (['jt', 'juta'].contains(u)) n *= 1000000;
  return (amt: n.round(), note: (s.substring(0, m.start) + s.substring(m.end)).trim());
}

// Teks notifikasi dari bank/e-wallet -> transaksi. Null bila bukan transaksi.
Tx? fromNotif(Map<String, dynamic> n) {
  final text = '${n['title']} ${n['text']}';
  final m = RegExp(r'Rp\s?([\d.]+)(?:,\d+)?', caseSensitive: false).firstMatch(text);
  if (m == null) return null;
  final amt = int.tryParse(m.group(1)!.replaceAll('.', ''));
  if (amt == null || amt == 0) return null;
  final inc = RegExp(r'menerima|diterima|dana masuk|uang masuk|top ?up|received', caseSensitive: false).hasMatch(text);
  final spend = RegExp(r'pembayaran|bayar|transfer|keluar|debit|payment|berhasil', caseSensitive: false).hasMatch(text);
  if (!inc && !spend) return null;
  final nm = RegExp(r'(?:ke|dari)\s+([A-Za-z][^.!,\n]{1,30}?)(?:\s+berhasil|[.!,\n]|$)', caseSensitive: false).firstMatch(text);
  final note = nm?.group(1)?.trim() ?? (inc ? 'Uang masuk' : 'Pembayaran');
  final pkg = '${n['pkg']}';
  return Tx(
    id: 'n${n['id']}',
    out: !inc,
    amt: amt,
    note: note,
    cat: inc ? 'Gaji' : guess('$note $text'),
    src: pkgNames[pkg] ?? pkg.split('.').last,
    date: DateTime.fromMillisecondsSinceEpoch((n['time'] as num).toInt()),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final p = await SharedPreferences.getInstance();
  langN.value = p.getString('lang') ?? 'id';
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Money Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: brand),
        builder: (context, child) => ValueListenableBuilder<String>(
          valueListenable: langN,
          builder: (_, l, __) => Directionality(textDirection: l == 'ar' ? TextDirection.rtl : TextDirection.ltr, child: child!),
        ),
        home: const Splash(),
      );
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Home(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: brand,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SvgPicture.asset('assets/logo.svg', height: 120, colorFilter: white),
            const SizedBox(height: 48),
            const Text('Money management for yourself',
                style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontFamily: 'monospace', fontSize: 15)),
          ]),
        ),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<Tx> tx = [];
  int tab = 0;
  bool access = true;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    langN.addListener(_rl);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    langN.removeListener(_rl);
    super.dispose();
  }

  void _rl() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _sync();
  }

  Future<void> _boot() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('tx');
    if (raw != null) {
      tx = (jsonDecode(raw) as List).map((e) => Tx.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    if (mounted) setState(() {});
    await _sync();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('tx', jsonEncode(tx.map((e) => e.toJson()).toList()));
  }

  // Ambil notifikasi yang ditangkap service Android saat aplikasi tertutup.
  Future<void> _sync() async {
    try {
      access = await channel.invokeMethod<bool>('hasAccess') ?? false;
      final raw = await channel.invokeMethod<String>('pending') ?? '[]';
      for (final n in jsonDecode(raw) as List) {
        final t = fromNotif(Map<String, dynamic>.from(n as Map));
        if (t != null && !tx.any((x) => x.id == t.id)) tx.add(t);
      }
      await _save();
    } on MissingPluginException {
      access = true;
    }
    if (mounted) setState(() {});
  }

  void _add(Tx t) {
    setState(() {
      tx.add(t);
      month = DateTime(t.date.year, t.date.month);
    });
    _save();
  }

  List<Tx> get cur => tx.where((t) => t.date.year == month.year && t.date.month == month.month).toList();

  @override
  Widget build(BuildContext context) {
    final c = cur;
    var o = 0, i = 0;
    for (final t in c) {
      t.out ? o += t.amt : i += t.amt;
    }
    final p = i > 0 ? o / i * 100 : (o > 0 ? 999.0 : 0.0);
    final lv = levelFor(p);
    return Scaffold(
      body: Column(children: [
        _header(lv, o, i, p),
        Expanded(child: [_list(c), _chart(c), _me()][tab]),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lv.bg,
        foregroundColor: lv.ink,
        onPressed: _sheet,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(0, Icons.receipt_long, tr('Riwayat')),
          _nav(1, Icons.pie_chart, tr('Grafik')),
          const SizedBox(width: 48),
          _nav(2, Icons.person, tr('Saya')),
        ]),
      ),
    );
  }

  Widget _nav(int k, IconData ic, String label) => InkWell(
        onTap: () => setState(() => tab = k),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(ic, color: tab == k ? null : Colors.grey),
            Text(label, style: TextStyle(fontSize: 12, color: tab == k ? null : Colors.grey, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _stat(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(fontSize: 12)),
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ]);

  Widget _header(Level lv, int o, int i, double p) => AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        color: lv.bg,
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 18),
        child: DefaultTextStyle(
          style: TextStyle(color: lv.ink),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              SvgPicture.asset('assets/logo.svg', height: 30, colorFilter: white),
              const SizedBox(width: 10),
              const Text('Money Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            Row(children: [
              IconButton(
                  icon: Icon(Icons.chevron_left, color: lv.ink),
                  onPressed: () => setState(() => month = DateTime(month.year, month.month - 1))),
              Text(DateFormat.yMMM(langN.value).format(month), style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                  icon: Icon(Icons.chevron_right, color: lv.ink),
                  onPressed: () => setState(() => month = DateTime(month.year, month.month + 1))),
            ]),
            Text(tr('Saldo total'), style: const TextStyle(fontSize: 12)),
            Text('${i - o < 0 ? '-' : ''}${rp(i - o)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _stat(tr('Pengeluaran'), rp(o))), Expanded(child: _stat(tr('Pemasukan'), rp(i)))]),
            const SizedBox(height: 14),
            Row(children: [
              Text(p > 100 ? tr('Melebihi pemasukan') : tr(lv.label), style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${p.clamp(0, 999).round()}% ${tr('terpakai')}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: (p / 100).clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: Colors.black12, color: lv.ink),
            ),
          ]),
        ),
      );

  Widget _banner() => Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          title: Text(tr('Aktifkan akses notifikasi')),
          subtitle: Text(tr('Agar transaksi dari m-banking dan e-wallet tercatat otomatis.')),
          trailing: FilledButton(onPressed: () => channel.invokeMethod('openSettings'), child: Text(tr('Aktifkan'))),
        ),
      );

  Widget _list(List<Tx> c) {
    if (c.isEmpty) {
      return ListView(children: [
        if (!access) _banner(),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: Text(tr('Belum ada catatan bulan ini.\nKetuk + lalu tulis, misalnya “minuman 5000”.'), textAlign: TextAlign.center)),
        ),
      ]);
    }
    c.sort((a, b) => b.date.compareTo(a.date));
    final days = <String, List<Tx>>{};
    for (final t in c) {
      (days[DateFormat('EEEE, d MMM', langN.value).format(t.date)] ??= []).add(t);
    }
    return ListView(padding: const EdgeInsets.only(bottom: 90), children: [
      if (!access) _banner(),
      for (final e in days.entries) ...[
        Container(
          color: const Color(0x1F888888),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text('${tr('Keluar')} ${rp(e.value.where((t) => t.out).fold<int>(0, (a, t) => a + t.amt))}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        for (final t in e.value)
          Dismissible(
            key: ValueKey(t.id),
            background: Container(color: Colors.red.shade100),
            onDismissed: (_) {
              setState(() => tx.removeWhere((x) => x.id == t.id));
              _save();
            },
            child: ListTile(
              leading: CircleAvatar(child: Text(catIcons[t.cat] ?? '🪙')),
              title: Text(tr(t.note), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${tr(t.cat)}${t.src.isNotEmpty ? ' · ${tr('otomatis dari')} ${t.src}' : ''}'),
              trailing: Text('${t.out ? '-' : '+'}${rp(t.amt)}',
                  style: TextStyle(fontWeight: FontWeight.w800, color: t.out ? const Color(0xFFD93A3A) : const Color(0xFF1E9E62))),
            ),
          ),
      ],
    ]);
  }

  Widget _chart(List<Tx> c) {
    final m = <String, int>{};
    for (final t in c.where((t) => t.out)) {
      m[t.cat] = (m[t.cat] ?? 0) + t.amt;
    }
    if (m.isEmpty) return Center(child: Text(tr('Belum ada pengeluaran bulan ini.')));
    final e = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final tot = e.fold<int>(0, (a, x) => a + x.value);
    return ListView(padding: const EdgeInsets.all(20), children: [
      for (final x in e)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${catIcons[x.key] ?? ''} ${tr(x.key)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${rp(x.value)} · ${(x.value / tot * 100).round()}%'),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: x.value / tot, minHeight: 8)),
          ]),
        ),
    ]);
  }

  Widget _me() => ListView(children: [
        ListTile(
          leading: Icon(access ? Icons.check_circle : Icons.error_outline, color: access ? Colors.green : Colors.orange),
          title: Text(tr('Akses notifikasi')),
          subtitle: Text(tr(access ? 'Aktif. Transaksi dari notifikasi dicatat otomatis.' : 'Belum aktif. Ketuk untuk membuka pengaturan.')),
          onTap: () => channel.invokeMethod('openSettings'),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(tr('Bahasa')),
          subtitle: Text(kLangs.firstWhere((x) => x.$1 == langN.value).$2),
          onTap: _pickLang,
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(tr('Hapus semua catatan')),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(tr('Hapus semua catatan?')),
                content: Text(tr('Tindakan ini tidak bisa dibatalkan.')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Batal'))),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Hapus'))),
                ],
              ),
            );
            if (ok == true) {
              setState(() => tx = []);
              _save();
            }
          },
        ),
      ]);

  void _pickLang() {
    var q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final k = q.toLowerCase();
        final l = kLangs.where((x) => k.isEmpty || x.$2.toLowerCase().contains(k) || x.$3.toLowerCase().contains(k) || x.$1.contains(k)).toList();
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * .7,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), hintText: tr('Cari bahasa')),
                  onChanged: (v) => set(() => q = v),
                ),
              ),
              Expanded(
                child: ListView(children: [
                  for (final x in l)
                    ListTile(
                      title: Text(x.$2),
                      subtitle: Text(x.$3),
                      trailing: langN.value == x.$1 ? const Icon(Icons.check) : null,
                      onTap: () async {
                        langN.value = x.$1;
                        final p = await SharedPreferences.getInstance();
                        await p.setString('lang', x.$1);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
  }

  void _sheet() {
    var out = true;
    final ctl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final r = parseQuick(ctl.text);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment(value: true, label: Text(tr('Pengeluaran'))),
                ButtonSegment(value: false, label: Text(tr('Pemasukan'))),
              ],
              selected: {out},
              onSelectionChanged: (s) => set(() => out = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctl,
              autofocus: true,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: tr('Ketik cepat, misalnya: minuman 5000')),
              onChanged: (_) => set(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(r == null
                  ? tr('Tulis catatan lalu jumlahnya. Singkatan rb, k, dan jt dikenali.')
                  : '${rp(r.amt)} · ${tr(out ? guess(r.note) : 'Gaji')}${r.note.isEmpty ? '' : ' · ${r.note}'}'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: r == null
                    ? null
                    : () {
                        _add(Tx(
                          id: 'm${DateTime.now().microsecondsSinceEpoch}',
                          out: out,
                          amt: r.amt,
                          note: r.note.isEmpty ? (out ? 'Pengeluaran' : 'Pemasukan') : r.note,
                          cat: out ? guess(r.note) : 'Gaji',
                          date: DateTime.now(),
                        ));
                        Navigator.pop(ctx);
                      },
                child: Text(tr('Simpan catatan')),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
