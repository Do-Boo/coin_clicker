class GameConstants {
  // Base values
  static const double initialClickPower = 1.0;
  static const double initialCoinsPerSecond = 0.0;
  static const double criticalMultiplier = 2.0;

  // Upgrade costs and effects
  static const double clickUpgradeBaseCost = 100.0;
  static const double clickUpgradeEffect = 1.0;
  static const double autoUpgradeBaseCost = 150.0;
  static const double autoUpgradeEffect = 0.5;
  static const double criticalUpgradeBaseCost = 200.0;
  static const double criticalUpgradeEffect = 0.05; // 5% increase per level

  // Investment costs and effects
  static const double realEstateBaseCost = 1000.0;
  static const double realEstateEffect = 1.0; // CPS
  static const double goldBaseCost = 5000.0;
  static const double goldEffect = 0.2; // 20% click power
  static const double fundBaseCost = 10000.0;
  static const double fundEffect = 100.0; // Bonus every 30s

  // Time constants
  static const int adBoostDurationMinutes = 5;
  static const int autosaveIntervalSeconds = 60;
  static const int fundBonusIntervalSeconds = 30;

  // Storage keys
  static const String storageKeyPlayerData = 'player_data';
  static const String storageKeySettings = 'settings';
  static const String storageKeyAchievements = 'achievements';

  // Achievement thresholds
  static const List<int> clickCountAchievements = [100, 1000, 10000, 100000];
  static const List<double> coinCountAchievements = [1000, 10000, 100000, 1000000];
  
  // Daily rewards
  static const List<DailyReward> dailyRewards = [
    DailyReward(coins: 500, description: '500 코인'),
    DailyReward(coins: 1000, boostMinutes: 5, description: '1000 코인 + 5분 부스터'),
    DailyReward(coins: 2000, description: '2000 코인'),
    DailyReward(coins: 3000, upgradeDiscount: 0.5, description: '3000 코인 + 업그레이드 50% 할인'),
    DailyReward(coins: 5000, description: '5000 코인'),
    DailyReward(coins: 7000, boostMinutes: 10, description: '7000 코인 + 10분 부스터'),
    DailyReward(coins: 10000, specialItem: 'premium_investment', description: '10000 코인 + 프리미엄 투자'),
  ];
}

class DailyReward {
  final double coins;
  final int? boostMinutes;
  final double? upgradeDiscount;
  final String? specialItem;
  final String description;

  const DailyReward({
    required this.coins,
    this.boostMinutes,
    this.upgradeDiscount,
    this.specialItem,
    required this.description,
  });
} 