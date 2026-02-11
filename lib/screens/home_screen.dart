import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/coffee_calculator.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State Variables
  BrewMethod _selectedMethod = BrewMethod.v60;
  BrewStyle _selectedStyle = BrewStyle.hot;
  RoastLevel _selectedRoast = RoastLevel.medium;
  double _coffeeDose = 20.0;
  
  // Taste Value: 0..4
  // 0: Very Sour, 1: Sour, 2: Balanced, 3: Bitter, 4: Very Bitter
  double _tasteValue = 2.0; 
  int _pourCount = 2; // Default Standard V60 

  // Language State
  bool _isArabic = false;

  // Localization Map
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Coffee Calculator ☕',
      'method': 'Method',
      'style': 'Style',
      'v60': 'V60',
      'aeropress': 'AeroPress',
      'french_press': 'French Press',
      'espresso': 'Espresso',
      'cold_brew': 'Cold Brew',
      'hot': 'Hot',
      'iced': 'Iced',
      'roast_level': 'Roast Level',
      'light': 'Light\n(Fruity)',
      'medium': 'Medium\n(Balanced)',
      'dark': 'Dark\n(Bold)',
      'dose': 'Coffee Dose',
      'target_profile': 'Target Profile',
      'very_sour': 'Very Sour',
      'sour': 'Sour',
      'balanced': 'Balanced',
      'bitter': 'Bitter',
      'very_bitter': 'Very Bitter',
      'your_recipe': 'Your Recipe',
      'your_recipe': 'Your Recipe',
      'total_liquid': 'Total Water',
      'ice_amount': 'Ice Amount',
      'hot_water': 'Hot Water',
      'water_amount': 'Water Amount',
      'temp': 'Temp',
      'grind': 'Grind',
      'about': 'About',
      'about_content': 'Calculations based on standard SCAA guidelines.\nSour? Increase temp/ratio.\nBitter? Decrease temp/ratio.',
      'fine': 'Fine (Low)',
      'coarse': 'Coarse (High)',
      'grind_medium_sand': 'Medium (Like V60 / Sand)',
      'grind_medium_fine': 'Medium-Fine (Like Moka Pot)',
      'grind_medium_fine_salt': 'Medium-Fine (Like AeroPress / Table Salt)',
      'grind_coarse_sea_salt': 'Coarse (Like French Press / Sea Salt)',
      'grind_fine_table_salt': 'Fine (Like Espresso / Table Salt)',
      'grind_medium_coarse': 'Medium-Coarse (Like Chemex)',
      'grind_very_coarse_rock': 'Very Coarse (Like Cold Brew / Rock Salt)',
      'advice_good_shot': 'Good shot!',
      'advice_adjust_grind': 'Adjust grind size slightly.',
      'advice_very_sour': 'Ideally for Very Sour coffee: Grind FINER, Increase Temp significantly.',
      'advice_sour': 'For Sour coffee: Increase ratio slightly or grind a bit finer.',
      'advice_balanced': 'Perfect balanced settings.',
      'advice_bitter': 'For Bitter coffee: Coarsen grind or lower temp slightly.',
      'advice_very_bitter': 'For Very Bitter coffee: Grind much COARSER and lower temp.',
      'pulse_count': 'Number of Pours',
      'pour': 'Pour',
      'bloom': 'Bloom',
      'menu': 'Menu',
      'privacy': 'Privacy Policy',
      'contact': 'Contact Us',
      'offers': 'Offers',
      'instagram': 'Instagram',
      'whatsapp': 'WhatsApp',
      'social_media': 'Social Media',
      'general': 'General',
      'coming_soon': 'Coming Soon',
      'language': 'Language',
      'theme': 'Theme',
      'total': 'Total',
      'pressure': 'Pressure',
      'flow': 'Flow',
      'bars': 'Bars',
    },
    'ar': {
      'app_title': 'حاسبة القهوة ☕',
      'method': 'طريقة التحضير',
      'style': 'النمط',
      'v60': 'V60',
      'aeropress': 'إيروبريس',
      'french_press': 'فرنش برس',
      'espresso': 'إسبريسو',
      'cold_brew': 'كولد برو',
      'hot': 'حار',
      'iced': 'بارد',
      'roast_level': 'درجة التحميص',
      'light': 'فاتحة\n(فاكهية)',
      'medium': 'وسط\n(متوازنة)',
      'dark': 'غامقة\n(قوية)',
      'dose': 'كمية البن',
      'target_profile': 'الطعم المطلوب',
      'very_sour': 'حامضة جداً',
      'sour': 'حامضة',
      'balanced': 'موزونة',
      'bitter': 'مرة',
      'very_bitter': 'مرة جداً',
      'your_recipe': 'وصفـتك',
      'total_liquid': 'إجمالي الماء',
      'ice_amount': 'كمية الثلج',
      'hot_water': 'الماء الحار',
      'water_amount': 'كمية الماء',
      'temp': 'الحرارة',
      'grind': 'الطحنة',
      'about': 'عن التطبيق',
      'about_content': 'الحسابات مبنية على معايير القهوة المختصة.\nإذا كانت حامضة: ارفع الحرارة ونعم الطحنة.\nإذا كانت مرة: قلل الحرارة وحشن الطحنة.',
      'fine': 'ناعمة (واطي)',
      'coarse': 'خشنة (عالي)',
      'grind_medium_sand': 'وسط (مثل V60 / رمل)',
      'grind_medium_fine': 'وسط-ناعمة (مثل موكا بوت)',
      'grind_medium_fine_salt': 'وسط-ناعمة (مثل إيروبريس / ملح طعام)',
      'grind_coarse_sea_salt': 'خشنة (مثل فرنش برس / ملح بحري)',
      'grind_fine_table_salt': 'ناعمة (مثل إسبريسو / ملح طعام)',
      'grind_medium_coarse': 'وسط-خشنة (مثل كيمكس)',
      'grind_very_coarse_rock': 'خشنة جداً (مثل كولد برو / ملح صخري)',
      'advice_good_shot': 'استخلاص ممتاز!',
      'advice_adjust_grind': 'عدل الطحنة قليلاً.',
      'advice_very_sour': 'للقهوة الحامضة جداً: نعم الطحنة وارفع الحرارة كثيراً.',
      'advice_sour': 'للقهوة الحامضة: زِد الريشيو قليلاً أو نعم الطحنة.',
      'advice_balanced': 'إعدادات موزونة ومثالية.',
      'advice_bitter': 'للقهوة المرة: خشن الطحنة أو قلل الحرارة قليلاً.',
      'advice_very_bitter': 'للقهوة المرة جداً: خشن الطحنة كثيراً وقلل الحرارة.',
      'pulse_count': 'عدد الصبات',
      'pour': 'صبة',
      'bloom': 'ترطيب',
      'menu': 'القائمة',
      'privacy': 'سياسة الخصوصية',
      'contact': 'تواصل معنا',
      'offers': 'العروض',
      'instagram': 'انستقرام',
      'whatsapp': 'واتس آب',
      'social_media': 'تواصل اجتماعي',
      'general': 'عام',
      'coming_soon': 'قريباً',
      'language': 'الغة (Language)',
      'theme': 'المظهر (Theme)',
      'total': 'الإجمالي',
      'pressure': 'الضغط',
      'flow': 'التدفق',
      'bars': 'بار',
    },
  };

  String tr(String key) => _localizedValues[_isArabic ? 'ar' : 'en']![key] ?? key;

  TasteProfile get _tasteProfile {
    if (_tasteValue < 0.5) return TasteProfile.verySour;
    if (_tasteValue < 1.5) return TasteProfile.sour;
    if (_tasteValue > 3.5) return TasteProfile.veryBitter;
    if (_tasteValue > 2.5) return TasteProfile.bitter;
    return TasteProfile.balanced;
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/96555224500');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://instagram.com/al_timemi');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Instagram')),
        );
      }
    }
  }

  void _showOffersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('offers'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text("48e", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: const Text("48e Store", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("10% Discount"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text("AJH", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri url = Uri.parse('https://48e.co/');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Could not launch Store')),
                         );
                       }
                    }
                  },
                  onLongPress: () {
                    Clipboard.setData(const ClipboardData(text: "AJH"));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code 'AJH' copied to clipboard!")),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Tap to visit • Long press to copy code",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Recipe
    final recipe = CoffeeCalculator.calculate(
      coffeeGrams: _coffeeDose,
      roast: _selectedRoast,
      method: _selectedMethod,
      style: _selectedStyle,
      taste: _tasteProfile,
      pourCount: _pourCount,
    );

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('app_title')),
          // Remove actions or keep them? User asked for drawer. 
          // Usually drawer replaces leading icon, actions are still okay.
          // Let's keep actions for Theme/Lang but maybe remove explicit WA button if it's in drawer now?
          // User said "But currently will use [drawer] later... currently we will join my Instagram and WhatsApp".
          // It implies he wants them ACCESSIBLE now.
          // Let's keep the AppBar actions for quick access but ALSO add the drawer.
          actions: [],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
             children: [
               const SizedBox(height: 20), // Spacing instead of Header
               ListTile(
                 leading: const Icon(Icons.local_offer),
                 title: Text(tr('offers')),
                 onTap: () async {
                   Navigator.pop(context);
                   await Future.delayed(const Duration(milliseconds: 200));
                   if (context.mounted) _showOffersDialog(context);
                 },
               ),
               const Divider(),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Text(tr('social_media'), style: TextStyle(color: Colors.grey, fontSize: 12)),
               ),
               ListTile(
                 leading: const FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
                 title: Text(tr('instagram')),
                 subtitle: const Text("@al_timemi"),
                 onTap: () {
                   Navigator.pop(context);
                   _launchInstagram();
                 },
               ),
               ListTile(
                 leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                 title: Text(tr('whatsapp')),
                 subtitle: const Text("96555224500"),
                 onTap: () {
                   Navigator.pop(context);
                   _launchWhatsApp();
                 },
               ),
               const Divider(),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Text(tr('general'), style: TextStyle(color: Colors.grey, fontSize: 12)),
               ),
               ListTile(
                 leading: const Icon(Icons.language),
                 title: Text(tr('language')),
                 trailing: Text(_isArabic ? 'عربي' : 'English', style: const TextStyle(fontWeight: FontWeight.bold)),
                 onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 250));
                    setState(() => _isArabic = !_isArabic);
                 },
               ),
               ListTile(
                 leading: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
                 title: Text(tr('theme')),
                 onTap: () async {
                   Navigator.pop(context);
                   await Future.delayed(const Duration(milliseconds: 200));
                   widget.onThemeToggle();
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.info_outline),
                 title: Text(tr('about')),
                 onTap: () async {
                   Navigator.pop(context);
                   await Future.delayed(const Duration(milliseconds: 200));
                   if (context.mounted) _showInfoDialog(context);
                 },
               ),
               const Spacer(), // Pushes Privacy Policy to bottom
               ListTile(
                 title: Center(
                   child: Text(
                     tr('privacy'), 
                     style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12),
                   ),
                 ),
                 onTap: () {
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('coming_soon'))));
                 },
               ),
               const SizedBox(height: 10),
             ],
           ),
         ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Method Selection
              _buildSectionTitle(tr('method')),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMethodCard(BrewMethod.v60, tr('v60'), FontAwesomeIcons.mugHot),
                    const SizedBox(width: 8),
                    _buildMethodCard(BrewMethod.espresso, tr('espresso'), FontAwesomeIcons.mugSaucer),
                    const SizedBox(width: 8),
                    _buildMethodCard(BrewMethod.frenchPress, tr('french_press'), FontAwesomeIcons.jar),
                    const SizedBox(width: 8),
                    _buildMethodCard(BrewMethod.aeropress, tr('aeropress'), FontAwesomeIcons.syringe),
                    const SizedBox(width: 8),
                    _buildMethodCard(BrewMethod.coldBrew, tr('cold_brew'), FontAwesomeIcons.snowflake),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1.1 Style Selection (Hot/Iced) - Only if not Espresso/ColdBrew
              if (_selectedMethod != BrewMethod.espresso && _selectedMethod != BrewMethod.coldBrew) ...[
                _buildSectionTitle(tr('style')),
                Row(
                  children: [
                    Expanded(child: _buildStyleCard(BrewStyle.hot, tr('hot'), Icons.local_fire_department)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStyleCard(BrewStyle.iced, tr('iced'), Icons.ac_unit)),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 1.2 Pour Count (V60 Only)
              if (_selectedMethod == BrewMethod.v60) ...[
                 _buildSectionTitle('${tr('pulse_count')}: $_pourCount'),
                 Slider(
                    value: _pourCount.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_pourCount',
                    onChanged: (val) => setState(() => _pourCount = val.round()),
                 ),
                 const SizedBox(height: 24),
              ],

              // 2. Roast Selection
              _buildSectionTitle(tr('roast_level')),
              Row(
                children: [
                  Expanded(child: _buildRoastCard(RoastLevel.light, tr('light'), const Color(0xFFD4A373))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildRoastCard(RoastLevel.medium, tr('medium'), const Color(0xFFA98467))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildRoastCard(RoastLevel.dark, tr('dark'), const Color(0xFF6F4E37))),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Dose Input
              _buildSectionTitle('${tr('dose')}: ${_coffeeDose.round()}g'),
              Slider(
                value: _coffeeDose,
                min: 10,
                max: 60,
                divisions: 50,
                label: '${_coffeeDose.round()}g',
                onChanged: (val) => setState(() => _coffeeDose = val),
              ),
              const SizedBox(height: 24),

              // 4. Taste Preference (5 Levels)
              _buildSectionTitle(tr('target_profile')),
              Slider(
                value: _tasteValue,
                min: 0,
                max: 4,
                divisions: 4,
                onChanged: (val) => setState(() => _tasteValue = val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTasteLabel(0, tr('very_sour')),
                    _buildTasteLabel(1, tr('sour')),
                    _buildTasteLabel(2, tr('balanced')),
                    _buildTasteLabel(3, tr('bitter')),
                    _buildTasteLabel(4, tr('very_bitter')),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Result Card
              _buildResultCard(recipe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasteLabel(int val, String text) {
    bool isActive = (_tasteValue - val).abs() < 0.1;
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10, // Small text to fit 5 items
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[400],
        ),
      ),
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

  Widget _buildMethodCard(BrewMethod method, String title, IconData icon) {
    final isSelected = _selectedMethod == method;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedContentColor = isDarkMode ? Colors.black87 : Colors.white;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        width: 100, // Fixed width for horizontal scroll
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? selectedContentColor : Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? selectedContentColor : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(BrewStyle style, String title, IconData icon) {
    final isSelected = _selectedStyle == style;
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : AppTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoastCard(RoastLevel roast, String title, Color color) {
    final isSelected = _selectedRoast == roast;
    return GestureDetector(
      onTap: () => setState(() => _selectedRoast = roast),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(CoffeeRecipe recipe) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.black87 : Colors.white;
    // Darken the label color slightly for better visibility as requested
    final labelColor = isDarkMode ? Colors.black87 : Colors.white70; 

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('your_recipe'),
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  recipe.time,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildRecipeRow(FontAwesomeIcons.droplet, tr('total_liquid'), '${recipe.totalLiquid.round()} ml', textColor, labelColor),
          Divider(color: labelColor.withOpacity(0.2), height: 24),
          
          if (recipe.iceAmount > 0) ...[
             _buildRecipeRow(FontAwesomeIcons.cube, tr('ice_amount'), '${recipe.iceAmount.round()} g', textColor, labelColor),
             const SizedBox(height: 12),
             _buildRecipeRow(FontAwesomeIcons.fire, tr('hot_water'), '${recipe.waterAmount.round()} ml', textColor, labelColor),
             Divider(color: labelColor.withOpacity(0.2), height: 24),
          ],
          // Hidden 'Water Amount' when no ice, as Total Liquid == Water Amount

          Row(
            children: [
              Expanded(child: _buildRecipeDetail(tr('temp'), '${recipe.temperature}°C', textColor, labelColor)),
              Expanded(child: _buildRecipeDetail(tr('grind'), '${tr(recipe.grindSize)}\n(~${recipe.microns} µm)', textColor, labelColor)),
            ],
          ),
          
          if (recipe.pressure != null) ...[
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: _buildRecipeDetail(tr('pressure'), '${recipe.pressure} ${tr('bars')}', textColor, labelColor)),
                 Expanded(child: _buildRecipeDetail(tr('flow'), tr(recipe.flow!), textColor, labelColor)),
               ],
             ),
          ],

          const SizedBox(height: 24),

          
          _buildGrindSlider(recipe.microns),
          const SizedBox(height: 16),

          if (recipe.pourSteps.isNotEmpty) ...[
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                        const Icon(Icons.water_drop, color: AppTheme.accent, size: 16),
                        const SizedBox(width: 8),
                        Text(tr('pulse_count') + ": " + recipe.pourSteps.length.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   ...recipe.pourSteps.map((step) {
                      String text;
                      if (step.key == 'bloom') {
                        text = "• ${tr('bloom')}: ${step.volume}ml";
                      } else {
                        // Pour X
                        String indexStr = step.index > 0 ? " ${step.index}" : "";
                        text = "• ${tr('pour')}$indexStr: ${step.volume}ml (${tr('total')}: ${step.total}ml)";
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(text, style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 13)),
                      );
                   }).toList(),
                 ],
               ),
             ),
             const SizedBox(height: 16),
          ],

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: AppTheme.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr(recipe.note),
                    style: TextStyle(color: isDarkMode ? Colors.black54 : Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrindSlider(int microns) {
    // Normalize microns (approx 200 - 1400 range) to slider value (0.0 - 1.0)
    // Fine (~200) -> 0.0
    // Coarse (~1200) -> 1.0
    double sliderValue = (microns - 200) / (1200 - 200);
    // Clamp value
    if (sliderValue < 0.0) sliderValue = 0.0;
    if (sliderValue > 1.0) sliderValue = 1.0;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            onChanged: null, // Disabled (Read-only)
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeRow(IconData icon, String label, String value, Color textColor, Color labelColor) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: labelColor, fontSize: 16)),
        const Spacer(),
        Text(value, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('about')),
        content: Text(tr('about_content')),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}
