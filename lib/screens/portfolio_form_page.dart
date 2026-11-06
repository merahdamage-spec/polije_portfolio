import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../database/db_helper.dart';
import '../models/portfolio.dart';
import '../widgets/gradient_header.dart';
import '../widgets/portfolio_card.dart';

/// Form CREATE (portfolio == null) dan UPDATE (portfolio != null).
class PortfolioFormPage extends StatefulWidget {
  final Portfolio? portfolio;
  final VoidCallback? onSaved;
  const PortfolioFormPage({super.key, this.portfolio, this.onSaved});

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late String _category;
  late String _tech;
  String? _imagePath;
  bool _saving = false;

  bool get _isEdit => widget.portfolio != null;

  @override
  void initState() {
    super.initState();
    final e = widget.portfolio;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? kCategories.first;
    _tech = e?.technology ?? kTechnologies.first;
    _imagePath = e?.imagePath;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (x == null) return;
    final bytes = await x.readAsBytes(); // aman untuk web & mobile
    setState(() => _imagePath = base64Encode(bytes));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = Portfolio(
      id: widget.portfolio?.id,
      title: _title.text.trim(),
      category: _category,
      technology: _tech,
      description: _desc.text.trim(),
      imagePath: _imagePath,
      createdAt: widget.portfolio?.createdAt ?? DateTime.now().toIso8601String(),
    );

    try {
      if (_isEdit) {
        await DbHelper.instance.update(item); // UPDATE
      } else {
        await DbHelper.instance.insert(item); // CREATE
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Portofolio berhasil diperbarui'
              : 'Portofolio berhasil ditambahkan')));
      if (_isEdit) Navigator.pop(context);
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: _isEdit ? 'Edit Portofolio' : 'Tambah Portofolio',
            subtitle: 'Isi data karya kamu dengan lengkap',
            leading: _isEdit
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context))
                : null,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PortfolioImage(
                                  path: _imagePath,
                                  width: double.infinity,
                                  height: 170),
                              const Positioned(
                                bottom: 8,
                                right: 8,
                                child: CircleAvatar(
                                    child: Icon(Icons.photo_camera)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                            labelText: 'Judul Karya',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Judul wajib diisi';
                          }
                          if (v.trim().length < 3) return 'Minimal 3 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.folder_outlined),
                            border: OutlineInputBorder()),
                        items: kCategories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _tech,
                        decoration: const InputDecoration(
                            labelText: 'Teknologi',
                            prefixIcon: Icon(Icons.code),
                            border: OutlineInputBorder()),
                        items: kTechnologies
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _tech = v!),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _desc,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            alignLabelWithHint: true,
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.notes)),
                            border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }
                          if (v.trim().length < 10) {
                            return 'Minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                        style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
