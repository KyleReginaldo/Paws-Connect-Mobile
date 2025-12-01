// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_provider.mapper.dart';

class HomeProvider {
  Future<Result<List<CapstoneLink>>> fetchCapstoneLinks() async {
    try {
      final result = await supabase
          .from('capstone_links')
          .select()
          .order('created_at', ascending: false);
      if (result.isNotEmpty) {
        List<CapstoneLink> links = [];
        for (var item in result) {
          links.add(CapstoneLinkMapper.fromMap(item));
        }
        return Result.success(links);
      } else {
        return Result.success([]);
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Something went wrong. Please try again later.');
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CapstoneLink with CapstoneLinkMappable {
  final int id;
  final DateTime createdAt;
  final String title;
  final String link;
  final String? description;
  final String? imageLink;
  final String? buttonLabel;

  CapstoneLink({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.link,
    this.description,
    this.imageLink,
    this.buttonLabel,
  });
}
