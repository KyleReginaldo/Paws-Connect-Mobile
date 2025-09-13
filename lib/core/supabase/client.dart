import '../services/supabase_service.dart';

String? USER_ID = supabase.auth.currentUser?.id;
