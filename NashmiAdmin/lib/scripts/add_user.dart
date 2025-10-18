import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ohhomkhnzsozopwwnmfw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9oaG9ta2huenNvem9wd3dubWZ3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzA3NDc1OCwiZXhwIjoyMDcyNjUwNzU4fQ.KSg2AQxRkt9Cuo7yYMZq6f2qf_KCZf4wXBcs8XtAPEk', // Service Role Key
  );

  final supabase = Supabase.instance.client;

  final userAttributes = AdminUserAttributes(
    email: 'goba2995@gmail.com',
    password: '123',
    userMetadata: {
      'full_name': 'Goba',
      'role': 'admin',
    },
    // emailRedirectTo: 'https://your-app-url.com', // Optional - removed due to API change
  );

  final response = await supabase.auth.admin.createUser(userAttributes);

  if (response.user != null) {
    print('User created: \${response.user!.email}');
  } else {
    print('Error creating user: \${response.error?.message}');
  }
}
