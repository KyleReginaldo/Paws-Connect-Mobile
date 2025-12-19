import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

Future<String?> fetchGameTitle() async {
  final url = Uri.parse('https://kylereginaldo.itch.io/pawsconnect');

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load page');
  }

  final document = parser.parse(response.body);

  // Select: <h1 class="game_title">PawsConnect(2.1.2)</h1>
  final Element? titleElement = document.querySelector('h1.game_title');

  return titleElement?.text.trim().split('(').last.split(')').first;
}
