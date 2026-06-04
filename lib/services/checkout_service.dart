import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutService {
  static const String baseUrl = 'https://testing.rasmuspharmaceuticals.com/api/v1';

  // =========================================
  // FETCH REGIONS
  // =========================================
  Future<List<Map<String, dynamic>>> fetchRegions() async {
    final url = Uri.parse('$baseUrl/regions');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return _parseList(decoded);
      } else {
        throw Exception('Failed to load regions (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error fetching regions: $e');
    }
  }

  // =========================================
  // FETCH TOWNS BY REGION
  // =========================================
  Future<List<Map<String, dynamic>>> fetchTowns(int regionId) async {
    final url = Uri.parse('$baseUrl/regions/$regionId/towns');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return _parseList(decoded);
      } else {
        throw Exception('Failed to load towns (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error fetching towns: $e');
    }
  }

  // =========================================
  // PLACE ORDER
  // =========================================
  Future<Map<String, dynamic>> placeOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    required int deliveryRegionId,
    required int deliveryTownId,
    required String deliveryAddress,
    String? referenceContact,
    String? paymentMethod,
  }) async {
    final url = Uri.parse('$baseUrl/orders');

    final body = {
      'items': items,
      'delivery_method': deliveryMethod,
      'delivery_region_id': deliveryRegionId,
      'delivery_town_id': deliveryTownId,
      'delivery_address': deliveryAddress,
    };

    if (referenceContact != null && referenceContact.isNotEmpty) {
      body['reference_contact'] = referenceContact;
    }
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      body['payment_method'] = paymentMethod;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            final errors = responseData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstVal = errors.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                throw Exception(firstVal.first);
              } else {
                throw Exception(firstVal.toString());
              }
            }
          }
          final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Failed to place order';
          throw Exception(errorMsg);
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException') && !e.toString().contains('TypeError')) {
            rethrow;
          }
          throw Exception('Failed to place order (Status: ${response.statusCode}). Response: ${response.body}');
        }
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error placing order: $e');
    }
  }

  // HELPER: Safely parse a list from the response payload, handling wrapping
  List<Map<String, dynamic>> _parseList(dynamic decoded) {
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    } else if (decoded is Map) {
      final data = decoded['data'] ?? decoded['regions'] ?? decoded['towns'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }
}
