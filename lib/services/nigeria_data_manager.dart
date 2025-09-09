import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/nigeria_api_models.dart';

class NigeriaDataManager {
  static const String _statesFileName = 'nigeria_states.json';
  static const String _lgasFileName = 'nigeria_lgas.json';
  static const String _baseUrl = 'https://nga-states-lga.onrender.com';
  static const Duration _timeout = Duration(seconds: 60); // Longer timeout for bulk data

  final Dio _dio;

  NigeriaDataManager() : _dio = Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 Data Manager API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Data Manager API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print('❌ Data Manager API Error: ${error.type} - ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get the local directory for storing JSON files
  Future<Directory> _getLocalDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get the file path for states JSON
  Future<String> _getStatesFilePath() async {
    final directory = await _getLocalDirectory();
    return '${directory.path}/$_statesFileName';
  }

  /// Get the file path for LGAs JSON
  Future<String> _getLGAsFilePath() async {
    final directory = await _getLocalDirectory();
    return '${directory.path}/$_lgasFileName';
  }

  /// Fetch all states from API and save to JSON
  Future<List<String>> fetchAndCacheStates() async {
    try {
      print('🔄 Fetching all states from API...');

      // Try different possible endpoints
      final endpoints = ['/api/states', '/states', '/api/v1/states'];

      for (final endpoint in endpoints) {
        try {
          final response = await _dio.get(endpoint);

          if (response.statusCode == 200) {
            final data = response.data;
            print('States API response from $endpoint: ${data.toString().substring(0, min(200, data.toString().length))}...');

            List<String> states = [];

            if (data is List) {
              states = data.map((state) {
                if (state is String) return state;
                if (state is Map<String, dynamic>) {
                  return StateModel.fromJson(state).name;
                }
                return state.toString();
              }).toList();
            } else if (data is Map<String, dynamic>) {
              final statesData = data['states'] ?? data['data'] ?? data['result'];
              if (statesData is List) {
                states = statesData.map((state) {
                  if (state is String) return state;
                  if (state is Map<String, dynamic>) {
                    return StateModel.fromJson(state).name;
                  }
                  return state.toString();
                }).toList();
              }
            }

            if (states.isNotEmpty) {
              await _saveStatesToJson(states);
              print('✅ Successfully cached ${states.length} states');
              return states;
            }
          }
        } catch (e) {
          print('Endpoint $endpoint failed: $e');
          continue;
        }
      }

      throw DioException(
        requestOptions: RequestOptions(path: '/api/states'),
        type: DioExceptionType.connectionError,
      );

    } catch (e) {
      print('Error fetching states: $e');
      // Return cached states if available
      final cachedStates = await getCachedStates();
      if (cachedStates.isNotEmpty) {
        print('📁 Using cached states (${cachedStates.length} states)');
        return cachedStates;
      }
      // Return fallback if no cache
      return getFallbackStates();
    }
  }

  /// Fetch all LGAs for all states and save to JSON
  Future<Map<String, List<String>>> fetchAndCacheAllLGAs() async {
    try {
      print('🔄 Fetching all LGAs from API...');

      // First get all states
      final states = await fetchAndCacheStates();
      final Map<String, List<String>> allLGAs = {};

      // Try to find an endpoint that returns all LGAs at once
      final bulkEndpoints = ['/api/lgas', '/lgas', '/api/v1/lgas'];

      for (final endpoint in bulkEndpoints) {
        try {
          final response = await _dio.get(endpoint);

          if (response.statusCode == 200) {
            final data = response.data;
            print('Bulk LGAs API response from $endpoint');

            if (data is Map<String, dynamic>) {
              // If API returns LGAs grouped by state
              data.forEach((state, lgas) {
                if (lgas is List) {
                  allLGAs[state] = lgas.map((lga) {
                    if (lga is String) return lga;
                    if (lga is Map<String, dynamic>) {
                      return LGAModel.fromJson(lga).name;
                    }
                    return lga.toString();
                  }).toList();
                }
              });

              if (allLGAs.isNotEmpty) {
                await _saveLGAsToJson(allLGAs);
                print('✅ Successfully cached LGAs for ${allLGAs.length} states');
                return allLGAs;
              }
            }
          }
        } catch (e) {
          print('Bulk endpoint $endpoint failed: $e');
          continue;
        }
      }

      // If bulk endpoint doesn't work, fetch LGAs for each state individually
      print('🔄 Bulk endpoint not available, fetching LGAs per state...');

      for (final state in states) {
        try {
          final stateLGAs = await _fetchLGAsForState(state);
          if (stateLGAs.isNotEmpty) {
            allLGAs[state] = stateLGAs;
          }
        } catch (e) {
          print('Failed to fetch LGAs for $state: $e');
          // Use fallback for this state
          final fallbackLGAs = getFallbackLGAs(state);
          if (fallbackLGAs.isNotEmpty) {
            allLGAs[state] = fallbackLGAs;
          }
        }

        // Add small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (allLGAs.isNotEmpty) {
        await _saveLGAsToJson(allLGAs);
        print('✅ Successfully cached LGAs for ${allLGAs.length} states');
        return allLGAs;
      }

      throw Exception('Failed to fetch any LGAs');

    } catch (e) {
      print('Error fetching LGAs: $e');
      // Return cached LGAs if available
      final cachedLGAs = await getCachedLGAs();
      if (cachedLGAs.isNotEmpty) {
        print('📁 Using cached LGAs (${cachedLGAs.length} states)');
        return cachedLGAs;
      }
      // Return fallback if no cache
      return getFallbackAllLGAs();
    }
  }

  /// Fetch LGAs for a specific state
  Future<List<String>> _fetchLGAsForState(String stateName) async {
    final endpoints = [
      '/api/states/$stateName/lgas',
      '/api/states/$stateName/lga',
      '/lgas/$stateName',
      '/api/lgas/$stateName',
      '/states/$stateName/lgas',
      '/states/$stateName/lga'
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(endpoint);

        if (response.statusCode == 200) {
          final data = response.data;

          if (data is List) {
            return data.map((lga) {
              if (lga is String) return lga;
              if (lga is Map<String, dynamic>) {
                return LGAModel.fromJson(lga).name;
              }
              return lga.toString();
            }).toList();
          } else if (data is Map<String, dynamic>) {
            final lgas = data['lgas'] ?? data['lga'] ?? data['data'] ?? data['local_governments'] ?? data['result'];
            if (lgas is List) {
              return lgas.map((lga) {
                if (lga is String) return lga;
                if (lga is Map<String, dynamic>) {
                  return LGAModel.fromJson(lga).name;
                }
                return lga.toString();
              }).toList();
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    return [];
  }

  /// Save states to JSON file
  Future<void> _saveStatesToJson(List<String> states) async {
    try {
      final filePath = await _getStatesFilePath();
      final Map<String, dynamic> jsonData = {
        'last_updated': DateTime.now().toIso8601String(),
        'states': states,
      };

      final jsonString = jsonEncode(jsonData);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('💾 States saved to: $filePath');
    } catch (e) {
      print('Error saving states to JSON: $e');
    }
  }

  /// Save LGAs to JSON file
  Future<void> _saveLGAsToJson(Map<String, List<String>> lgas) async {
    try {
      final filePath = await _getLGAsFilePath();
      final Map<String, dynamic> jsonData = {
        'last_updated': DateTime.now().toIso8601String(),
        'lgas': lgas,
      };

      final jsonString = jsonEncode(jsonData);
      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('💾 LGAs saved to: $filePath');
    } catch (e) {
      print('Error saving LGAs to JSON: $e');
    }
  }

  /// Get cached states from JSON file
  Future<List<String>> getCachedStates() async {
    try {
      final filePath = await _getStatesFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);

        if (jsonData is Map<String, dynamic> && jsonData['states'] is List) {
          final states = List<String>.from(jsonData['states']);
          print('📖 Loaded ${states.length} cached states');
          return states;
        }
      }
    } catch (e) {
      print('Error reading cached states: $e');
    }

    return [];
  }

  /// Get cached LGAs from JSON file
  Future<Map<String, List<String>>> getCachedLGAs() async {
    try {
      final filePath = await _getLGAsFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);

        if (jsonData is Map<String, dynamic> && jsonData['lgas'] is Map) {
          final lgas = Map<String, List<String>>.from(
            jsonData['lgas'].map((key, value) => MapEntry(key, List<String>.from(value)))
          );
          print('📖 Loaded cached LGAs for ${lgas.length} states');
          return lgas;
        }
      }
    } catch (e) {
      print('Error reading cached LGAs: $e');
    }

    return {};
  }

  /// Get LGAs for a specific state from cache
  Future<List<String>> getCachedLGAsForState(String stateName) async {
    final cachedLGAs = await getCachedLGAs();
    return cachedLGAs[stateName] ?? [];
  }

  /// Check if data is stale (older than 30 days)
  Future<bool> isDataStale() async {
    try {
      final statesPath = await _getStatesFilePath();
      final statesFile = File(statesPath);

      if (await statesFile.exists()) {
        final jsonString = await statesFile.readAsString();
        final jsonData = jsonDecode(jsonString);

        if (jsonData is Map<String, dynamic> && jsonData['last_updated'] != null) {
          final lastUpdated = DateTime.parse(jsonData['last_updated']);
          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

          return lastUpdated.isBefore(thirtyDaysAgo);
        }
      }
    } catch (e) {
      print('Error checking data staleness: $e');
    }

    return true; // Consider data stale if we can't check
  }

  /// Refresh all data from API
  Future<void> refreshData() async {
    print('🔄 Refreshing all Nigeria data from API...');
    await fetchAndCacheStates();
    await fetchAndCacheAllLGAs();
    print('✅ Data refresh complete');
  }

  /// Initialize data - load from cache or fetch from API
  Future<void> initializeData() async {
    final hasData = await hasCachedData();

    if (!hasData || await isDataStale()) {
      print('📡 No cached data or data is stale, fetching from API...');
      await refreshData();
    } else {
      print('📁 Using cached Nigeria data');
    }
  }

  /// Check if we have cached data
  Future<bool> hasCachedData() async {
    final statesPath = await _getStatesFilePath();
    final lgasPath = await _getLGAsFilePath();

    final statesFile = File(statesPath);
    final lgasFile = File(lgasPath);

    return await statesFile.exists() && await lgasFile.exists();
  }

  /// Get fallback states
  List<String> getFallbackStates() {
    return [
      'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
      'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo',
      'Ekiti', 'Enugu', 'FCT', 'Gombe', 'Imo', 'Jigawa', 'Kaduna',
      'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa',
      'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers',
      'Sokoto', 'Taraba', 'Yobe', 'Zamfara'
    ];
  }

  /// Get fallback LGAs for all states
  Map<String, List<String>> getFallbackAllLGAs() {
    return {
      'Lagos': [
        'Agege', 'Ajeromi-Ifelodun', 'Alimosho', 'Amuwo-Odofin', 'Apapa',
        'Badagry', 'Epe', 'Eti Osa', 'Ibeju-Lekki', 'Ifako-Ijaiye',
        'Ikeja', 'Ikorodu', 'Kosofe', 'Lagos Island', 'Lagos Mainland',
        'Mushin', 'Ojo', 'Oshodi-Isolo', 'Shomolu', 'Surulere'
      ],
      'FCT': [
        'Abaji', 'Bwari', 'Gwagwalada', 'Kuje', 'Kwali', 'Municipal Area Council'
      ],
      'Kano': [
        'Ajingi', 'Albasu', 'Bagwai', 'Bebeji', 'Bichi', 'Bunkure',
        'Dala', 'Dambatta', 'Dawakin Kudu', 'Dawakin Tofa', 'Doguwa',
        'Fagge', 'Gabasawa', 'Garko', 'Garun Mallam', 'Gaya',
        'Gezawa', 'Gwale', 'Gwarzo', 'Kabo', 'Kano Municipal'
      ],
      'Rivers': [
        'Abua/Odual', 'Ahoada East', 'Ahoada West', 'Akuku-Toru', 'Andoni',
        'Asari-Toru', 'Bonny', 'Degema', 'Eleme', 'Emuoha', 'Etche',
        'Gokana', 'Ikwerre', 'Khana', 'Obio/Akpor', 'Ogba/Egbema/Ndoni',
        'Ogu/Bolo', 'Okrika', 'Omuma', 'Opobo/Nkoro', 'Oyigbo',
        'Port Harcourt', 'Tai'
      ],
      'Ogun': [
        'Abeokuta North', 'Abeokuta South', 'Ado-Odo/Ota', 'Egbado North',
        'Egbado South', 'Ewekoro', 'Ifo', 'Ijebu East', 'Ijebu North',
        'Ijebu North East', 'Ijebu Ode', 'Ikenne', 'Imeko Afon', 'Ipokia',
        'Obafemi Owode', 'Odeda', 'Odogbolu', 'Ogun Waterside',
        'Remo North', 'Shagamu'
      ],
      'Oyo': [
        'Afijio', 'Akinyele', 'Atiba', 'Atisbo', 'Egbeda', 'Ibadan North',
        'Ibadan North East', 'Ibadan North West', 'Ibadan South East',
        'Ibadan South West', 'Ibarapa Central', 'Ibarapa East',
        'Ibarapa North', 'Ido', 'Irepo', 'Iseyin', 'Itesiwaju', 'Iwajowa',
        'Kajola', 'Lagelu', 'Ogbomoso North', 'Ogbomoso South',
        'Ogo Oluwa', 'Olorunsogo', 'Oluyole', 'Ona Ara', 'Orelope',
        'Ori Ire', 'Oyo East', 'Oyo West', 'Saki East', 'Saki West',
        'Surulere'
      ],
      // Add more states as needed - using the existing NigeriaData as fallback
    };
  }

  /// Get fallback LGAs for a specific state
  List<String> getFallbackLGAs(String stateName) {
    final allFallbackLGAs = getFallbackAllLGAs();
    return allFallbackLGAs[stateName] ?? [];
  }

  int min(int a, int b) => a < b ? a : b;
}
