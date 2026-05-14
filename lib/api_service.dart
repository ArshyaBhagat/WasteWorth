import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

// Emulator -> Django on your laptop
//const String baseUrl = 'http://10.0.2.2:8000/api';
//const String baseUrl = "http://127.0.0.1:8000/api";
const String baseUrl = "http://10.58.171.129:8000/api";



class ApiService {
  Map<String, String> _authHeaders(String token, {bool json = false}) {
    final headers = <String, String>{
      'Authorization': 'Token $token',
    };
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // =============== REGISTER ===============
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone_number': phone,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 400) {
      debugPrint('REGISTER ERROR BODY: ${response.body}');
      try {
        final data = jsonDecode(response.body);
        throw Exception(data.toString());
      } catch (_) {
        throw Exception(response.body);
      }
    }

    throw Exception('Register failed (${response.statusCode}): ${response.body}');
  }

  // =============== LOGIN ===============
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('LOGIN ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Invalid username or password');
  }

  // =============== CURRENT USER ===============
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final url = Uri.parse('$baseUrl/auth/me/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('ME ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Session expired');
  }

  // =============== FORGOT PASSWORD ===============
  Future<void> forgotPassword({
    required String username,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/forgot_password/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint(
          'FORGOT PASSWORD ERROR (${response.statusCode}): ${response.body}');
      throw Exception('Password reset failed');
    }
  }

  // =============== UPDATE USER ===============
  Future<Map<String, dynamic>> updateUser({
    required String token,
    String? email,
    String? phoneNumber,
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/auth/update/');
    final body = <String, dynamic>{};

    if (email != null) body['email'] = email;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (address != null) body['address'] = address;

    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }

    final response = await http.patch(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('UPDATE USER ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to update user: ${response.body}');
  }

  // =============== PICKUPS LIST ===============
  Future<List<dynamic>> getPickups(String token) async {
    final url = Uri.parse('$baseUrl/pickups/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('PICKUPS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load pickups: ${response.body}');
  }

  // =============== AVAILABLE PICKUPS FOR DRIVERS ===============
  Future<List<dynamic>> getAvailablePickups(String token) async {
    final url = Uri.parse('$baseUrl/pickups/available/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint(
        'AVAILABLE PICKUPS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load available pickups: ${response.body}');
  }

  // =============== DRIVER PICKUPS ===============
  Future<List<dynamic>> getDriverPickups(String token) async {
    final url = Uri.parse('$baseUrl/pickups/driver/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('DRIVER PICKUPS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load driver pickups: ${response.body}');
  }

  // =============== CREATE PICKUP (JSON) ===============
  // ⚠️ Keep it, but do NOT use it for your pickup creation now
  // because backend expects multipart.
  Future<Map<String, dynamic>> createPickup({
    required String token,
    required String manpower,
    required String date,
    required String timeSlot,
    required String weight,
    String? address,
    required List<String> categories,
  }) async {
    final url = Uri.parse('$baseUrl/pickups/create/');

    final response = await http.post(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode({
        'manpower': manpower,
        'date': date,
        'time_slot': timeSlot,
        'weight': weight,
        'address': address,
        'categories': categories,
      }),
    );

    debugPrint('CreatePickup status: ${response.statusCode}');
    debugPrint('CreatePickup body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 400) {
      throw Exception('Validation error: ${response.body}');
    }

    throw Exception(
        'Failed to create pickup (${response.statusCode}): ${response.body}');
  }

  // =============== CREATE PICKUP (MULTIPART ALWAYS) ===============
  // ✅ This works WITH photo and WITHOUT photo.
  Future<Map<String, dynamic>> createPickupWithPhoto({
    required String token,
    required String manpower,
    required String date,
    required String timeSlot,
    required String weight,
    String? address,
    required List<String> categories,
    File? photoFile, // ✅ OPTIONAL NOW
  }) async {
    final url = Uri.parse('$baseUrl/pickups/create/');
    debugPrint('Creating pickup (multipart) to: $url');

    final request = http.MultipartRequest('POST', url);

    // TokenAuthentication expects: Authorization: Token <token>
    request.headers['Authorization'] = 'Token $token';

    // Fields (all strings)
    request.fields['manpower'] = manpower;
    request.fields['date'] = date;
    request.fields['time_slot'] = timeSlot;
    request.fields['weight'] = weight;

    if (address != null && address.trim().isNotEmpty) {
      request.fields['address'] = address.trim();
    }

    // ✅ Keep same as your backend expects
    request.fields['categories'] = jsonEncode(categories);

    // ✅ Attach file ONLY if present
    if (photoFile != null) {
      debugPrint('Uploading file path: ${photoFile.path}');
      debugPrint('File exists: ${photoFile.existsSync()}');

      if (photoFile.existsSync()) {
        debugPrint('File size: ${photoFile.lengthSync()} bytes');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
          filename: p.basename(photoFile.path),
        ),
      );
    } else {
      debugPrint('No photo selected. Sending multipart WITHOUT photo.');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('Multipart status: ${response.statusCode}');
    debugPrint('Multipart body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 400) {
      throw Exception('Validation error: ${response.body}');
    }

    throw Exception(
        'Failed to create pickup (${response.statusCode}): ${response.body}');
  }

  // =============== ACCEPT PICKUP ===============
  Future<Map<String, dynamic>> acceptPickup({
    required String token,
    required int pickupId,
  }) async {
    final url = Uri.parse('$baseUrl/pickups/$pickupId/accept/');
    final response = await http.patch(
      url,
      headers: _authHeaders(token, json: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('ACCEPT PICKUP ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to accept pickup: ${response.body}');
  }

  // =============== CANCEL PICKUP ===============
  Future<Map<String, dynamic>> cancelPickup({
    required String token,
    required int pickupId,
  }) async {
    final url = Uri.parse('$baseUrl/pickups/$pickupId/cancel/');
    final response = await http.patch(
      url,
      headers: _authHeaders(token, json: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('CANCEL PICKUP ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to cancel pickup: ${response.body}');
  }

  // =============== PRODUCTS ===============
  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/products/');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('PRODUCTS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load products: ${response.body}');
  }

  // =============== DRIVERS LIST ===============
  Future<List<dynamic>> getDrivers(String token) async {
    final url = Uri.parse('$baseUrl/drivers/');
    final response = await http.get(
      url,
      headers: _authHeaders(token, json: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('DRIVERS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load drivers: ${response.body}');
  }

  // =============== DRIVER DETAILS (GET) ===============
  Future<Map<String, dynamic>> getDriverDetails(String token) async {
    final url = Uri.parse('$baseUrl/driver-details/retrieve/');
    final response = await http.get(
      url,
      headers: _authHeaders(token, json: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      throw Exception('Driver details not found');
    }

    debugPrint(
        'DRIVER DETAILS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load driver details: ${response.body}');
  }

  // =============== DRIVER DETAILS (CREATE) ===============
  Future<Map<String, dynamic>> createDriverDetails({
    required String token,
    required String driverName,
    required String phoneNumber,
    required String emailId,
    required String address,
    required String vehicleName,
    required String vehicleNumber,
  }) async {
    final url = Uri.parse('$baseUrl/driver-details/create/');

    final response = await http.post(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode({
        'driver_name': driverName,
        'phone_number': phoneNumber,
        'email_id': emailId,
        'address': address,
        'vehicle_name': vehicleName,
        'vehicle_number': vehicleNumber,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint(
        'CREATE DRIVER DETAILS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to create driver details: ${response.body}');
  }

  // =============== DRIVER DETAILS (UPDATE) ===============
  Future<Map<String, dynamic>> updateDriverDetails({
    required String token,
    String? driverName,
    String? phoneNumber,
    String? emailId,
    String? address,
    String? vehicleName,
    String? vehicleNumber,
    String? status,
  }) async {
    final url = Uri.parse('$baseUrl/driver-details/update/');
    final body = <String, dynamic>{};

    if (driverName != null) body['driver_name'] = driverName;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (emailId != null) body['email_id'] = emailId;
    if (address != null) body['address'] = address;
    if (vehicleName != null) body['vehicle_name'] = vehicleName;
    if (vehicleNumber != null) body['vehicle_number'] = vehicleNumber;
    if (status != null) body['status'] = status;

    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }

    final response = await http.patch(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint(
        'UPDATE DRIVER DETAILS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to update driver details: ${response.body}');
  }

  // =============== REPORTS (CREATE) ===============
  Future<Map<String, dynamic>> createReport({
    required String token,
    required int pickupId,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/reports/create/');

    final response = await http.post(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode({
        'pickup': pickupId,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('CREATE REPORT ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to create report: ${response.body}');
  }

  // =============== REPORTS (DRIVER LIST) ===============
  Future<List<dynamic>> getDriverReports(String token) async {
    final url = Uri.parse('$baseUrl/reports/driver/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint(
        'DRIVER REPORTS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load driver reports: ${response.body}');
  }

  // =============== BILLS (CREATE) ===============
  Future<Map<String, dynamic>> createBill({
    required String token,
    required int pickupId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
  }) async {
    final url = Uri.parse('$baseUrl/bills/create/');

    final response = await http.post(
      url,
      headers: _authHeaders(token, json: true),
      body: jsonEncode({
        'pickup': pickupId,
        'items': items,
        'grand_total': grandTotal,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('CREATE BILL ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to create bill: ${response.body}');
  }

  // =============== BILLS (DRIVER LIST) ===============
  Future<List<dynamic>> getDriverBills(String token) async {
    final url = Uri.parse('$baseUrl/bills/driver/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('DRIVER BILLS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load driver bills: ${response.body}');
  }

  // =============== BILLS (USER LIST) ===============
  Future<List<dynamic>> getUserBills(String token) async {
    final url = Uri.parse('$baseUrl/bills/user/');
    final response = await http.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    debugPrint('USER BILLS ERROR (${response.statusCode}): ${response.body}');
    throw Exception('Failed to load user bills: ${response.body}');
  }
}
