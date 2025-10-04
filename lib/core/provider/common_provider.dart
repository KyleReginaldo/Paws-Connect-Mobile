import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/transfer_object/address.dto.dart';

class CommonProvider {
  // In-memory cache for quick access
  static final Map<String, String> _responseCache = {};
  static const int _maxCacheEntries = 100; // Limit cache size

  /// Generate a cache key from content and about parameters
  String _generateCacheKey(String content, String about) {
    final combinedInput = '$content|$about';
    final normalized = combinedInput.toLowerCase().trim();
    // Simple hash function using string hashCode
    return normalized.hashCode.abs().toString();
  }

  /// Get cached response if available
  Future<String?> _getCachedResponse(String cacheKey) async {
    // Check in-memory cache first
    if (_responseCache.containsKey(cacheKey)) {
      debugPrint('Found response in memory cache');
      // Update usage stats in background
      _updateUsageStats(cacheKey);
      return _responseCache[cacheKey];
    }

    // Check database cache
    try {
      final result = await supabase
          .from('ai_responses')
          .select('response')
          .eq('cache_key', cacheKey)
          .maybeSingle();

      if (result != null) {
        final response = result['response'] as String;
        // Load into memory cache for faster access next time
        _responseCache[cacheKey] = response;
        // Update usage stats in background
        _updateUsageStats(cacheKey);
        debugPrint('Found response in database cache');
        return response;
      }
    } catch (e) {
      debugPrint('Error reading from database cache: $e');
    }
    return null;
  }

