import 'package:flutter/foundation.dart';

/// Bahasa aktif. Berubah saat pengguna memilih bahasa di tab Saya.
final langN = ValueNotifier<String>('id');

/// (kode, nama asli, nama Inggris). Indonesia adalah bahasa sumber.
const kLangs = <(String, String, String)>[
  ('id', 'Bahasa Indonesia', 'Indonesian'),
  ('en', 'English', 'English'),
  ('ms', 'Bahasa Melayu', 'Malay'),
  ('zh', '中文 (简体)', 'Chinese'),
  ('ja', '日本語', 'Japanese'),
  ('ko', '한국어', 'Korean'),
  ('ar', 'العربية', 'Arabic'),
  ('hi', 'हिन्दी', 'Hindi'),
  ('es', 'Español', 'Spanish'),
  ('fr', 'Français', 'French'),
  ('de', 'Deutsch', 'German'),
  ('th', 'ไทย', 'Thai'),
  ('vi', 'Tiếng Việt', 'Vietnamese'),
];

// Urutan kolom terjemahan di tabel _s.
const _cols = ['en', 'ms', 'zh', 'ja', 'ko', 'ar', 'hi', 'es', 'fr', 'de', 'th', 'vi'];

/// Terjemahkan teks sumber (Indonesia). Jika tidak ada terjemahan, teks asli dikembalikan.
String tr(String id) {
  final l = langN.value;
  if (l == 'id') return id;
  final i = _cols.indexOf(l);
  final r = _s[id];
  if (i < 0 || r == null) return id;
  return r[i];
}

