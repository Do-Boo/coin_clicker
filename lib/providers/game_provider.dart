import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coin_clicker/models/player_data.dart';
import 'package:coin_clicker/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';

class GameProvider with ChangeNotifier {
  PlayerData _playerData = PlayerData();
  Timer? _autoIncomeTimer;
  Timer? _autosaveTimer;
  Timer? _fundBonusTimer;
  bool _isInitialized = false;
  final List<AudioPlayer> _soundPool = List.generate(4, (_) => AudioPlayer());
  int _currentSoundIndex = 0;
  bool _isSoundEnabled = true;
  bool _isCriticalHit = false;

  // Getters
  PlayerData get playerData => _playerData;
  bool get isInitialized => _isInitialized;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isCriticalHit => _isCriticalHit;
  
  GameProvider() {
    _initialize();
    _initAudio();
  }

  Future<void> _initialize() async {
    await _loadGameState();
    _startTimers();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initAudio() async {
    for (var player in _soundPool) {
      await player.setSource(AssetSource('sounds/coin_click.mp3'));
      await player.setVolume(0.5);
    }
  }

  void _startTimers() {
    // Auto income timer
    _autoIncomeTimer?.cancel();
    _autoIncomeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _processAutoIncome(),
    );

    // Autosave timer
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(
      Duration(seconds: GameConstants.autosaveIntervalSeconds),
      (_) => _saveGameState(),
    );

    // Fund bonus timer
    _fundBonusTimer?.cancel();
    _fundBonusTimer = Timer.periodic(
      Duration(seconds: GameConstants.fundBonusIntervalSeconds),
      (_) => _processFundBonus(),
    );
  }

  void _processAutoIncome() {
    if (_playerData.coinsPerSecond > 0) {
      _playerData.coins += _playerData.coinsPerSecond;
      notifyListeners();
    }
  }

  void _processFundBonus() {
    final fundLevel = _playerData.investments['fund'] ?? 0;
    if (fundLevel > 0) {
      final bonus = GameConstants.fundEffect * fundLevel;
      _playerData.coins += bonus;
      notifyListeners();
    }
  }

  // Game actions
  void clickCoin() {
    final random = Random();
    _isCriticalHit = random.nextDouble() < 0.1; // 10% 확률로 크리티컬 발생

    double earnedAmount = playerData.clickPower;
    if (_isCriticalHit) {
      earnedAmount *= 2; // 크리티컬 시 2배 데미지
    }

    if (playerData.hasClickBooster) {
      earnedAmount *= 2; // 클릭 부스터 활성화 시 2배
    }

    playerData.coins += earnedAmount;
    notifyListeners();
  }

  Future<void> playClickSound() async {
    if (_isSoundEnabled) {
      try {
        final player = _soundPool[_currentSoundIndex];
        await player.seek(Duration.zero);
        await player.resume();
        _currentSoundIndex = (_currentSoundIndex + 1) % _soundPool.length;
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  // Upgrade methods
  bool canAffordUpgrade(String type) {
    final level = _playerData.upgrades[type] ?? 0;
    final cost = _getUpgradeCost(type, level);
    return _playerData.coins >= cost;
  }

  double _getUpgradeCost(String type, int level) {
    switch (type) {
      case 'click':
        return GameConstants.clickUpgradeBaseCost * pow(1.15, level);
      case 'auto':
        return GameConstants.autoUpgradeBaseCost * pow(1.15, level);
      case 'critical':
        return GameConstants.criticalUpgradeBaseCost * pow(1.15, level);
      default:
        return double.infinity;
    }
  }

  bool purchaseUpgrade(String type) {
    final level = _playerData.upgrades[type] ?? 0;
    final cost = _getUpgradeCost(type, level);
    
    if (_playerData.coins < cost) return false;
    
    _playerData.coins -= cost;
    _playerData.upgrades[type] = level + 1;

    switch (type) {
      case 'click':
        _playerData.clickPower += GameConstants.clickUpgradeEffect;
        break;
      case 'auto':
        _playerData.coinsPerSecond += GameConstants.autoUpgradeEffect;
        break;
    }

    notifyListeners();
    return true;
  }

  // Investment methods
  bool canAffordInvestment(String type) {
    final level = _playerData.investments[type] ?? 0;
    final cost = _getInvestmentCost(type, level);
    return _playerData.coins >= cost;
  }

  double _getInvestmentCost(String type, int level) {
    switch (type) {
      case 'realEstate':
        return GameConstants.realEstateBaseCost * pow(1.5, level);
      case 'gold':
        return GameConstants.goldBaseCost * pow(1.5, level);
      case 'fund':
        return GameConstants.fundBaseCost * pow(1.5, level);
      default:
        return double.infinity;
    }
  }

  bool purchaseInvestment(String type) {
    final level = _playerData.investments[type] ?? 0;
    final cost = _getInvestmentCost(type, level);
    
    if (_playerData.coins < cost) return false;
    
    _playerData.coins -= cost;
    _playerData.investments[type] = level + 1;

    switch (type) {
      case 'realEstate':
        _playerData.coinsPerSecond += GameConstants.realEstateEffect;
        break;
    }

    notifyListeners();
    return true;
  }

  // Boost methods
  void activateAdsBoost() {
    _playerData.adsBoostUntil = DateTime.now().add(
      Duration(minutes: GameConstants.adBoostDurationMinutes),
    );
    notifyListeners();
  }

  // Save/Load methods
  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_playerData.toJson());
    await prefs.setString(GameConstants.storageKeyPlayerData, jsonData);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(GameConstants.storageKeyPlayerData);
    
    if (jsonData != null) {
      try {
        final data = jsonDecode(jsonData);
        _playerData = PlayerData.fromJson(data);
        _playerData.updateLoginStreak();
      } catch (e) {
        debugPrint('Error loading game state: $e');
        _playerData = PlayerData();
      }
    }
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_data', jsonEncode(_playerData.toJson()));
    notifyListeners();
  }

  @override
  void dispose() {
    _autoIncomeTimer?.cancel();
    _autosaveTimer?.cancel();
    _fundBonusTimer?.cancel();
    for (var player in _soundPool) {
      player.dispose();
    }
    super.dispose();
  }
} 