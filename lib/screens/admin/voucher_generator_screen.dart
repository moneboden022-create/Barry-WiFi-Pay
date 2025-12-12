// lib/screens/admin/voucher_generator_screen.dart
// 🎟️ Écran de génération massive de vouchers - BARRY WiFi
// Interface complète pour générer, visualiser et exporter des vouchers

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/admin_voucher_service.dart';

class VoucherGeneratorScreen extends StatefulWidget {
  const VoucherGeneratorScreen({super.key});

  @override
  State<VoucherGeneratorScreen> createState() => _VoucherGeneratorScreenState();
}

class _VoucherGeneratorScreenState extends State<VoucherGeneratorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // État de génération
  bool _isGenerating = false;
  bool _isExporting = false;
  String? _lastBatchId;
  BulkGenerationResult? _lastResult;
  
  // Formulaire
  String _selectedCategory = 'individual';
  VoucherPreset? _selectedPreset;
  final _quantityController = TextEditingController(text: '100');
  final _prefixController = TextEditingController();
  
  // Configuration personnalisée
  bool _useCustomConfig = false;
  final _customPriceController = TextEditingController(text: '500');
  final _customDurationController = TextEditingController(text: '60');
  final _customLabelController = TextEditingController(text: 'Pass Personnalisé');
  int _customMaxDevices = 1;
  
  // Liste des vouchers générés
  List<GeneratedVoucher> _generatedVouchers = [];
  
  // Statistiques
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedPreset = VoucherPresets.individual.first;
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _prefixController.dispose();
    _customPriceController.dispose();
    _customDurationController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await AdminVoucherService.getStatsByCategory();
    if (mounted) {
      setState(() => _stats = stats);
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      final presets = VoucherPresets.getByCategory(category);
      _selectedPreset = presets.isNotEmpty ? presets.first : null;
    });
  }

  Future<void> _generateVouchers() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    
    if (quantity < 1 || quantity > 10000) {
      _showSnackBar('⚠️ Quantité invalide (1 - 10000)', isError: true);
      return;
    }

    if (!_useCustomConfig && _selectedPreset == null) {
      _showSnackBar('⚠️ Veuillez sélectionner un type de voucher', isError: true);
      return;
    }

    setState(() => _isGenerating = true);

    try {
      BulkGenerationResult result;
      
      if (_useCustomConfig) {
        // Configuration personnalisée
        result = await AdminVoucherService.generateBulk(
          category: _selectedCategory,
          type: _selectedCategory,
          durationMinutes: int.tryParse(_customDurationController.text) ?? 60,
          maxDevices: _customMaxDevices,
          quantity: quantity,
          price: int.tryParse(_customPriceController.text) ?? 500,
          label: _customLabelController.text.isNotEmpty 
              ? _customLabelController.text 
              : 'Pass Personnalisé',
          prefix: _prefixController.text.isNotEmpty ? _prefixController.text : null,
        );
      } else {
        // Utiliser le preset sélectionné
        result = await AdminVoucherService.generateFromPreset(
          category: _selectedCategory,
          preset: _selectedPreset!,
          quantity: quantity,
          prefix: _prefixController.text.isNotEmpty ? _prefixController.text : null,
        );
      }

      if (result.success) {
        setState(() {
          _lastBatchId = result.batchId;
          _lastResult = result;
          _generatedVouchers = result.vouchers;
        });
        _showSnackBar('✅ ${result.created} vouchers générés avec succès!');
        _loadStats();
        _tabController.animateTo(1); // Aller à l'onglet "Résultats"
      } else {
        _showSnackBar('❌ Erreur: ${result.error ?? "Erreur inconnue"}', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _exportPDF() async {
    if (_lastBatchId == null) {
      _showSnackBar('⚠️ Générez d\'abord des vouchers', isError: true);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final filePath = await AdminVoucherService.exportPDF(batchId: _lastBatchId);
      
      if (filePath != null) {
        _showSnackBar('✅ PDF exporté: $filePath');
        // Ouvrir le fichier
        if (Platform.isAndroid || Platform.isIOS) {
          await launchUrl(Uri.file(filePath));
        }
      } else {
        _showSnackBar('❌ Échec de l\'export PDF', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportExcel() async {
    if (_lastBatchId == null) {
      _showSnackBar('⚠️ Générez d\'abord des vouchers', isError: true);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final filePath = await AdminVoucherService.exportExcel(batchId: _lastBatchId);
      
      if (filePath != null) {
        _showSnackBar('✅ Excel exporté: $filePath');
        // Ouvrir le fichier
        if (Platform.isAndroid || Platform.isIOS) {
          await launchUrl(Uri.file(filePath));
        }
      } else {
        _showSnackBar('❌ Échec de l\'export Excel', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('📋 Code copié!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎟️ Génération Massive'),
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Générer'),
            Tab(icon: Icon(Icons.list_alt), text: 'Résultats'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratorTab(),
          _buildResultsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  // ============================================================
  // 🎯 ONGLET GÉNÉRATION
  // ============================================================
  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          _buildSectionHeader(
            icon: Icons.category,
            title: '1️⃣ Catégorie de vouchers',
          ),
          const SizedBox(height: 12),
          _buildCategorySelector(),
          
          const SizedBox(height: 24),
          
          // Type de voucher
          _buildSectionHeader(
            icon: Icons.style,
            title: '2️⃣ Type de voucher',
          ),
          const SizedBox(height: 12),
          _buildPresetSelector(),
          
          const SizedBox(height: 16),
          
          // Configuration personnalisée
          _buildCustomConfigToggle(),
          if (_useCustomConfig) ...[
            const SizedBox(height: 16),
            _buildCustomConfigForm(),
          ],
          
          const SizedBox(height: 24),
          
          // Quantité
          _buildSectionHeader(
            icon: Icons.numbers,
            title: '3️⃣ Quantité à générer',
          ),
          const SizedBox(height: 12),
          _buildQuantityInput(),
          
          const SizedBox(height: 24),
          
          // Options avancées
          _buildSectionHeader(
            icon: Icons.settings,
            title: '4️⃣ Options avancées',
          ),
          const SizedBox(height: 12),
          _buildAdvancedOptions(),
          
          const SizedBox(height: 32),
          
          // Résumé et bouton
          _buildSummaryCard(),
          
          const SizedBox(height: 16),
          
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'key': 'individual', 'label': '👤 Individuels', 'desc': 'Pass uniques'},
      {'key': 'subscription', 'label': '📅 Abonnements', 'desc': 'Semaine/Mois/Année'},
      {'key': 'business', 'label': '🏢 Entreprise', 'desc': 'Multi-employés'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat['key'];
        return ChoiceChip(
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cat['label']!, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
              Text(
                cat['desc']!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => _onCategoryChanged(cat['key']!),
          selectedColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildPresetSelector() {
    final presets = VoucherPresets.getByCategory(_selectedCategory);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: presets.asMap().entries.map((entry) {
          final preset = entry.value;
          final isSelected = _selectedPreset == preset;
          
          return InkWell(
            onTap: () => setState(() => _selectedPreset = preset),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                border: entry.key < presets.length - 1
                    ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
              ),
              child: Row(
                children: [
                  Radio<VoucherPreset>(
                    value: preset,
                    groupValue: _selectedPreset,
                    onChanged: (v) => setState(() => _selectedPreset = v),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${preset.durationLabel} • ${preset.maxDevices} appareil(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      preset.priceLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomConfigToggle() {
    return SwitchListTile(
      title: const Text('Configuration personnalisée'),
      subtitle: const Text('Définir manuellement prix, durée, etc.'),
      value: _useCustomConfig,
      onChanged: (v) => setState(() => _useCustomConfig = v),
      secondary: const Icon(Icons.tune),
    );
  }

  Widget _buildCustomConfigForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _customLabelController,
              decoration: const InputDecoration(
                labelText: 'Nom du voucher',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix (GNF)',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _customDurationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durée (minutes)',
                      prefixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Appareils max:'),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _customMaxDevices,
                  items: [1, 2, 3, 5, 10, 30, 50, 100, 999]
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v == 999 ? 'Illimité' : '$v'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _customMaxDevices = v ?? 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    final quickOptions = [10, 50, 100, 200, 500, 1000, 5000];
    
    return Column(
      children: [
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantité',
            hintText: 'Ex: 100, 500, 1000...',
            prefixIcon: const Icon(Icons.format_list_numbered),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText: 'Maximum: 10 000 vouchers par lot',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickOptions.map((qty) {
            return ActionChip(
              label: Text('$qty'),
              onPressed: () => setState(() => _quantityController.text = '$qty'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return TextField(
      controller: _prefixController,
      decoration: InputDecoration(
        labelText: 'Préfixe personnalisé (optionnel)',
        hintText: 'Ex: PROMO, VIP, CLIENT...',
        prefixIcon: const Icon(Icons.abc),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        helperText: 'Le code sera: PREFIXE-XXXXXXXX',
      ),
    );
  }

  Widget _buildSummaryCard() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final preset = _useCustomConfig ? null : _selectedPreset;
    final price = _useCustomConfig
        ? (int.tryParse(_customPriceController.text) ?? 0)
        : (preset?.price ?? 0);
    final totalValue = quantity * price;

    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize, size: 20),
                SizedBox(width: 8),
                Text(
                  'Résumé de la génération',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            _buildSummaryRow('Catégorie', _selectedCategory.toUpperCase()),
            _buildSummaryRow(
              'Type',
              _useCustomConfig
                  ? _customLabelController.text
                  : (preset?.label ?? '-'),
            ),
            _buildSummaryRow('Quantité', '$quantity vouchers'),
            _buildSummaryRow(
              'Prix unitaire',
              '${_formatPrice(price)} GNF',
            ),
            const Divider(),
            _buildSummaryRow(
              'VALEUR TOTALE',
              '${_formatPrice(totalValue)} GNF',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isBold ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateVouchers,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Génération en cours...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'GÉNÉRER LES VOUCHERS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // 📋 ONGLET RÉSULTATS
  // ============================================================
  Widget _buildResultsTab() {
    if (_generatedVouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun voucher généré',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez l\'onglet "Générer" pour créer des vouchers',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barre d'actions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_generatedVouchers.length} vouchers',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_lastBatchId != null)
                      Text(
                        'Lot: $_lastBatchId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Boutons d'export
              IconButton(
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: _isExporting ? null : _exportPDF,
                tooltip: 'Export PDF',
              ),
              IconButton(
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.table_chart, color: Colors.green),
                onPressed: _isExporting ? null : _exportExcel,
                tooltip: 'Export Excel',
              ),
            ],
          ),
        ),
        
        // Liste des vouchers
        Expanded(
          child: ListView.builder(
            itemCount: _generatedVouchers.length,
            itemBuilder: (context, index) {
              final voucher = _generatedVouchers[index];
              return _buildVoucherTile(voucher, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherTile(GeneratedVoucher voucher, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: Text('${index + 1}'),
        ),
        title: Text(
          voucher.code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${voucher.label ?? voucher.category} • ${_formatPrice(voucher.price)} GNF',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton QR
            if (voucher.qrData != null)
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () => _showQRDialog(voucher),
              ),
            // Bouton copier
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(voucher.code),
            ),
          ],
        ),
        onTap: () => _showVoucherDetails(voucher),
      ),
    );
  }

  void _showQRDialog(GeneratedVoucher voucher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(voucher.code),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (voucher.qrData != null)
              Image.memory(
                base64Decode(voucher.qrData!),
                width: 200,
                height: 200,
              )
            else
              QrImageView(
                data: voucher.code,
                size: 200,
              ),
            const SizedBox(height: 16),
            Text(voucher.label ?? "Voucher"),
            Text('${_formatPrice(voucher.price)} GNF'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copier'),
            onPressed: () {
              _copyToClipboard(voucher.code);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showVoucherDetails(GeneratedVoucher voucher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // QR Code
            Center(
              child: voucher.qrData != null
                  ? Image.memory(
                      base64Decode(voucher.qrData!),
                      width: 150,
                      height: 150,
                    )
                  : QrImageView(data: voucher.code, size: 150),
            ),
            
            const SizedBox(height: 16),
            
            // Code
            Center(
              child: SelectableText(
                voucher.code,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Détails
            _buildDetailRow('Catégorie', voucher.category.toUpperCase()),
            _buildDetailRow('Label', voucher.label ?? '-'),
            _buildDetailRow('Prix', '${_formatPrice(voucher.price)} GNF'),
            _buildDetailRow('Durée', '${voucher.durationMinutes} minutes'),
            _buildDetailRow('Appareils max', '${voucher.maxDevices}'),
            _buildDetailRow('Statut', voucher.status.toUpperCase()),
            if (voucher.createdAt != null)
              _buildDetailRow('Créé le', voucher.createdAt!),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier'),
                    onPressed: () {
                      _copyToClipboard(voucher.code);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    onPressed: () {
                      // TODO: Implémenter le partage
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 ONGLET STATISTIQUES
  // ============================================================
  Widget _buildStatsTab() {
    if (_stats.isEmpty || _stats.containsKey('error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              onPressed: _loadStats,
            ),
          ],
        ),
      );
    }

    final global = _stats['global'] as Map<String, dynamic>? ?? {};
    final byCategory = _stats['by_category'] as Map<String, dynamic>? ?? {};
    final recentBatches = _stats['recent_batches'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats globales
          _buildStatsCard(
            title: '📊 Statistiques Globales',
            children: [
              _buildStatTile('Total', '${global['total'] ?? 0}', Icons.confirmation_number),
              _buildStatTile('Utilisés', '${global['used'] ?? 0}', Icons.check_circle, color: Colors.green),
              _buildStatTile('Disponibles', '${global['available'] ?? 0}', Icons.hourglass_empty, color: Colors.orange),
              _buildStatTile('Taux d\'utilisation', '${global['usage_rate'] ?? 0}%', Icons.percent),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats par catégorie
          _buildStatsCard(
            title: '📦 Par Catégorie',
            children: byCategory.entries.map((entry) {
              final cat = entry.value as Map<String, dynamic>;
              return ExpansionTile(
                title: Text(entry.key.toUpperCase()),
                subtitle: Text('${cat['total'] ?? 0} vouchers'),
                children: [
                  ListTile(
                    dense: true,
                    title: const Text('Utilisés'),
                    trailing: Text('${cat['used'] ?? 0}'),
                  ),
                  ListTile(
                    dense: true,
                    title: const Text('Disponibles'),
                    trailing: Text('${cat['available'] ?? 0}'),
                  ),
                  ListTile(
                    dense: true,
                    title: const Text('Revenu potentiel'),
                    trailing: Text('${_formatPrice(cat['revenue_potential'] ?? 0)} GNF'),
                  ),
                  ListTile(
                    dense: true,
                    title: const Text('Revenu réalisé'),
                    trailing: Text('${_formatPrice(cat['revenue_realized'] ?? 0)} GNF'),
                  ),
                ],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Lots récents
          if (recentBatches.isNotEmpty)
            _buildStatsCard(
              title: '📋 Lots Récents',
              children: recentBatches.map((batch) {
                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(batch['batch_id'] ?? '-'),
                  subtitle: Text(batch['created_at'] ?? ''),
                  trailing: Chip(label: Text('${batch['count']}')),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

