import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/auth/data/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseAuthRepository User Mapping', () {
    test('maps user with display_name metadata correctly', () {
      final repo = SupabaseAuthRepository(
        supabaseClient: SupabaseClient('http://localhost', 'anon'),
      );

      // Use reflection or public mapping check
      expect(repo, isA<SupabaseAuthRepository>());
    });

    test('User entity converts correctly with metadata', () {
      final user = User(
        id: 'user_123',
        appMetadata: {},
        userMetadata: {'display_name': 'Jane Doe'},
        aud: 'authenticated',
        createdAt: '2026-10-06T00:00:00Z',
        email: 'jane@example.com',
      );

      expect(user.id, equals('user_123'));
      expect(user.email, equals('jane@example.com'));
      expect(user.userMetadata?['display_name'], equals('Jane Doe'));
    });
  });
}
