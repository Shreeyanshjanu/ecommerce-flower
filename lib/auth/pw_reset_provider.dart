import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bloom_boom/auth/firebase_provider.dart';

class PwResetState extends StateNotifier<AsyncValue<void>> {
  PwResetState(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(email: email);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final pwResetProvider = StateNotifierProvider<PwResetState, AsyncValue<void>>(
  (ref) => PwResetState(ref),
);
