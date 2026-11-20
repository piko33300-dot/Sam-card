import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const _adminEmail = 'yemenmixpro@gmail.com';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  int _tab = 0;
  bool _loadingProducts = true;
  List<_StoreProduct> _products = const [];
  final Map<String, int> _cart = {};
  User? _user;
  StreamSubscription<User?>? _authSubscription;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;
  bool get _isAdmin => _user?.email?.trim().toLowerCase() == _adminEmail;

  @override
  void initState() {
    super.initState();
    if (_firebaseReady) {
      _user = FirebaseAuth.instance.currentUser;
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (mounted) setState(() => _user = user);
      });
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    var result = _sampleProducts;
    if (_firebaseReady) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection('products').get();
        if (snapshot.docs.isNotEmpty) {
          result = snapshot.docs
              .map((doc) => _StoreProduct.fromMap(doc.id, doc.data()))
              .toList();
        }
      } catch (error) {
        debugPrint('Unable to fetch products: $error');
      }
    }
    if (mounted) {
      setState(() {
        _products = result;
        _loadingProducts = false;
      });
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _addToCart(_StoreProduct product) {
    setState(() => _cart.update(product.id, (count) => count + 1, ifAbsent: () => 1));
    _message('تمت إضافة المنتج إلى السلة');
  }

  void _openAuth({bool signup = false}) {
    showDialog<void>(
      context: context,
      builder: (_) => _AuthDialog(
        initialSignup: signup,
        onAuthenticated: (user) {
          if (mounted) setState(() => _user = user);
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
  }

  Future<void> _checkout() async {
    if (_user == null) {
      _message('يرجى تسجيل الدخول لإتمام الطلب');
      _openAuth();
      return;
    }
    if (_cart.isEmpty) return;

    final linkController = TextEditingController();
    final referenceController = TextEditingController();
    String? accountLinkOrId;
    String? paymentReference;
    try {
      final submitted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('إتمام الطلب'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: linkController,
                decoration: const InputDecoration(labelText: 'رابط الحساب أو الـ ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(labelText: 'رقم الحوالة / المرجع'),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      );
      if (submitted != true) return;
      accountLinkOrId = linkController.text.trim();
      paymentReference = referenceController.text.trim();
    } finally {
      linkController.dispose();
      referenceController.dispose();
    }

    if (accountLinkOrId!.isEmpty || paymentReference!.isEmpty) {
      _message('يرجى إدخال رابط الحساب ورقم الحوالة');
      return;
    }
    if (!_firebaseReady) {
      _message('خدمة Firebase غير مهيأة. أضف إعدادات Firebase ثم أعد المحاولة.');
      return;
    }

    try {
      final lines = <Map<String, dynamic>>[];
      for (final entry in _cart.entries) {
        final matches = _products.where((product) => product.id == entry.key);
        if (matches.isEmpty) continue;
        final product = matches.first;
        lines.add({
          'productId': product.id,
          'title': product.title,
          'price': product.price,
          'quantity': entry.value,
        });
      }
      if (lines.isEmpty) {
        _message('تعذر العثور على منتجات السلة. حدّث المنتجات وحاول مرة أخرى.');
        return;
      }
      final total = lines.fold<double>(
        0,
        (sum, line) => sum + (line['price'] as num) * (line['quantity'] as int),
      );
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': _user!.uid,
        'email': _user!.email,
        'items': lines,
        'total': total,
        'accountLinkOrId': accountLinkOrId,
        'paymentReference': paymentReference,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(_cart.clear);
        _message('تم إرسال طلبك بنجاح');
      }
    } catch (error) {
      debugPrint('Unable to save order: $error');
      if (mounted) _message('تعذر حفظ الطلب. تحقق من اتصالك وصلاحيات Firebase.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_homePage(), _cartPage(), _ordersPage(), _profilePage()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAM CARD', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'السلة',
            onPressed: () => setState(() => _tab = 1),
            icon: Badge(
              label: Text('${_cart.values.fold<int>(0, (a, b) => a + b)}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'السلة'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'الملف الشخصي'),
        ],
      ),
    );
  }

  Widget _homePage() => RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خدمات رقمية بكل سهولة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('اختر خدمتك المفضلة وأرسل بيانات طلبك.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_loadingProducts)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_products.isEmpty)
            const Center(child: Text('لا توجد منتجات حالياً'))
          else
            ..._products.map(_productCard),
        ]),
      );

  Widget _productCard(_StoreProduct product) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(product.category), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (product.description.isNotEmpty)
                  Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 5),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ]),
            ),
            IconButton(onPressed: () => _addToCart(product),
                icon: const Icon(Icons.add_shopping_cart), tooltip: 'أضف للسلة'),
          ]),
        ),
      );

  Widget _cartPage() {
    final entries = _cart.entries.toList();
    final total = entries.fold<double>(0, (sum, entry) {
      final matches = _products.where((item) => item.id == entry.key);
      return sum + (matches.isEmpty ? 0 : matches.first.price * entry.value);
    });
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('سلة التسوق', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (entries.isEmpty)
        const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('السلة فارغة'))),
      ...entries.map((entry) {
        final matches = _products.where((item) => item.id == entry.key);
        if (matches.isEmpty) return const SizedBox.shrink();
        final product = matches.first;
        return ListTile(
          title: Text(product.title),
          subtitle: Text('الكمية: ${entry.value}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _cart.remove(entry.key)),
          ),
        );
      }),
      if (entries.isNotEmpty) ...[
        const Divider(),
        Text('الإجمالي: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _checkout, icon: const Icon(Icons.payment), label: const Text('متابعة إلى الدفع')),
      ],
    ]);
  }

  Widget _ordersPage() {
    if (_user == null) return _emptyLogin('سجل الدخول لعرض طلباتك');
    if (!_firebaseReady) return const Center(child: Text('خدمة الطلبات غير متاحة حالياً'));
    final query = FirebaseFirestore.instance.collection('orders')
        .where('userId', isEqualTo: _user!.uid).limit(50);
    return _ordersList(query, admin: false);
  }

  Widget _profilePage() => ListView(padding: const EdgeInsets.all(20), children: [
        const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 12),
        Center(child: Text(_user?.email ?? 'مرحباً بك في SAM CARD',
            style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        if (_user == null) ...[
          FilledButton.icon(onPressed: () => _openAuth(), icon: const Icon(Icons.login), label: const Text('تسجيل الدخول')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => _openAuth(signup: true), child: const Text('إنشاء حساب جديد')),
        ] else ...[
          if (_isAdmin) ...[
            FilledButton.icon(onPressed: _openAdmin, icon: const Icon(Icons.admin_panel_settings),
                label: const Text('لوحة تحكم الإدارة')),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) setState(() => _user = null);
            },
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ]);

  Widget _emptyLogin(String text) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(text),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => _openAuth(), child: const Text('تسجيل الدخول')),
        ]),
      );

  Widget _ordersList(Query<Map<String, dynamic>> query, {required bool admin}) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('تعذر تحميل الطلبات. تحقق من صلاحيات Firestore.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد طلبات حتى الآن'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final items = (data['items'] as List<dynamic>? ?? []).map((item) {
                final row = Map<String, dynamic>.from(item as Map);
                return '${row['title']} × ${row['quantity']}';
              }).join('، ');
              final total = (data['total'] as num?)?.toDouble() ?? 0;
              final detail = admin
                  ? 'الحوالة: ${data['paymentReference'] ?? '—'}\nالحساب: ${data['accountLinkOrId'] ?? '—'}'
                  : 'الحالة: ${data['status'] ?? 'قيد المراجعة'}';
              return Card(
                child: ListTile(
                  title: Text('${data['email'] ?? ''} • \$${total.toStringAsFixed(2)}'),
                  subtitle: Text('$items\n$detail'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      );

  void _openAdmin() {
    if (!_isAdmin || !_firebaseReady) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _AdminPanel()));
  }
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog({required this.onAuthenticated, required this.initialSignup});
  final ValueChanged<User> onAuthenticated;
  final bool initialSignup;

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _signup = widget.initialSignup;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _arabicError(FirebaseAuthException error) => switch (error.code) {
        'invalid-email' => 'صيغة البريد الإلكتروني غير صحيحة.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        'email-already-in-use' => 'هذا البريد مسجل مسبقاً. سجّل الدخول بدلاً من ذلك.',
        'weak-password' => 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.',
        'network-request-failed' => 'تعذر الاتصال بالإنترنت. حاول مرة أخرى.',
        'too-many-requests' => 'محاولات كثيرة. يرجى الانتظار قليلاً.',
        _ => 'تعذر إتمام العملية. تحقق من البيانات وحاول مرة أخرى.',
      };

  Future<void> _submit() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _error = 'خدمة Firebase غير مهيأة. أضف إعدادات Firebase للمشروع.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      final credential = _signup
          ? await auth.createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text)
          : await auth.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      if (credential.user != null) widget.onAuthenticated(credential.user!);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _arabicError(error));
    } catch (_) {
      if (mounted) setState(() => _error = 'حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_signup ? 'إنشاء حساب' : 'تسجيل الدخول'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
            TextField(controller: _password, obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور')),
            if (_error != null)
              Padding(padding: const EdgeInsets.only(top: 10),
                  child: Text(_error!, style: const TextStyle(color: Colors.red))),
            TextButton(
              onPressed: _busy ? null : () => setState(() => _signup = !_signup),
              child: Text(_signup ? 'لديك حساب؟ تسجيل الدخول' : 'ليس لديك حساب؟ أنشئ حساباً'),
            ),
          ]),
        ),
        actions: [
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator())
                : Text(_signup ? 'إنشاء حساب' : 'دخول'),
          ),
        ],
      );
}

