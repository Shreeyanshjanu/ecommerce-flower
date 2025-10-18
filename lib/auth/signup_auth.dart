import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bloom_boom/auth/firebase_provider.dart';

class SignupState extends StateNotifier<AsyncValue<User?>> {
  SignupState(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> signup(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);
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

final signupProvider = StateNotifierProvider<SignupState, AsyncValue<User?>>(
  (ref) => SignupState(ref),
);
