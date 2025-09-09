import 'nigeria_data_manager.dart';

class NigeriaApiService {
  final NigeriaDataManager _dataManager;
  bool _isInitialized = false;

  NigeriaApiService() : _dataManager = NigeriaDataManager();

  /// Initialize the service - load cached data or fetch from API
  Future<void> initialize() async {
    if (!_isInitialized) {
      print('🚀 Initializing Nigeria API Service...');
      await _dataManager.initializeData();
      _isInitialized = true;
      print('✅ Nigeria API Service initialized');
    }
  }

  /// Force refresh data from API
  Future<void> refreshData() async {
    await _dataManager.refreshData();
  }

  /// Fetches all Nigerian states from cache
  Future<List<String>> getStates() async {
    await initialize(); // Ensure data is loaded
    return await _dataManager.getCachedStates();
  }

  /// Fetches LGAs for a specific state from cache
  Future<List<String>> getLGAs(String stateName) async {
    await initialize(); // Ensure data is loaded
    return await _dataManager.getCachedLGAsForState(stateName);
  }

  /// Test if cached data exists
  Future<bool> hasCachedData() async {
    await initialize();
    return await _dataManager.hasCachedData();
  }

  /// Check if cached data is stale
  Future<bool> isDataStale() async {
    await initialize();
    return await _dataManager.isDataStale();
  }

  /// Get fallback states (for backward compatibility)
  List<String> getFallbackStates() {
    return _dataManager.getFallbackStates();
  }

  /// Get fallback LGAs for a specific state (for backward compatibility)
  List<String> getFallbackLGAs(String stateName) {
    return _dataManager.getFallbackLGAs(stateName);
  }
}
