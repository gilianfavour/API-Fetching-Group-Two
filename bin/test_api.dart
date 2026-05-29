import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://admin.rasmuspharmaceuticals.com/api/v1/products');
  final response = await http.get(url);
  final data = jsonDecode(response.body);
  print(data.keys);
  if (data.containsKey('meta')) {
    print(data['meta']);
  }
}
