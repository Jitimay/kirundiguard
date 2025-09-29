import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _authService.isLoggedIn();
    emit(isLoggedIn ? AuthAuthenticated() : AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authService.login(event.email, event.password);
      emit(success ? AuthAuthenticated() : AuthError('Invalid credentials'));
    } catch (e) {
      emit(AuthError('Login failed'));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authService.signUp(event.email, event.password);
      emit(success ? AuthAuthenticated() : AuthError('Sign up failed'));
    } catch (e) {
      emit(AuthError('Sign up failed'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }
}
