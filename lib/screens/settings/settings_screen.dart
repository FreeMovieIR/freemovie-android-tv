import 'package:flutter/material.dart';

import '../../utils/web/http_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _currentUserKey;

  @override
  void initState() {
    super.initState();
    _loadCurrentApiKey();
  }

  Future<void> _loadCurrentApiKey() async {
    setState(() {
      _isLoading = true;
      _currentUserKey = omdbApiKeySwitcher.userApiKey;
      if (_currentUserKey != null) {
        _apiKeyController.text = _currentUserKey!;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    if (_apiKeyController.text.isEmpty) {
      _showSnackBar('لطفاً کلید API را وارد کنید');
      return;
    }

    setState(() => _isLoading = true);

    final success = await omdbApiKeySwitcher.saveUserApiKey(_apiKeyController.text);

    setState(() {
      _isLoading = false;
      _currentUserKey = success ? _apiKeyController.text : _currentUserKey;
    });

    _showSnackBar(success ? 'کلید API با موفقیت ذخیره شد' : 'خطا در ذخیره کلید API');
  }

  Future<void> _clearApiKey() async {
    setState(() => _isLoading = true);

    final success = await omdbApiKeySwitcher.clearUserApiKey();

    setState(() {
      _isLoading = false;
      if (success) {
        _currentUserKey = null;
        _apiKeyController.clear();
      }
    });

    _showSnackBar(success ? 'کلید API با موفقیت حذف شد' : 'خطا در حذف کلید API');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'تنظیمات OMDB API',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'برای استفاده از کلید API شخصی خود، آن را در فیلد زیر وارد کنید. '
                    'این کار به شما اجازه می‌دهد از محدودیت‌های API پیش‌فرض جلوگیری کنید.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: 'کلید API شخصی OMDB',
                      hintText: 'کلید API خود را اینجا وارد کنید',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _apiKeyController.clear,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveApiKey,
                          child: const Text('ذخیره کلید API'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentUserKey != null ? _clearApiKey : null,
                          child: const Text('حذف کلید API'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'وضعیت فعلی',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentUserKey != null
                                ? 'درحال استفاده از کلید API شخصی شما'
                                : 'درحال استفاده از کلیدهای API پیش‌فرض',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
