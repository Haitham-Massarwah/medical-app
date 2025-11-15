import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRegistrationService {
  static const String _baseUrl = 'https://your-api-domain.com/api'; // Replace with your actual API URL
  
  // Register new user (Option 1: Customer self-registration)
  static Future<Map<String, dynamic>> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'customer',
          'emergencyContact': emergencyContact,
          'emergencyPhone': emergencyPhone,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'gender': gender,
          'address': address,
          'isActive': true,
          'emailVerified': false,
        }),
      );

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        // Send verification email
        await _sendVerificationEmail(email, result['verificationToken']);
        return {
          'success': true,
          'message': 'Registration successful. Please check your email to verify your account.',
          'userId': result['userId'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register user by doctor (Option 2: Doctor creates customer)
  static Future<Map<String, dynamic>> registerCustomerByDoctor({
    required String firstName,
    required String lastName,
    required String email,
    required String doctorId,
    String? phone,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register-by-doctor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'role': 'customer',
          'createdBy': doctorId,
          'emergencyContact': emergencyContact,
          'emergencyPhone': emergencyPhone,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'gender': gender,
          'address': address,
          'isActive': true,
          'emailVerified': false,
        }),
      );

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        // Send completion email to customer
        await _sendCompletionEmail(email, result['completionToken']);
        return {
          'success': true,
          'message': 'Customer registered successfully. They will receive an email to complete their registration.',
          'userId': result['userId'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Complete registration (for doctor-created users)
  static Future<Map<String, dynamic>> completeRegistration({
    required String token,
    required String password,
    String? phone,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/complete-registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'password': password,
          'phone': phone,
          'emergencyContact': emergencyContact,
          'emergencyPhone': emergencyPhone,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'gender': gender,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registration completed successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Completion failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Verify email
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return {
          'success': true,
          'token': result['token'],
          'user': result['user'],
          'role': result['user']['role'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get user profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Send verification email
  static Future<void> _sendVerificationEmail(String email, String token) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/email/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'type': 'verification',
        }),
      );
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  // Send completion email
  static Future<void> _sendCompletionEmail(String email, String token) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/email/send-completion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'type': 'completion',
        }),
      );
    } catch (e) {
      print('Error sending completion email: $e');
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    // Israeli phone patterns
    final patterns = [
      r'^05\d{8}$', // Mobile: 05X-XXXXXXX
      r'^0[2-4]\d{7,8}$', // Landline: 0X-XXXXXXX
      r'^\+972[2-5]\d{8,9}$', // International format
    ];
    
    phone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    return patterns.any((pattern) => RegExp(pattern).hasMatch(phone));
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 8 && 
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }
}








