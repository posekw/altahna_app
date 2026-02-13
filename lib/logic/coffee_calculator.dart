class PourStep {
  final String key; // 'bloom' or 'pour'
  final int volume;
  final int total;
  final int index; // For 'Pour 1', 'Pour 2'

  PourStep({required this.key, required this.volume, required this.total, this.index = 0});
}

class CoffeeRecipe {
  final double coffeeAmount;
  final double waterAmount;
  final double iceAmount;
  final int temperature;
  final String grindSize; // Description (e.g. Medium - Sand)
  final int microns; // Scientific unit (e.g. 800)
  final String time;
  final String note;
  final List<PourStep> pourSteps;
  final double? pressure;
  final String? flow;

  CoffeeRecipe({
    required this.coffeeAmount,
    required this.waterAmount,
    required this.iceAmount,
    required this.temperature,
    required this.grindSize,
    required this.microns,
    required this.time,
    required this.note,
    this.pourSteps = const [],
    this.pressure,
    this.flow,
  });
  
  double get totalLiquid => waterAmount + iceAmount;
}

enum Order { hot, iced }
enum RoastLevel { light, medium, dark }
enum BrewMethod { v60, aeropress, frenchPress, espresso, coldBrew }
enum BrewStyle { hot, iced }
enum TasteProfile { verySour, sour, balanced, bitter, veryBitter }

