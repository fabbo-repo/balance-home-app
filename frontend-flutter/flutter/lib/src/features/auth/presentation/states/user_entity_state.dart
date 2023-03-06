import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserEntityState extends StateNotifier<UserEntity?> {
  UserEntityState(UserEntity? userEntity)
      : super(null);

  void setUserEntity(UserEntity userEntity) {
    state = userEntity;
  }
}
