import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/models.dart';

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final _supabase = SupabaseConfig.client;

  // Check if user is authenticated
  Future<void> checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final userData = await _supabase
            .from(DbTables.users)
            .select()
            .eq('id', session.user.id)
            .single();
        
        emit(AuthAuthenticated(UserModel.fromJson(userData)));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _supabase
            .from(DbTables.users)
            .select()
            .eq('id', response.user!.id)
            .single();

        emit(AuthAuthenticated(UserModel.fromJson(userData)));
      } else {
        emit(AuthError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthError('خطأ في تسجيل الدخول: ${e.toString()}'));
    }
  }

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String gender,
    UserRole role = UserRole.customer,
  }) async {
    try {
      emit(AuthLoading());

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        final userProfile = {
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'region': region,
          'gender': gender,
          'role': role.name,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from(DbTables.users).insert(userProfile);

        emit(AuthAuthenticated(UserModel.fromJson(userProfile)));
      } else {
        emit(AuthError('فشل إنشاء الحساب'));
      }
    } catch (e) {
      emit(AuthError('خطأ في إنشاء الحساب: ${e.toString()}'));
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('خطأ في تسجيل الخروج: ${e.toString()}'));
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      emit(AuthLoading());
      await _supabase.auth.resetPasswordForEmail(email);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('خطأ في إعادة تعيين كلمة المرور: ${e.toString()}'));
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? region,
  }) async {
    try {
      final currentState = state;
      if (currentState is! AuthAuthenticated) return;

      emit(AuthLoading());

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (region != null) updates['region'] = region;

      await _supabase
          .from(DbTables.users)
          .update(updates)
          .eq('id', userId);

      final userData = await _supabase
          .from(DbTables.users)
          .select()
          .eq('id', userId)
          .single();

      emit(AuthAuthenticated(UserModel.fromJson(userData)));
    } catch (e) {
      emit(AuthError('خطأ في تحديث الملف الشخصي: ${e.toString()}'));
    }
  }
}