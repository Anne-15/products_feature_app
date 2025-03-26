import 'dart:convert';

import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete }

class HttpService {
  late http.Client client;

  HttpService() : client = http.Client();

  Future<Map<String, dynamic>> request({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers, // Add this parameter
  }) async {
    try {
      http.Response response;

      final uri = Uri.parse(url);
      final defaultHeaders = {"Content-Type": "application/json"};

      // Merge provided headers with default headers
      final combinedHeaders = {
        ...defaultHeaders,
        if (headers != null) ...headers
      };

      switch (method) {
        case HttpMethod.get:
          response = await client.get(uri, headers: combinedHeaders);
          break;
        case HttpMethod.post:
          response = await client.post(
            uri,
            body: jsonEncode(body),
            headers: combinedHeaders,
          );
          break;
        case HttpMethod.put:
          response = await client.put(
            uri,
            body: jsonEncode(body),
            headers: combinedHeaders,
          );
          break;
        case HttpMethod.delete:
          response = await client.delete(uri, headers: combinedHeaders);
          break;
        default:
          throw Exception('Invalid request method');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to make request with status code: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}