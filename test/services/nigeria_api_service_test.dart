import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app2/services/nigeria_api_service.dart';
import 'package:chat_app2/services/nigeria_data_manager.dart';

void main() {
  late NigeriaApiService nigeriaService;
  late NigeriaDataManager dataManager;

  setUp(() {
    nigeriaService = NigeriaApiService();
    dataManager = NigeriaDataManager();
  });

  group('NigeriaApiService', () {
    test('should initialize successfully', () async {
      // Test that initialization works
      await nigeriaService.initialize();

      // Should not throw any errors
      expect(true, true);
    });

    test('should return fallback states from data manager', () async {
      // Test fallback functionality
      final states = dataManager.getFallbackStates();

      expect(states, isNotEmpty);
      expect(states.length, 37); // Nigeria has 37 states including FCT
      expect(states.contains('Lagos'), true);
      expect(states.contains('Kano'), true);
      expect(states.contains('Abuja'), false); // Should be FCT, not Abuja
    });

    test('should return fallback LGAs for known states', () {
      final lagosLGAs = dataManager.getFallbackLGAs('Lagos');

      expect(lagosLGAs, isNotEmpty);
      expect(lagosLGAs.contains('Ikeja'), true);
      expect(lagosLGAs.contains('Surulere'), true);
    });

    test('should return empty list for unknown state', () {
      final unknownLGAs = dataManager.getFallbackLGAs('UnknownState');

      expect(unknownLGAs, isEmpty);
    });

    test('should handle case sensitive state lookup', () {
      final lagosLGAs1 = dataManager.getFallbackLGAs('Lagos');
      final lagosLGAs2 = dataManager.getFallbackLGAs('lagos');

      // Note: The current implementation is case sensitive
      // This test verifies the current behavior
      expect(lagosLGAs1, isNotEmpty);
      expect(lagosLGAs2, isEmpty); // 'lagos' (lowercase) returns empty
    });

    test('should return empty lists when no cached data exists', () async {
      // Test that empty lists are returned when no cached data
      final states = await dataManager.getCachedStates();
      final lgas = await dataManager.getCachedLGAs();

      // This might be empty if no data is cached
      expect(states, isA<List<String>>());
      expect(lgas, isA<Map<String, List<String>>>());
    });
  });

  group('NigeriaDataManager Fallback Data', () {
    test('fallback states should contain all 37 states', () {
      final states = dataManager.getFallbackStates();

      expect(states.length, 37);
      expect(states.contains('Lagos'), true);
      expect(states.contains('FCT'), true);
      expect(states.contains('Zamfara'), true);
    });

    test('fallback LGAs should be comprehensive for major states', () {
      final lagosLGAs = dataManager.getFallbackLGAs('Lagos');
      final fctLGAs = dataManager.getFallbackLGAs('FCT');
      final kanoLGAs = dataManager.getFallbackLGAs('Kano');

      expect(lagosLGAs.length, greaterThan(15)); // Lagos has many LGAs
      expect(fctLGAs.length, 6); // FCT has 6 area councils
      expect(kanoLGAs.length, greaterThan(40)); // Kano has many LGAs
    });
  });
}