// Kolom: en, ms, zh, ja, ko, ar, hi, es, fr, de, th, vi
const _s = <String, List<String>>{
  'Saldo total': ['Total balance', 'Jumlah baki', '总余额', '合計残高', '총 잔액', 'الرصيد الإجمالي', 'कुल शेष', 'Saldo total', 'Solde total', 'Gesamtsaldo', 'ยอดคงเหลือรวม', 'Tổng số dư'],
  'Pengeluaran': ['Expenses', 'Perbelanjaan', '支出', '支出', '지출', 'المصروفات', 'खर्च', 'Gastos', 'Dépenses', 'Ausgaben', 'รายจ่าย', 'Chi tiêu'],
  'Pemasukan': ['Income', 'Pendapatan', '收入', '収入', '수입', 'الدخل', 'आय', 'Ingresos', 'Revenus', 'Einnahmen', 'รายรับ', 'Thu nhập'],
  'Sangat hemat': ['Very frugal', 'Sangat jimat', '非常节省', 'とても節約', '매우 절약', 'اقتصاد كبير', 'बहुत किफ़ायती', 'Muy ahorrador', 'Très économe', 'Sehr sparsam', 'ประหยัดมาก', 'Rất tiết kiệm'],
  'Terkendali': ['Under control', 'Terkawal', '在掌控中', '順調', '안정적', 'تحت السيطرة', 'नियंत्रण में', 'Bajo control', 'Sous contrôle', 'Unter Kontrolle', 'อยู่ในการควบคุม', 'Trong tầm kiểm soát'],
  'Mulai waspada': ['Getting risky', 'Mula berwaspada', '开始留意', '要注意', '주의 시작', 'ابدأ بالحذر', 'सावधान रहें', 'Con cautela', 'À surveiller', 'Vorsicht', 'เริ่มระวัง', 'Bắt đầu cần chú ý'],
  'Hampir habis': ['Almost spent', 'Hampir habis', '快用完了', 'もうすぐ上限', '거의 소진', 'أوشك على النفاد', 'लगभग खत्म', 'Casi agotado', 'Presque épuisé', 'Fast aufgebraucht', 'ใกล้หมดแล้ว', 'Sắp hết'],
  'Melebihi pemasukan': ['Over income', 'Melebihi pendapatan', '超出收入', '収入を超過', '수입 초과', 'تجاوز الدخل', 'आय से अधिक', 'Supera los ingresos', 'Dépasse les revenus', 'Über den Einnahmen', 'เกินรายรับ', 'Vượt thu nhập'],
  'terpakai': ['used', 'digunakan', '已使用', '使用済み', '사용됨', 'مُستخدم', 'उपयोग किया', 'usado', 'utilisé', 'verbraucht', 'ใช้ไปแล้ว', 'đã dùng'],
  'Riwayat': ['History', 'Sejarah', '记录', '履歴', '내역', 'السجل', 'इतिहास', 'Historial', 'Historique', 'Verlauf', 'ประวัติ', 'Lịch sử'],
  'Grafik': ['Charts', 'Carta', '图表', 'グラフ', '차트', 'الرسوم', 'चार्ट', 'Gráficos', 'Graphiques', 'Diagramme', 'กราฟ', 'Biểu đồ'],
  'Saya': ['Me', 'Saya', '我', '自分', '나', 'أنا', 'मैं', 'Yo', 'Moi', 'Ich', 'ฉัน', 'Tôi'],
  'Aktifkan akses notifikasi': ['Enable notification access', 'Aktifkan akses pemberitahuan', '开启通知访问', '通知へのアクセスを有効にする', '알림 접근 허용', 'تفعيل الوصول إلى الإشعارات', 'सूचना एक्सेस चालू करें', 'Activar acceso a notificaciones', 'Activer l’accès aux notifications', 'Benachrichtigungszugriff aktivieren', 'เปิดการเข้าถึงการแจ้งเตือน', 'Bật quyền truy cập thông báo'],
  'Agar transaksi dari m-banking dan e-wallet tercatat otomatis.': ['So transactions from mobile banking and e-wallets are recorded automatically.', 'Supaya transaksi daripada m-banking dan e-dompet dicatat secara automatik.', '让手机银行和电子钱包的交易自动记录。', 'モバイルバンキングや電子マネーの取引を自動で記録します。', '모바일 뱅킹과 전자지갑 거래가 자동으로 기록됩니다.', 'لتُسجَّل معاملات الخدمات المصرفية والمحافظ الإلكترونية تلقائيًا.', 'ताकि मोबाइल बैंकिंग और ई-वॉलेट के लेन-देन अपने आप दर्ज हों।', 'Para registrar automáticamente las transacciones de banca móvil y billeteras electrónicas.', 'Pour enregistrer automatiquement les transactions de la banque mobile et des portefeuilles électroniques.', 'Damit Transaktionen aus Mobile Banking und E-Wallets automatisch erfasst werden.', 'เพื่อบันทึกรายการจากโมบายแบงก์กิ้งและอีวอลเล็ตโดยอัตโนมัติ', 'Để giao dịch từ ngân hàng di động và ví điện tử được ghi tự động.'],
  'Aktifkan': ['Enable', 'Aktifkan', '开启', '有効にする', '켜기', 'تفعيل', 'चालू करें', 'Activar', 'Activer', 'Aktivieren', 'เปิด', 'Bật'],
  'Belum ada catatan bulan ini.\nKetuk + lalu tulis, misalnya “minuman 5000”.': ['No entries this month.\nTap + and type, e.g. “drink 5000”.', 'Tiada catatan bulan ini.\nKetuk + dan taip, cth “minuman 5000”.', '本月暂无记录。\n点 + 输入，例如“饮料 5000”。', '今月の記録はまだありません。\n＋をタップして「飲み物 5000」のように入力。', '이번 달 내역이 없습니다.\n+를 눌러 “음료 5000”처럼 입력하세요.', 'لا توجد سجلات هذا الشهر.\nاضغط + واكتب مثل «مشروب 5000».', 'इस महीने कोई प्रविष्टि नहीं।\n+ दबाकर लिखें, जैसे “पेय 5000”।', 'No hay registros este mes.\nToca + y escribe, p. ej. “bebida 5000”.', 'Aucune entrée ce mois-ci.\nAppuyez sur + et saisissez, p. ex. « boisson 5000 ».', 'Keine Einträge in diesem Monat.\nTippe auf + und schreibe z. B. „Getränk 5000“.', 'ยังไม่มีรายการในเดือนนี้\nแตะ + แล้วพิมพ์ เช่น “เครื่องดื่ม 5000”', 'Tháng này chưa có mục nào.\nChạm + rồi nhập, ví dụ “đồ uống 5000”.'],
  'Keluar': ['Spent', 'Keluar', '支出', '支出', '지출', 'المصروف', 'खर्च', 'Gasto', 'Dépensé', 'Ausgegeben', 'จ่ายไป', 'Đã chi'],
  'otomatis dari': ['auto from', 'automatik daripada', '自动来自', '自動：', '자동:', 'تلقائي من', 'स्वतः', 'automático de', 'auto depuis', 'automatisch von', 'อัตโนมัติจาก', 'tự động từ'],
  'Belum ada pengeluaran bulan ini.': ['No expenses this month.', 'Tiada perbelanjaan bulan ini.', '本月暂无支出。', '今月の支出はありません。', '이번 달 지출이 없습니다.', 'لا مصروفات هذا الشهر.', 'इस महीने कोई खर्च नहीं।', 'Sin gastos este mes.', 'Aucune dépense ce mois-ci.', 'Keine Ausgaben in diesem Monat.', 'ยังไม่มีรายจ่ายในเดือนนี้', 'Tháng này chưa có chi tiêu.'],
  'Akses notifikasi': ['Notification access', 'Akses pemberitahuan', '通知访问', '通知アクセス', '알림 접근', 'الوصول إلى الإشعارات', 'सूचना एक्सेस', 'Acceso a notificaciones', 'Accès aux notifications', 'Benachrichtigungszugriff', 'การเข้าถึงการแจ้งเตือน', 'Quyền truy cập thông báo'],
  'Aktif. Transaksi dari notifikasi dicatat otomatis.': ['On. Transactions from notifications are recorded automatically.', 'Aktif. Transaksi daripada pemberitahuan dicatat secara automatik.', '已开启。通知中的交易会自动记录。', 'オン。通知の取引は自動で記録されます。', '켜짐. 알림의 거래가 자동으로 기록됩니다.', 'مفعّل. تُسجَّل المعاملات من الإشعارات تلقائيًا.', 'चालू। सूचनाओं के लेन-देन अपने आप दर्ज होते हैं।', 'Activo. Las transacciones de las notificaciones se registran automáticamente.', 'Activé. Les transactions des notifications sont enregistrées automatiquement.', 'Aktiv. Transaktionen aus Benachrichtigungen werden automatisch erfasst.', 'เปิดอยู่ รายการจากการแจ้งเตือนจะถูกบันทึกอัตโนมัติ', 'Đang bật. Giao dịch từ thông báo được ghi tự động.'],
  'Belum aktif. Ketuk untuk membuka pengaturan.': ['Not enabled. Tap to open settings.', 'Belum aktif. Ketik untuk buka tetapan.', '尚未开启。点按打开设置。', 'オフ。タップして設定を開きます。', '꺼짐. 탭하여 설정을 엽니다.', 'غير مفعّل. اضغط لفتح الإعدادات.', 'चालू नहीं है। सेटिंग्स खोलने के लिए टैप करें।', 'No activado. Toca para abrir los ajustes.', 'Non activé. Touchez pour ouvrir les réglages.', 'Nicht aktiviert. Tippe, um die Einstellungen zu öffnen.', 'ยังไม่เปิด แตะเพื่อเปิดการตั้งค่า', 'Chưa bật. Chạm để mở cài đặt.'],
  'Hapus semua catatan': ['Delete all entries', 'Padam semua catatan', '删除所有记录', 'すべての記録を削除', '모든 내역 삭제', 'حذف كل السجلات', 'सभी प्रविष्टियाँ हटाएँ', 'Eliminar todos los registros', 'Supprimer toutes les entrées', 'Alle Einträge löschen', 'ลบรายการทั้งหมด', 'Xóa tất cả mục'],
  'Hapus semua catatan?': ['Delete all entries?', 'Padam semua catatan?', '删除所有记录？', 'すべての記録を削除しますか？', '모든 내역을 삭제할까요?', 'حذف كل السجلات؟', 'सभी प्रविष्टियाँ हटाएँ?', '¿Eliminar todos los registros?', 'Supprimer toutes les entrées ?', 'Alle Einträge löschen?', 'ลบรายการทั้งหมดหรือไม่?', 'Xóa tất cả mục?'],
  'Tindakan ini tidak bisa dibatalkan.': ['This action cannot be undone.', 'Tindakan ini tidak boleh dibatalkan.', '此操作无法撤销。', 'この操作は元に戻せません。', '이 작업은 되돌릴 수 없습니다.', 'لا يمكن التراجع عن هذا الإجراء.', 'यह क्रिया पूर्ववत नहीं की जा सकती।', 'Esta acción no se puede deshacer.', 'Cette action est irréversible.', 'Diese Aktion kann nicht rückgängig gemacht werden.', 'ไม่สามารถย้อนกลับการดำเนินการนี้ได้', 'Hành động này không thể hoàn tác.'],
  'Batal': ['Cancel', 'Batal', '取消', 'キャンセル', '취소', 'إلغاء', 'रद्द करें', 'Cancelar', 'Annuler', 'Abbrechen', 'ยกเลิก', 'Hủy'],
  'Hapus': ['Delete', 'Padam', '删除', '削除', '삭제', 'حذف', 'हटाएँ', 'Eliminar', 'Supprimer', 'Löschen', 'ลบ', 'Xóa'],
  'Bahasa': ['Language', 'Bahasa', '语言', '言語', '언어', 'اللغة', 'भाषा', 'Idioma', 'Langue', 'Sprache', 'ภาษา', 'Ngôn ngữ'],
  'Cari bahasa': ['Search language', 'Cari bahasa', '搜索语言', '言語を検索', '언어 검색', 'ابحث عن لغة', 'भाषा खोजें', 'Buscar idioma', 'Rechercher une langue', 'Sprache suchen', 'ค้นหาภาษา', 'Tìm ngôn ngữ'],
  'Ketik cepat, misalnya: minuman 5000': ['Quick entry, e.g. drink 5000', 'Taip pantas, cth: minuman 5000', '快速输入，例如：饮料 5000', 'クイック入力（例：飲み物 5000）', '빠른 입력, 예: 음료 5000', 'إدخال سريع، مثل: مشروب 5000', 'त्वरित प्रविष्टि, जैसे: पेय 5000', 'Entrada rápida, p. ej.: bebida 5000', 'Saisie rapide, p. ex. : boisson 5000', 'Schnelleingabe, z. B.: Getränk 5000', 'พิมพ์ด่วน เช่น: เครื่องดื่ม 5000', 'Nhập nhanh, ví dụ: đồ uống 5000'],
  'Tulis catatan lalu jumlahnya. Singkatan rb, k, dan jt dikenali.': ['Write a note, then the amount. Shorthand rb, k and jt works.', 'Tulis catatan kemudian jumlah. Singkatan rb, k dan jt dikenali.', '写下备注再写金额。可用 rb、k、jt 简写。', 'メモ、金額の順に入力。rb、k、jt の略記が使えます。', '메모와 금액을 순서대로 입력하세요. rb, k, jt 약어를 인식합니다.', 'اكتب الملاحظة ثم المبلغ. تُدعم الاختصارات rb وk وjt.', 'पहले नोट, फिर राशि लिखें। rb, k और jt संक्षेप चलते हैं।', 'Escribe una nota y luego el importe. Se admiten las abreviaturas rb, k y jt.', 'Écrivez une note puis le montant. Les abréviations rb, k et jt sont reconnues.', 'Schreibe eine Notiz, dann den Betrag. Kürzel rb, k und jt werden erkannt.', 'เขียนบันทึกแล้วตามด้วยจำนวนเงิน รองรับตัวย่อ rb, k และ jt', 'Viết ghi chú rồi số tiền. Hỗ trợ viết tắt rb, k và jt.'],
  'Simpan catatan': ['Save entry', 'Simpan catatan', '保存记录', '記録を保存', '내역 저장', 'حفظ السجل', 'प्रविष्टि सहेजें', 'Guardar registro', 'Enregistrer', 'Eintrag speichern', 'บันทึกรายการ', 'Lưu mục'],
  'Makanan': ['Food', 'Makanan', '餐饮', '食費', '식비', 'طعام', 'भोजन', 'Comida', 'Alimentation', 'Essen', 'อาหาร', 'Ăn uống'],
  'Transport': ['Transport', 'Pengangkutan', '交通', '交通', '교통', 'مواصلات', 'परिवहन', 'Transporte', 'Transport', 'Verkehr', 'การเดินทาง', 'Đi lại'],
  'Tagihan': ['Bills', 'Bil', '账单', '請求書', '공과금', 'فواتير', 'बिल', 'Facturas', 'Factures', 'Rechnungen', 'ค่าบริการ', 'Hóa đơn'],
  'Belanja': ['Shopping', 'Membeli-belah', '购物', '買い物', '쇼핑', 'تسوق', 'खरीदारी', 'Compras', 'Achats', 'Einkauf', 'ช้อปปิ้ง', 'Mua sắm'],
  'Lain-lain': ['Other', 'Lain-lain', '其他', 'その他', '기타', 'أخرى', 'अन्य', 'Otros', 'Autres', 'Sonstiges', 'อื่น ๆ', 'Khác'],
  'Gaji': ['Salary', 'Gaji', '工资', '給与', '급여', 'الراتب', 'वेतन', 'Salario', 'Salaire', 'Gehalt', 'เงินเดือน', 'Lương'],
};
