import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class ShopeeService {
  /// Fetches a product page and attempts to return an absolute image URL.
  ///
  /// The function tries multiple strategies: open-graph meta, twitter meta,
  /// JSON-LD image fields, and scanning <img> tags with simple heuristics.
  Future<String?> getShopeeImageUrl(String productLink) async {
    try {
      final uri = Uri.parse(productLink);
      final response = await http
          .get(uri, headers: {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final document = parse(response.body);

      // 1) Try open graph meta
      final og = document
          .querySelector("meta[property='og:image']")
          ?.attributes['content'];
      if (og != null && og.isNotEmpty) return _resolveUrl(uri, og);

      // 2) Try twitter image
      final tw = document
          .querySelector("meta[name='twitter:image']")
          ?.attributes['content'];
      if (tw != null && tw.isNotEmpty) return _resolveUrl(uri, tw);

      // 3) Try JSON-LD
      final scripts = document.getElementsByTagName('script');
      for (final s in scripts) {
        final type = s.attributes['type'];
        if (type != null && type.contains('ld+json')) {
            try {
            final json = jsonDecode(s.text);
            if (json is Map && json.containsKey('image')) {
              final img = json['image'];
              if (img is String && img.isNotEmpty) return _resolveUrl(uri, img);
              if (img is List && img.isNotEmpty && img[0] is String) {
                return _resolveUrl(uri, img[0]);
              }
            }
          } catch (_) {
            // ignore JSON parse errors
          }
        }
      }

      // 4) Scan img tags and pick a likely product image
      final imgs = document.getElementsByTagName('img');
      final candidates = <String>[];
      for (final img in imgs) {
        final src = img.attributes['src'] ?? img.attributes['data-src'] ?? '';
        if (src.isEmpty) continue;
        final low = src.toLowerCase();
        // skip known non-product images
        if (low.contains('favicon') || low.contains('icon') || low.contains('logo') || low.contains('splash') || low.contains('sprite')) continue;
        candidates.add(src);
      }

      // Prefer URLs that look like CDN or have path segments suggesting product images
      String? pick;
      for (final c in candidates) {
        final lc = c.toLowerCase();
        if (lc.contains('shopee') || lc.contains('cf.shopee') || lc.contains('cdn') || lc.contains('image') || lc.contains('images') || lc.contains('item')) {
          pick = c;
          break;
        }
      }
      pick ??= candidates.isNotEmpty ? candidates.first : null;
      if (pick != null && pick.isNotEmpty) return _resolveUrl(uri, pick);

    } catch (e) {
      // keep silent in production code; return null on error
    }
    return null;
  }

  String? _resolveUrl(Uri base, String link) {
    try {
      final trimmed = link.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
      if (trimmed.startsWith('//')) return 'https:$trimmed';
      // relative path
      final resolved = base.resolve(trimmed).toString();
      return resolved;
    } catch (e) {
      return null;
    }
  }
}
