import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsService {
  final String _spreadsheetId;
  final AutoRefreshingAuthClient _client;

  GoogleSheetsService(this._spreadsheetId, this._client);

  /// Get a single cell value like 'Sheet1!B2'
  Future<String?> getCell(String range) async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/$range';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final values = data['values'] as List<dynamic>?;
      return values?.isNotEmpty == true ? values![0][0].toString() : null;
    } else {
      print('Failed to get cell: ${response.body}');
      return null;
    }
  }

  /// Update a single cell like 'Sheet1!B2'
  Future<bool> updateCell(String range, String value) async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/$range?valueInputOption=USER_ENTERED';

    final body = jsonEncode({
      'range': range,
      'majorDimension': 'ROWS',
      'values': [
        [value]
      ],
    });

    final response = await _client.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  /// Create a new sheet tab
  Future<bool> createSheet(String title) async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId:batchUpdate';

    final body = jsonEncode({
      'requests': [
        {
          'addSheet': {
            'properties': {
              'title': title,
            }
          }
        }
      ]
    });

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }
}
