import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Converts a remote URL to XFile
Future<XFile> urlToXFile(String url) async {
  // Fetch the file from the URL
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to load file from URL');
  }

  // Get the filename from URL
  final fileName = path.basename(url);

  // Create a temporary file to store the content
  final tempDir = Directory.systemTemp;
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(response.bodyBytes);

  // Return as XFile
  return XFile(file.path);
}

/// Converts multiple remote URLs to a list of XFiles
Future<List<XFile>> urlsToXFiles(List<String> urls) async {
  // Use Future.wait to fetch all files concurrently
  return Future.wait(urls.map((url) => urlToXFile(url)));
}

Future<XFile> createTextFile(String text) async {
  final tempDir = Directory.systemTemp;
  final file = File('${tempDir.path}/message.txt');
  await file.writeAsString(text);
  return XFile(file.path);
}
