import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bloom_boom/auth/firebase_provider.dart';

class LoginState extends StateNotifier<AsyncValue<User?>> {
  LoginState(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> Login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final LoginProvider = StateNotifierProvider<LoginState, AsyncValue<User?>>(
  (ref) => LoginState(ref),
);
