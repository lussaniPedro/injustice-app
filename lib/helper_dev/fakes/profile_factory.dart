import '../../domain/models/profile_entity.dart';
import 'fakes_factory.dart';

class ProfileFactory {
  /// Cria uma instância de Profile com dados falsos
  static Profile single() {
    return FakeFactory.profile();
  }

  /// Cria uma lista de Profiles com dados falsos
  static List<Profile> list([int count = 5]) {
    var list = List.generate(
      count,
      (index) => single(),
    );

    return list;
  }
}
