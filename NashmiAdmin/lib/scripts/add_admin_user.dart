import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  const supabaseUrl = 'https://ohhomkhnzsozopwwnmfw.supabase.co';
  const supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9oaG9ta2huenNvem9wd3dubWZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzQ3NTgsImV4cCI6MjA3MjY1MDc1OH0.O4W8YQB71cOvR67BhIHP-_P6FjnJJgHwEKqDlva8BQA'; // User provided service role key

  final supabase = SupabaseClient(supabaseUrl, supabaseServiceRoleKey);

  final email = 'admin@nashmi.com';
  final password = '123';

  try {
    final response = await supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: password,
        userMetadata: {'role': 'admin'},
      ),
    );
    print('Admin user created: \${response.user?.email}');
  } catch (e) {
    print('Error creating admin user: \$e');
  }
}
