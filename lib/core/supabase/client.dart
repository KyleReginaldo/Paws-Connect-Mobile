import '../services/supabase_service.dart';

final USER_ID = supabase.auth.currentUser?.id ?? '';
