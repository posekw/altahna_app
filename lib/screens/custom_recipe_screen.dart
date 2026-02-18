import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/coffee_calculator.dart';
import '../theme/app_theme.dart';

class CustomRecipeScreen extends StatefulWidget {
  final bool isArabic;
  const CustomRecipeScreen({super.key, required this.isArabic});

  @override
  State<CustomRecipeScreen> createState() => _CustomRecipeScreenState();
}

class _CustomRecipeScreenState extends State<CustomRecipeScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _methodController = TextEditingController(text: 'V60');
  final _notesController = TextEditingController();
  final _brewTimeController = TextEditingController(text: '3:00');

  // Slider values
  double _coffeeAmount = 20.0;
  double _waterAmount = 300.0;
  double _iceAmount = 0.0;
  int _temperature = 93;
  int _microns = 800;
  bool _hasIce = false;

  // Saved recipes
  List<CustomRecipeData> _savedRecipes = [];

  // Current view: 'form' or 'list'
  bool _showingList = false;

  // Localization
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'custom_recipe': 'Custom Recipe',
      'create_recipe': 'Create Recipe',
      'my_recipes': 'My Recipes',
      'recipe_name': 'Recipe Name',
      'recipe_name_hint': 'e.g. Morning V60',
      'brew_method': 'Brew Method',
      'method_hint': 'e.g. V60, AeroPress, Chemex...',
      'coffee_amount': 'Coffee',
      'water_amount': 'Water',
      'ice_amount': 'Ice',
      'add_ice': 'Add Ice',
      'temperature': 'Temperature',
      'grind_size': 'Grind Size',
      'brew_time': 'Brew Time',
      'brew_time_hint': 'e.g. 3:00',
      'notes': 'Notes',
      'notes_hint': 'Tips, origin, etc.',
      'preview': 'Preview',
      'save_recipe': 'Save Recipe',
      'share_recipe': 'Share as Image',
      'no_recipes': 'No saved recipes yet',
      'no_recipes_sub': 'Create your first custom recipe!',
      'recipe_saved': 'Recipe saved!',
      'recipe_deleted': 'Recipe deleted',
      'delete': 'Delete',
      'name_required': 'Please enter a recipe name',
      'fine': 'Fine (Low)',
      'coarse': 'Coarse (High)',
      'total_liquid': 'Total Water',
      'ice_label': 'Ice Amount',
      'hot_water': 'Hot Water',
      'temp': 'Temp',
      'grind': 'Grind',
      'grind_medium_sand': 'Medium (Like V60 / Sand)',
      'grind_medium_fine': 'Medium-Fine (Like Moka Pot)',
      'grind_medium_fine_salt': 'Medium-Fine (Like AeroPress / Table Salt)',
      'grind_coarse_sea_salt': 'Coarse (Like French Press / Sea Salt)',
      'grind_fine_table_salt': 'Fine (Like Espresso / Table Salt)',
      'grind_medium_coarse': 'Medium-Coarse (Like Chemex)',
      'grind_very_coarse_rock': 'Very Coarse (Like Cold Brew / Rock Salt)',
      'undo': 'Undo',
    },
    'ar': {
      'custom_recipe': 'وصفة مخصصة',
      'create_recipe': 'إنشاء وصفة',
      'my_recipes': 'وصفاتي',
      'recipe_name': 'اسم الوصفة',
      'recipe_name_hint': 'مثال: V60 صباحي',
      'brew_method': 'طريقة التحضير',
      'method_hint': 'مثال: V60, إيروبريس, كيمكس...',
      'coffee_amount': 'البن',
      'water_amount': 'الماء',
      'ice_amount': 'الثلج',
      'add_ice': 'إضافة ثلج',
      'temperature': 'الحرارة',
      'grind_size': 'حجم الطحنة',
      'brew_time': 'وقت التحضير',
      'brew_time_hint': 'مثال: 3:00',
      'notes': 'ملاحظات',
      'notes_hint': 'نصائح، أصل البن، إلخ.',
      'preview': 'معاينة',
      'save_recipe': 'حفظ الوصفة',
      'share_recipe': 'مشاركة كصورة',
      'no_recipes': 'لا توجد وصفات محفوظة',
      'no_recipes_sub': 'أنشئ أول وصفة مخصصة!',
      'recipe_saved': 'تم حفظ الوصفة!',
      'recipe_deleted': 'تم حذف الوصفة',
      'delete': 'حذف',
      'name_required': 'الرجاء إدخال اسم الوصفة',
      'fine': 'ناعمة (واطي)',
      'coarse': 'خشنة (عالي)',
      'total_liquid': 'إجمالي الماء',
      'ice_label': 'كمية الثلج',
      'hot_water': 'الماء الحار',
      'temp': 'الحرارة',
      'grind': 'الطحنة',
      'grind_medium_sand': 'وسط (مثل V60 / رمل)',
      'grind_medium_fine': 'وسط-ناعمة (مثل موكا بوت)',
      'grind_medium_fine_salt': 'وسط-ناعمة (مثل إيروبريس / ملح طعام)',
      'grind_coarse_sea_salt': 'خشنة (مثل فرنش برس / ملح بحري)',
      'grind_fine_table_salt': 'ناعمة (مثل إسبريسو / ملح طعام)',
      'grind_medium_coarse': 'وسط-خشنة (مثل كيمكس)',
      'grind_very_coarse_rock': 'خشنة جداً (مثل كولد برو / ملح صخري)',
      'undo': 'تراجع',
    },
  };

  String tr(String key) => _localizedValues[widget.isArabic ? 'ar' : 'en']![key] ?? key;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _methodController.dispose();
    _notesController.dispose();
    _brewTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('custom_recipes');
    if (jsonStr != null) {
      final List<dynamic> list = jsonDecode(jsonStr);
      setState(() {
        _savedRecipes = list.map((e) => CustomRecipeData.fromJson(e)).toList();
        _savedRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    }
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_savedRecipes.map((e) => e.toJson()).toList());
    await prefs.setString('custom_recipes', jsonStr);
  }

  void _saveCurrentRecipe() {
    if (!_formKey.currentState!.validate()) return;

    final recipe = CustomRecipeData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      method: _methodController.text.trim(),
      coffeeAmount: _coffeeAmount,
      waterAmount: _waterAmount,
      iceAmount: _hasIce ? _iceAmount : 0,
      temperature: _temperature,
      microns: _microns,
      brewTime: _brewTimeController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _savedRecipes.insert(0, recipe);
    });
    _saveRecipes();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('recipe_saved'))),
    );
  }

  void _deleteRecipe(int index) {
    final deleted = _savedRecipes[index];
    setState(() {
      _savedRecipes.removeAt(index);
    });
    _saveRecipes();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('recipe_deleted')),
        action: SnackBarAction(
          label: tr('undo'),
          onPressed: () {
            setState(() {
              _savedRecipes.insert(index, deleted);
            });
            _saveRecipes();
          },
        ),
      ),
    );
  }

  void _loadRecipeIntoForm(CustomRecipeData recipe) {
    setState(() {
      _nameController.text = recipe.name;
      _methodController.text = recipe.method;
      _coffeeAmount = recipe.coffeeAmount;
      _waterAmount = recipe.waterAmount;
      _iceAmount = recipe.iceAmount;
      _hasIce = recipe.iceAmount > 0;
      _temperature = recipe.temperature;
      _microns = recipe.microns;
      _brewTimeController.text = recipe.brewTime;
      _notesController.text = recipe.notes;
      _showingList = false;
    });
  }

  Future<void> _captureAndShareRecipe() async {
    try {
      RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/custom_recipe.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'My Coffee Recipe from Al-Tahna ☕',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  String _getGrindDescription() {
    if (_microns < 350) return tr('grind_fine_table_salt');
    if (_microns < 550) return tr('grind_medium_fine');
    if (_microns < 750) return tr('grind_medium_sand');
    if (_microns < 950) return tr('grind_medium_coarse');
    if (_microns < 1300) return tr('grind_coarse_sea_salt');
    return tr('grind_very_coarse_rock');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_showingList ? tr('my_recipes') : tr('create_recipe')),
          actions: [
            IconButton(
              icon: Icon(_showingList ? Icons.add_circle_outline : Icons.list),
              tooltip: _showingList ? tr('create_recipe') : tr('my_recipes'),
              onPressed: () => setState(() => _showingList = !_showingList),
            ),
          ],
        ),
        body: _showingList ? _buildRecipeList() : _buildCreateForm(isDarkMode),
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_savedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              tr('no_recipes'),
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              tr('no_recipes_sub'),
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _savedRecipes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.accent.withOpacity(0.2),
              child: const Icon(Icons.coffee, color: AppTheme.accent),
            ),
            title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${recipe.method}  •  ${recipe.coffeeAmount.round()}g  •  ${recipe.brewTime}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteRecipe(index),
            ),
            onTap: () => _loadRecipeIntoForm(recipe),
          ),
        );
      },
    );
  }

  Widget _buildCreateForm(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe Name
            _buildSectionTitle(tr('recipe_name')),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: tr('recipe_name_hint'),
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? tr('name_required') : null,
            ),
            const SizedBox(height: 20),

            // Brew Method
            _buildSectionTitle(tr('brew_method')),
            TextFormField(
              controller: _methodController,
              decoration: InputDecoration(
                hintText: tr('method_hint'),
                prefixIcon: const Icon(FontAwesomeIcons.mugHot, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 20),

            // Coffee Amount
            _buildSectionTitle('${tr('coffee_amount')}: ${_coffeeAmount.round()}g'),
            Slider(
              value: _coffeeAmount,
              min: 5,
              max: 80,
              divisions: 75,
              label: '${_coffeeAmount.round()}g',
              onChanged: (val) => setState(() => _coffeeAmount = val),
            ),
            const SizedBox(height: 12),

            // Water Amount
            _buildSectionTitle('${tr('water_amount')}: ${_waterAmount.round()} ml'),
            Slider(
              value: _waterAmount,
              min: 20,
              max: 1000,
              divisions: 98,
              label: '${_waterAmount.round()} ml',
              onChanged: (val) => setState(() => _waterAmount = val),
            ),
            const SizedBox(height: 12),

            // Ice Toggle + Amount
            Row(
              children: [
                Expanded(child: _buildSectionTitle(tr('add_ice'))),
                Switch(
                  value: _hasIce,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => setState(() {
                    _hasIce = val;
                    if (!val) _iceAmount = 0;
                  }),
                ),
              ],
            ),
            if (_hasIce) ...[
              _buildSectionTitle('${tr('ice_amount')}: ${_iceAmount.round()} ml'),
              Slider(
                value: _iceAmount,
                min: 0,
                max: 500,
                divisions: 50,
                label: '${_iceAmount.round()} ml',
                onChanged: (val) => setState(() => _iceAmount = val),
              ),
              const SizedBox(height: 12),
            ],

            // Temperature
            _buildSectionTitle('${tr('temperature')}: $_temperature°C'),
            Slider(
              value: _temperature.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '$_temperature°C',
              onChanged: (val) => setState(() => _temperature = val.round()),
            ),
            const SizedBox(height: 12),

            // Grind Size
            _buildSectionTitle('${tr('grind_size')}: $_microns µm'),
            Slider(
              value: _microns.toDouble(),
              min: 100,
              max: 1500,
              divisions: 140,
              label: '$_microns µm',
              onChanged: (val) => setState(() => _microns = val.round()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('fine'), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  Flexible(
                    child: Text(
                      _getGrindDescription(),
                      style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(tr('coarse'), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Brew Time
            _buildSectionTitle(tr('brew_time')),
            TextFormField(
              controller: _brewTimeController,
              decoration: InputDecoration(
                hintText: tr('brew_time_hint'),
                prefixIcon: const Icon(Icons.timer),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            _buildSectionTitle(tr('notes')),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: tr('notes_hint'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.sticky_note_2_outlined),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 32),

            // Preview Section
            _buildSectionTitle(tr('preview')),
            _buildPreviewCard(isDarkMode),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveCurrentRecipe,
                    icon: const Icon(Icons.save),
                    label: Text(tr('save_recipe')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _captureAndShareRecipe,
                    icon: const Icon(Icons.share),
                    label: Text(tr('share_recipe')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.black87 : Colors.white;
    final labelColor = isDarkMode ? Colors.black87 : Colors.white70;
    final totalLiquid = _waterAmount + (_hasIce ? _iceAmount : 0);

    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? tr('custom_recipe')
                            : _nameController.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _methodController.text,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _brewTimeController.text.isEmpty ? '--:--' : _brewTimeController.text,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Total Liquid
            _buildRecipeRow(
              FontAwesomeIcons.droplet,
              tr('total_liquid'),
              '${totalLiquid.round()} ml',
              textColor,
              labelColor,
            ),
            Divider(color: labelColor.withOpacity(0.2), height: 24),

            // Ice breakdown
            if (_hasIce && _iceAmount > 0) ...[
              _buildRecipeRow(
                FontAwesomeIcons.cube,
                tr('ice_label'),
                '${_iceAmount.round()} g',
                textColor,
                labelColor,
              ),
              const SizedBox(height: 12),
              _buildRecipeRow(
                FontAwesomeIcons.fire,
                tr('hot_water'),
                '${_waterAmount.round()} ml',
                textColor,
                labelColor,
              ),
              Divider(color: labelColor.withOpacity(0.2), height: 24),
            ],

            // Temp + Grind
            Row(
              children: [
                Expanded(
                  child: _buildRecipeDetail(
                    tr('temp'),
                    '$_temperature°C',
                    textColor,
                    labelColor,
                  ),
                ),
                Expanded(
                  child: _buildRecipeDetail(
                    tr('grind'),
                    '${_getGrindDescription()}\n(~$_microns µm)',
                    textColor,
                    labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grind slider (read-only)
            _buildGrindSlider(_microns, isDarkMode),
            const SizedBox(height: 16),

            // Notes
            if (_notesController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.05)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: AppTheme.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _notesController.text,
                        style: TextStyle(
                          color: isDarkMode ? Colors.black54 : Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Al-Tahna branding
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Al-Tahna ☕',
                style: TextStyle(
                  color: labelColor.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrindSlider(int microns, bool isDarkMode) {
    double sliderValue = (microns - 100) / (1500 - 100);
    sliderValue = sliderValue.clamp(0.0, 1.0);

    final labelColor = isDarkMode ? Colors.black54 : Colors.white54;
    final trackColor = isDarkMode ? Colors.black12 : Colors.white24;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tr('fine'), style: TextStyle(color: labelColor, fontSize: 10)),
            Text(tr('coarse'), style: TextStyle(color: labelColor, fontSize: 10)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            disabledActiveTrackColor: AppTheme.accent,
            disabledInactiveTrackColor: trackColor,
            disabledThumbColor: AppTheme.accent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
          ),
          child: Slider(
            value: sliderValue,
            onChanged: null, // Read-only
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildRecipeRow(
      IconData icon, String label, String value, Color textColor, Color labelColor) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: labelColor, fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildRecipeDetail(String label, String value, Color textColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
      ],
    );
  }
}
