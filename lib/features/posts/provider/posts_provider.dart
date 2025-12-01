import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'posts_provider.mapper.dart';

class PostsProvider {
  Future<Result<List<Post>>> fetchPosts({int page = 1, int limit = 10}) async {
    try {
      final result = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      List<Post> posts = [];
      for (var e in result) {
        debugPrint('Post data: $e');
        posts.add(PostMapper.fromMap(e));
      }
      return Result.success(posts);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> addComment({
    required int postId,
    required String userId,
    required String comment,
  }) async {
    try {
      // First, fetch user information
      final userResult = await supabase
          .from('users')
          .select('username, profile_image_link')
          .eq('id', userId)
          .single();

      final newComment = {
        'user_id': userId,
        'username': userResult['username'] ?? 'Unknown User',
        'profile_image': userResult['profile_image_link'],
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };

      final result = await supabase
          .from('posts')
          .select('comments')
          .eq('id', postId)
          .single();

      final List<dynamic> currentComments = result['comments'] ?? [];
      currentComments.add(newComment);

      await supabase
          .from('posts')
          .update({'comments': currentComments})
          .eq('id', postId);

      return Result.success(true);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> toggleReaction({
    required int postId,
    required String userId,
  }) async {
    try {
      final result = await supabase
          .from('posts')
          .select('reactions')
          .eq('id', postId)
          .single();

      final List<dynamic> currentReactions = result['reactions'] ?? [];
      final existingIndex = currentReactions.indexWhere(
        (r) => r['user_id'] == userId,
      );

      if (existingIndex >= 0) {
        // Remove reaction
        currentReactions.removeAt(existingIndex);
      } else {
        // Add reaction
        currentReactions.add({
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await supabase
          .from('posts')
          .update({'reactions': currentReactions})
          .eq('id', postId);

      return Result.success(true);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> deleteComment({
    required int postId,
    required int commentIndex,
  }) async {
    try {
      final result = await supabase
          .from('posts')
          .select('comments')
          .eq('id', postId)
          .single();

      final List<dynamic> currentComments = result['comments'] ?? [];
      if (commentIndex >= 0 && commentIndex < currentComments.length) {
        currentComments.removeAt(commentIndex);

        await supabase
            .from('posts')
            .update({'comments': currentComments})
            .eq('id', postId);
      }

      return Result.success(true);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Post with PostMappable {
  final int id;
  final String? createdAt;
  final String title;
  final String category;
  final List<String>? images;
  final List<String>? links;
  final List<Map<String, dynamic>>? comments;
  final List<Map<String, dynamic>>? reactions;
  final String description;

  Post({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.category,
    required this.images,
    required this.links,
    required this.comments,
    required this.reactions,
    required this.description,
  });

  bool hasUserReacted(String userId) {
    if (reactions == null) return false;
    return reactions!.any((r) => r['user_id'] == userId);
  }
}
