import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';

Future<AutoRefreshingAuthClient> getSheetsClient() async {
  final jsonString = await rootBundle.loadString('assets/credentials.json');
  final jsonData = json.decode(jsonString);

  final accountCredentials = ServiceAccountCredentials.fromJson(jsonData);
  final scopes = ['https://www.googleapis.com/auth/spreadsheets'];

  return await clientViaServiceAccount(accountCredentials, scopes);
}