class _AdminPanel extends StatefulWidget {
  const _AdminPanel();

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _tabs.dispose();
    _title.dispose();
    _price.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (_title.text.trim().isEmpty || price == null || price <= 0 || _category.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل العنوان والسعر الموجب والتصنيف بشكل صحيح')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': _title.text.trim(),
        'price': price,
        'category': _category.text.trim(),
        'description': _description.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      _title.clear();
      _price.clear();
      _category.clear();
      _description.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المنتج')));
    } catch (error) {
      debugPrint('Unable to add product: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذرت إضافة المنتج. تحقق من صلاحيات Firestore.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    } catch (error) {
      debugPrint('Unable to delete product: $error');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر حذف المنتج')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم الإدارة'),
          bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'المنتجات'), Tab(text: 'الطلبات')]),
        ),
        body: TabBarView(controller: _tabs, children: [_productsTab(), _ordersTab()]),
      );

  Widget _productsTab() => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('إضافة منتج جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'العنوان')),
        TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'السعر بالدولار')),
        TextField(controller: _category, decoration: const InputDecoration(labelText: 'التصنيف (بطاقات / متابعون / ألعاب)')),
        TextField(controller: _description, decoration: const InputDecoration(labelText: 'الوصف')),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saving ? null : _addProduct,
            child: Text(_saving ? 'جارٍ الحفظ...' : 'إضافة إلى المتجر')),
        const Divider(height: 32),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('تعذر تحميل المنتجات. تحقق من صلاحيات Firestore.');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.data!.docs.isEmpty) return const Text('لا توجد منتجات مضافة بعد');
            return Column(children: snapshot.data!.docs.map((doc) {
              final product = _StoreProduct.fromMap(doc.id, doc.data());
              return ListTile(
                title: Text(product.title),
                subtitle: Text('${product.category} • \$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _delete(doc.id),
                ),
              );
            }).toList());
          },
        ),
      ]);

  Widget _ordersTab() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').limit(100).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('تعذر تحميل الطلبات. تحقق من صلاحيات Firestore.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد طلبات واردة'));
          return ListView(children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            return Card(
              child: ListTile(
                title: Text('${data['email'] ?? 'عميل'} • \$${total.toStringAsFixed(2)}'),
                subtitle: Text('رقم الحوالة: ${data['paymentReference'] ?? '—'}\nرابط الحساب أو ID: ${data['accountLinkOrId'] ?? '—'}\nالحالة: ${data['status'] ?? 'قيد المراجعة'}'),
                isThreeLine: true,
              ),
            );
          }).toList());
        },
      );
}

