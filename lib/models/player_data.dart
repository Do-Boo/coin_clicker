import 'dart:convert';

class PlayerData {
  double coins;
  double coinsPerSecond;
  double clickPower;
  Map<String, int> upgrades;
  Map<String, int> investments;
  DateTime? adsBoostUntil;
  int totalClicks;
  DateTime lastLoginDate;
  int consecutiveLoginDays;
  int level;
  double sessionEarnings;
  Map<String, int> boosters;
  int health;

  PlayerData({
    this.coins = 0,
    this.coinsPerSecond = 0,
    this.clickPower = 1,
    Map<String, int>? upgrades,
    Map<String, int>? investments,
    this.adsBoostUntil,
    this.totalClicks = 0,
    DateTime? lastLoginDate,
    this.consecutiveLoginDays = 0,
    this.level = 1,
    this.sessionEarnings = 0,
    Map<String, int>? boosters,
    this.health = 10,
  }) : 
    upgrades = upgrades ?? {
      'click': 0,
      'auto': 0,
      'critical': 0,
    },
    investments = investments ?? {
      'realEstate': 0,
      'gold': 0,
      'fund': 0,
    },
    lastLoginDate = lastLoginDate ?? DateTime.now(),
    boosters = boosters ?? {};

  bool get isAdsBoostActive => 
    adsBoostUntil != null && adsBoostUntil!.isAfter(DateTime.now());

  double get effectiveClickPower => 
    isAdsBoostActive ? clickPower * 2 : clickPower;

  bool get hasActiveBooster => hasClickBooster || hasAutoBooster;
  bool get hasClickBooster => boosters['click'] != null && boosters['click']! > 0;
  bool get hasAutoBooster => boosters['auto'] != null && boosters['auto']! > 0;
  
  double get boosterTimeRemaining => 
    adsBoostUntil?.difference(DateTime.now()).inSeconds.toDouble() ?? 0;
    
  double get boosterTotalTime => 300; // 5 minutes in seconds

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'coinsPerSecond': coinsPerSecond,
    'clickPower': clickPower,
    'upgrades': upgrades,
    'investments': investments,
    'adsBoostUntil': adsBoostUntil?.toIso8601String(),
    'totalClicks': totalClicks,
    'lastLoginDate': lastLoginDate.toIso8601String(),
    'consecutiveLoginDays': consecutiveLoginDays,
    'level': level,
    'sessionEarnings': sessionEarnings,
    'boosters': boosters,
    'health': health,
  };

  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
    coins: json['coins']?.toDouble() ?? 0,
    coinsPerSecond: json['coinsPerSecond']?.toDouble() ?? 0,
    clickPower: json['clickPower']?.toDouble() ?? 1,
    upgrades: Map<String, int>.from(json['upgrades'] ?? {}),
    investments: Map<String, int>.from(json['investments'] ?? {}),
    adsBoostUntil: json['adsBoostUntil'] != null 
      ? DateTime.parse(json['adsBoostUntil'])
      : null,
    totalClicks: json['totalClicks'] ?? 0,
    lastLoginDate: DateTime.parse(json['lastLoginDate'] ?? DateTime.now().toIso8601String()),
    consecutiveLoginDays: json['consecutiveLoginDays'] ?? 0,
    level: json['level'] ?? 1,
    sessionEarnings: json['sessionEarnings']?.toDouble() ?? 0,
    boosters: Map<String, int>.from(json['boosters'] ?? {}),
    health: json['health'] ?? 10,
  );

  void updateLoginStreak() {
    final now = DateTime.now();
    final difference = now.difference(lastLoginDate).inDays;
    
    if (difference == 1) {
      consecutiveLoginDays++;
    } else if (difference > 1) {
      consecutiveLoginDays = 1;
    }
    lastLoginDate = now;
  }
} 