  /// Store response in cache
  Future<void> _storeInCache(
    String cacheKey,
    String content,
    String about,
    String response,
  ) async {
    try {
      // Store in memory cache
      _responseCache[cacheKey] = response;

      // Limit memory cache size
      if (_responseCache.length > _maxCacheEntries) {
        final keysToRemove = _responseCache.keys
            .take(_responseCache.length - _maxCacheEntries)
            .toList();
        for (final key in keysToRemove) {
          _responseCache.remove(key);
        }
      }

      // Store in database cache
      await supabase.from('ai_responses').upsert({
        'cache_key': cacheKey,
        'content': content,
        'about': about,
        'response': response,
        'usage_count': 1,
        'last_used_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Stored response in database cache');
    } catch (e) {
      debugPrint('Error storing in database cache: $e');
    }
  }

  /// Update usage statistics for cached response
  Future<void> _updateUsageStats(String cacheKey) async {
    try {
      // First, get the current usage count
      final result = await supabase
          .from('ai_responses')
          .select('usage_count')
          .eq('cache_key', cacheKey)
          .maybeSingle();

      if (result != null) {
        final currentCount = (result['usage_count'] as int?) ?? 0;

        // Update both last_used_at and usage_count
        await supabase
            .from('ai_responses')
            .update({
              'last_used_at': DateTime.now().toIso8601String(),
              'usage_count': currentCount + 1,
            })
            .eq('cache_key', cacheKey);
      }
    } catch (e) {
      debugPrint('Error updating usage stats: $e');
    }
  }

  /// Clear all cached responses (useful for testing or when needed)
  Future<void> clearResponseCache() async {
    try {
      _responseCache.clear();
      await supabase.from('ai_responses').delete().neq('id', 0); // Delete all
      debugPrint('Cleared all cached responses from database');
    } catch (e) {
      debugPrint('Error clearing database cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    try {
      final result = await supabase
          .from('ai_responses')
          .select('id, usage_count, created_at')
          .order('usage_count', ascending: false);

      final responses = result as List;
      final totalResponses = responses.length;
      final totalUsage = responses.fold<int>(
        0,
        (sum, item) => sum + (item['usage_count'] as int? ?? 0),
      );

      return {
        'total_cached_responses': totalResponses,
        'total_usage_count': totalUsage,
        'average_usage_per_response': totalResponses > 0
            ? totalUsage / totalResponses
            : 0,
        'memory_cache_size': _responseCache.length,
      };
    } catch (e) {
      debugPrint('Error getting cache statistics: $e');
      return {
        'total_cached_responses': 0,
        'total_usage_count': 0,
        'average_usage_per_response': 0,
        'memory_cache_size': _responseCache.length,
      };
    }
  }

  Future<Result<String>> addAddress(AddAddressDTO dto) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASE_URL')}/address'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );
      print('address response: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return Result.success("Address added successfully");
      } else {
        return Result.error("Failed to add address: ${data['message']}");
      }
    } catch (e) {
      return Result.error("Failed to add address: ${e.toString()}");
    }
  }

  Future<Result<String>> deleteAddress(int addressId) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.delete(
        Uri.parse('${dotenv.get('BASE_URL')}/address/$addressId'),
      );
      print('delete address response: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Result.success("Address deleted successfully");
      } else {
        return Result.error("Failed to delete address: ${data['message']}");
      }
    } catch (e) {
      return Result.error("Failed to delete address: ${e.toString()}");
    }
  }

  Future<Result<String>> setDefaultAddress(String userId, int addressId) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASE_URL')}/address/default'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'addressId': addressId}),
      );
      print('set default address response: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Result.success("Address set as default successfully");
      } else {
        return Result.error(
          "Failed to set default address: ${data['message']}",
        );
      }
    } catch (e) {
      return Result.error("Failed to set default address: ${e.toString()}");
    }
  }

  Future<Result<int>> fetchUserUnviewedMessagesCount(String userId) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      // New logic: forum_chats has a 'viewers' (array) column listing user ids who have viewed the message.
      // We need to count chats in forums the user is a member of where:
      //   - sender != userId (don't count own messages)
      //   - viewers is null OR does not contain userId

      // 1. Fetch forum memberships
      final forumMemberships = await supabase
          .from('forum_members')
          .select('forum')
          .eq('member', userId);

      if (forumMemberships.isEmpty) {
        return Result.success(0);
      }
      final forumIds = (forumMemberships as List)
          .map((e) => e['forum'])
          .where((v) => v != null)
          .toSet() // ensure distinct
          .toList();

      if (forumIds.isEmpty) return Result.success(0);

      // 2. Fetch chats for those forums (only required fields)
      final rawChats = await supabase
          .from('forum_chats')
          .select('id, viewers, sender, forum')
          .neq('sender', userId)
          .inFilter('forum', forumIds);

      final chatsList = (rawChats as List);
      if (chatsList.isEmpty) return Result.success(0);

      int unviewed = 0; // 3. Filter locally for messages not yet viewed by user
      for (final row in chatsList) {
        final viewers = row['viewers'];
        if (viewers == null) {
          unviewed++; // no viewers yet
          continue;
        }
        if (viewers is List) {
          if (!viewers.contains(userId)) {
            unviewed++;
          }
        } else {
          // Unexpected type: treat as unviewed to be safe
          unviewed++;
        }
      }
      debugPrint('Unviewed messages count: $unviewed');
      return Result.success(unviewed);
    } catch (e) {
      debugPrint('Error fetching unviewed messages count: ${e.toString()}');
      return Result.error("Failed to fetch count: ${e.toString()}");
    }
  }

  Future<Result<bool>> markForumMessagesAsViewed({
    required String userId,
    required int forumId,
  }) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      // Fetch ids of chats in this forum the user hasn't viewed yet
      final rawChats = await supabase
          .from('forum_chats')
          .select('id, viewers, sender')
          .eq('forum', forumId)
          .neq('sender', userId);

      final chatsList = (rawChats as List);
      if (chatsList.isEmpty) {
        return Result.success(true); // nothing to update
      }
      final toUpdate = <Map<String, dynamic>>[];
      for (final row in chatsList) {
        final viewers = row['viewers'];
        if (viewers == null || (viewers is List && !viewers.contains(userId))) {
          final id = row['id'];
          if (id is int) {
            toUpdate.add({
              'id': id,
              'viewers': viewers is List ? [...viewers, userId] : [userId],
            });
          }
        }
      }
      if (toUpdate.isEmpty) return Result.success(true);

      // Loop updates (could be optimized by RPC or batching if needed)
      for (final item in toUpdate) {
        final id = item['id'];
        final newViewers = item['viewers'];
        try {
          await supabase
              .from('forum_chats')
              .update({'viewers': newViewers})
              .eq('id', id);
        } catch (_) {
          /* ignore individual failures */
        }
      }
      return Result.success(true);
    } catch (e) {
      return Result.error('Failed to mark viewed: $e');
    }
  }

  Future<Result<int>> fetchUserUnviewedNotificationsCount(String userId) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      final unviewedNotifCount = await supabase
          .from('notifications')
          .select('id')
          .eq('user', userId)
          .eq('is_viewed', false)
          .count();
      debugPrint('user id: $userId');
      debugPrint('Unviewed notifications count: ${unviewedNotifCount.count}');
      return Result.success(unviewedNotifCount.count);
    } catch (e) {
      return Result.error("Failed to fetch count: ${e.toString()}");
    }
  }

  /// Marks all notifications for the given [userId] as viewed (is_viewed = true)
  /// only if they are currently null or false. Returns `true` on success.
  Future<Result<bool>> markAllNotificationsAsViewed(String userId) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      // Fetch ids of notifications that are not yet viewed
      final raw = await supabase
          .from('notifications')
          .select('id')
          .eq('user', userId)
          .or('is_viewed.is.null,is_viewed.eq.false');

      final list = (raw as List?) ?? [];
      if (list.isEmpty) {
        return Result.success(true); // nothing to update
      }

      final ids = list
          .map((e) => e is Map ? e['id'] : null)
          .whereType<int>()
          .cast<int>()
          .toList();

      if (ids.isEmpty) return Result.success(true);

      // Update all in a single inFilter call
      await supabase
          .from('notifications')
          .update({'is_viewed': true})
          .inFilter('id', ids);

      debugPrint(
        'Marked ${ids.length} notifications as viewed for user $userId',
      );
      return Result.success(true);
    } catch (e) {
      return Result.error('Failed to mark notifications viewed: $e');
    }
  }

  /// Marks a single notification identified by [notificationId] as viewed.
  Future<Result<bool>> markNotificationAsViewed(int notificationId) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      await supabase
          .from('notifications')
          .update({'is_viewed': true})
          .eq('id', notificationId);
      debugPrint('Marked notification $notificationId as viewed');
      return Result.success(true);
    } catch (e) {
      return Result.error('Failed to mark notification viewed: $e');
    }
  }

  Future<Result<String>> requestCompletion({
    required String content,
    required String about,
  }) async {
    // Generate cache key
    final cacheKey = _generateCacheKey(content, about);

    // Check cache first
    final cachedResponse = await _getCachedResponse(cacheKey);
    if (cachedResponse != null) {
      return Result.success(cachedResponse);
    }

    // Check internet connectivity
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final body = {
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a helpful and knowledgeable assistant for Paws Connect, a pet adoption and care mobile application. You specialize in providing information about pet care, adoption processes, animal health, training, nutrition, and general pet-related questions. Your responses should be friendly, informative, and focused on helping pet owners and potential adopters. The context provided will include specific information about the user's situation or help they are seeking: $about. Always acknowledge their need for help and provide supportive, actionable advice. When users ask about which shelter or where the shelter is located, inform them that the shelter is 'Tails of Freedom - Tails of Haven' located in Silang, Cavite. If a question is completely unrelated to pets, animals, or the Paws Connect app, politely redirect the conversation back to pet-related topics.",
          },
          {"role": "user", "content": content},
        ],
      };

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': "application/json",
          'Authorization': 'Bearer ${dotenv.get('OPENAI_API_KEY')}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Store in cache for future use
        await _storeInCache(cacheKey, content, about, aiResponse);

        return Result.success(aiResponse);
      } else {
        return Result.error(
          'Failed to get completion: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      return Result.error('Error requesting completion: ${e.toString()}');
    }
  }
}