class _StoreProduct {
  const _StoreProduct({required this.id, required this.title, required this.price,
    required this.category, this.description = ''});
  final String id;
  final String title;
  final double price;
  final String category;
  final String description;

  factory _StoreProduct.fromMap(String id, Map<String, dynamic> data) => _StoreProduct(
        id: id,
        title: (data['title'] ?? data['name'] ?? 'منتج رقمي').toString(),
        price: (data['price'] as num?)?.toDouble() ?? 0,
        category: (data['category'] ?? '').toString(),
        description: (data['description'] ?? '').toString(),
      );
}

IconData _categoryIcon(String category) {
  final value = category.toLowerCase();
  if (value.contains('game') || value.contains('لعب') || value.contains('ألعاب')) return Icons.sports_esports;
  if (value.contains('social') || value.contains('follow') || value.contains('متابع')) return Icons.people_alt;
  return Icons.credit_card;
}

const _sampleProducts = <_StoreProduct>[
  _StoreProduct(id: 'sample-card', title: 'بطاقات رقمية افتراضية', price: 5,
      category: 'بطاقات', description: 'بطاقات وخدمات رقمية موثوقة.'),
  _StoreProduct(id: 'sample-followers', title: 'زيادة المتابعين', price: 3,
      category: 'متابعون', description: 'خدمات تواصل اجتماعي لحسابك.'),
  _StoreProduct(id: 'sample-games', title: 'شحن الألعاب', price: 2,
      category: 'ألعاب', description: 'اشحن رصيد ألعابك بسهولة.'),
];
