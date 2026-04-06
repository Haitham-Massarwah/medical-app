import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';

/// Placeholder state for optional BLoC wiring; use cases are registered in GetIt.
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

abstract class AuthEvent {
  const AuthEvent();
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required RefreshTokenUseCase refresh,
  }) : super(const AuthInitial()) {
    // Hook events → use cases when migrating screens to Bloc.
  }
}
