import 'package:flutterapp/model/models/cancelation.dart';

abstract class CancelationRepository {
  Future<Cancelation?> getOne(String id);

  Future<List<Cancelation>> getAll();

  Future<Cancelation?> getOneByUseridAndEventid({
    required String userId,
    required String eventId,
  });

  Future<void> deleteByUseridAndEventid({
    required String userId,
    required String eventId,
  });

  Future<String> create(Cancelation cancelation);
}