class CoffeeCalculator {
  static CoffeeRecipe calculate({
    required double coffeeGrams,
    required RoastLevel roast,
    required BrewMethod method,
    required BrewStyle style,
    required    TasteProfile taste,
    int pourCount = 2,
    double? customPressure,
    double? customFlow,
    double? expertRatio,
    double? expertTemp,
    int? expertMicrons,
  }) {
    // 1. Ratio & Microns Defaults
    double ratio = 15.0;
    int microns = 800;
    String grindKey = "grind_medium_sand";
    int temp = 93;
    int totalSeconds = 180;

    // --- Device Specific Logic ---
    switch (method) {
      case BrewMethod.v60:
        ratio = style == BrewStyle.iced ? 15.0 : 15.0; // 1:15 standard
        microns = 800; // Medium
        grindKey = "grind_medium_sand";
        totalSeconds = style == BrewStyle.iced ? 150 : 180;
        break;

      case BrewMethod.aeropress:
        ratio = 11.0; // Concentrated
        microns = 600; // Medium-Fine
        grindKey = "grind_medium_fine_salt";
        totalSeconds = 120;
        break;

      case BrewMethod.frenchPress:
        ratio = 12.0; // Rich
        microns = 1200; // Coarse
        grindKey = "grind_coarse_sea_salt";
        totalSeconds = 240; // 4 mins
        break;

      case BrewMethod.espresso:
        ratio = 2.0; // 1:2 Standard
        microns = 250; // Fine
        grindKey = "grind_fine_table_salt";
        totalSeconds = 30; // 30 sec
        break;

      case BrewMethod.coldBrew:
        ratio = 10.0; // Concentrate
        microns = 1400; // Very Coarse
        grindKey = "grind_very_coarse_rock";
        totalSeconds = 16 * 60 * 60; // 16 Hours
        temp = 20; // Room temp
        break;
    }

    // --- Adjustments based on Style (Iced) ---
    if (style == BrewStyle.iced && method != BrewMethod.coldBrew && method != BrewMethod.espresso) {
      microns -= 100; // Finer for iced to extract more
      if (microns < 200) microns = 200;
      totalSeconds -= 30; // Faster drawdown usually or shorter steep
    }

    // --- Adjustments based on Roast ---
    if (roast == RoastLevel.dark) {
      temp = 85;
      microns += 100; // Coarser to reduce bitterness
    } else if (roast == RoastLevel.light) {
      temp = 96;
      microns -= 50; // Finer to extract more
    } else {
      temp = 92;
    }

    // --- Adjustments based on Taste (Goal-Based) ---
    switch (taste) {
      case TasteProfile.verySour:
        // Goal: More Acidity/Sourness -> Coarser + Cooler
        microns += 100;
        temp -= 2;
        ratio -= (method == BrewMethod.espresso) ? 0.2 : 0.5; // Slightly shorter ratio for acidity
        break;
      case TasteProfile.sour:
        microns += 50;
        temp -= 1;
        break;
      case TasteProfile.balanced: break;
      case TasteProfile.bitter:
        microns -= 50;
        temp += 1;
        break;
      case TasteProfile.veryBitter:
        // Goal: More Bitterness/Intensity -> Finer + Hotter
        microns -= 100;
        temp += 2;
        ratio += (method == BrewMethod.espresso) ? 0.5 : 1.0; // Longer ratio for intensity
        break;
    }

    // --- Calculation ---
    double totalLiquid = coffeeGrams * ratio;
    double hotWater = totalLiquid;
    double ice = 0;

    if (style == BrewStyle.iced && method != BrewMethod.coldBrew && method != BrewMethod.espresso) {
      ice = totalLiquid * 0.4; // 40% Ice
      hotWater = totalLiquid * 0.6; // 60% Hot Water
    }

    // Cold Brew Force Temp
    if (method == BrewMethod.coldBrew) {
      temp = 0; // RT or Cold
      hotWater = totalLiquid; // All water
      ice = 0;
    }

    // Time Formatting
    String timeStr;
    if (totalSeconds > 3600) {
      timeStr = "${totalSeconds ~/ 3600}h"; // Hours for Cold Brew
    } else {
      int m = totalSeconds ~/ 60;
      int s = totalSeconds % 60;
      timeStr = "$m:${s.toString().padLeft(2, '0')}";
    }

    // --- Pour Schedule Calculation (V60 Only) ---
    List<PourStep> pours = [];
    if (method == BrewMethod.v60) {
      double bloom = coffeeGrams * 2.0; 
      if (bloom > totalLiquid) bloom = totalLiquid;
      
      pours.add(PourStep(key: 'bloom', volume: bloom.round(), total: bloom.round()));
      
      double remaining = totalLiquid - bloom;
      
      if (pourCount > 1) {
         int mainPours = pourCount - 1;
         double perPour = remaining / mainPours;
         double currentTotal = bloom;
         
         for (int i = 0; i < mainPours; i++) {
            currentTotal += perPour;
            pours.add(PourStep(
              key: 'pour', 
              volume: perPour.round(), 
              total: currentTotal.round(), 
              index: i + 1
            ));
         }
      } else {
         if (pourCount == 1) {
            pours.clear();
            pours.add(PourStep(key: 'pour', volume: totalLiquid.round(), total: totalLiquid.round(), index: 0));
         }
      }
    }

    // --- Pressure & Flow (Espresso Resulting Targets) ---
    double? pressure;
    String? flow;

    if (method == BrewMethod.espresso) {
      if (taste == TasteProfile.veryBitter || taste == TasteProfile.bitter) {
        pressure = 9.0;
        flow = "Standard (1.2 - 1.8 ml/s)";
      } else if (taste == TasteProfile.verySour || taste == TasteProfile.sour) {
        pressure = 6.0; // Modern Turbo/Allonge style
        flow = "Fast (2.5 - 3.5 ml/s)";
      } else {
        pressure = 8.5;
        flow = "Balanced (1.5 - 2.0 ml/s)";
      }
    }

    // --- Expert Overrides ---
    if (expertRatio != null) ratio = expertRatio;
    if (expertTemp != null) temp = expertTemp.round();
    if (expertMicrons != null) {
       microns = expertMicrons;
       // Find best grindKey for display
       if (microns < 350) grindKey = "grind_fine_table_salt";
       else if (microns < 550) grindKey = "grind_medium_fine";
       else if (microns < 750) grindKey = "grind_medium_sand";
       else if (microns < 950) grindKey = "grind_medium_coarse";
       else grindKey = "grind_coarse_sea_salt";
    }

    // Recalculate based on overrides if necessary
    if (expertRatio != null || expertMicrons != null) {
       totalLiquid = coffeeGrams * ratio;
       if (style == BrewStyle.iced) {
          ice = totalLiquid * 0.4;
          hotWater = totalLiquid - ice;
       } else {
          ice = 0;
          hotWater = totalLiquid;
       }
    }

    return CoffeeRecipe(
      coffeeAmount: coffeeGrams,
      waterAmount: double.parse(hotWater.toStringAsFixed(0)),
      iceAmount: double.parse(ice.toStringAsFixed(0)),
      temperature: temp,
      grindSize: grindKey,
      microns: microns,
      time: timeStr,
      note: _getAdvice(taste, method),
      pourSteps: pours,
      pressure: pressure,
      flow: flow,
    );
  }

  static String _getAdvice(TasteProfile taste, BrewMethod method) {
    if (method == BrewMethod.espresso) {
       return taste == TasteProfile.balanced ? "advice_good_shot" : "advice_adjust_grind";
    }
    
    switch (taste) {
      case TasteProfile.verySour:
        return "advice_very_sour";
      case TasteProfile.sour:
        return "advice_sour";
      case TasteProfile.balanced:
        return "advice_balanced";
      case TasteProfile.bitter:
        return "advice_bitter";
      case TasteProfile.veryBitter:
        return "advice_very_bitter";
    }
  }
}
