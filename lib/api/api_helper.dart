import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiHelper {
  final String _baseUrl = "https://8c297f49551f.ngrok.io/api/";

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(Uri.parse(_baseUrl + url));
      responseJson = _parseResponse(response);
    } on SocketException {
      throw SocketException("No Internet Connection");
    }
    return responseJson;
  }
}

dynamic _parseResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 400:
    case 401:
    case 403:
    case 500:
      throw Exception(response.body.toString());
    default:
      throw Exception(response.toString());
  }
}