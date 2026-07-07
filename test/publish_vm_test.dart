import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/watch_draft_status_usecase.dart';
import 'package:vivia_mobile/features/lessor/presentation/viewmodels/property_draft_viewmodel.dart';

class FakeLessorRepository implements LessorRepository {
  final List<String> log = [];

  @override
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body) async {
    log.add('createDraft:start');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    log.add('createDraft:done');
    return const DraftUploadModel(
      draftId: 'draft-1',
      status: 'PENDING',
      uploads: [
        DraftUploadItem(
          fileKey: 'main',
          uploadUrl: 'https://s3.fake/main',
          storageKey: 'k1',
        ),
      ],
    );
  }

  @override
  Future<void> uploadFile(
      String uploadUrl, String contentType, List<int> bytes) async {
    log.add('upload:start');
    await Future<void>.delayed(const Duration(milliseconds: 150));
    log.add('upload:done');
  }

  @override
  Future<List<AmenityModel>> getAmenities() async => [];

  @override
  Future<List<NeighborhoodModel>> getNeighborhoods(String cp) async => [];

  @override
  Stream<DraftStatusEvent> watchDraftStatus(String draftId) {
    log.add('sse:start');
    return const Stream<DraftStatusEvent>.empty();
  }
}

void main() {
  test('publish() retorna con success apenas responde el POST', () async {
    final dir = await Directory.systemTemp.createTemp('publish_vm_test');
    final photo = File('${dir.path}/main.jpg')
      ..writeAsBytesSync(List.filled(100, 7));

    final repo = FakeLessorRepository();
    final vm = PropertyDraftViewModel(
      getNeighborhoodsUseCase: GetNeighborhoodsUseCase(repo),
      getAmenitiesUseCase: GetAmenitiesUseCase(repo),
      publishPropertyDraftUseCase: PublishPropertyDraftUseCase(repo),
      watchDraftStatusUseCase: WatchDraftStatusUseCase(repo),
    );

    vm.setPropertyType(const PropertyTypeModel(id: 'pt1', name: 'Casa'));
    vm.setNeighborhood(const NeighborhoodModel(
        id: 'n1', name: 'Centro', postalCode: '00000'));
    vm.setTitle('Casa de prueba');
    vm.setMainPhotoPath(photo.path);

    final statusLog = <String>[];
    vm.addListener(() => statusLog.add(vm.publishStatus.name));

    await vm.publish(
      mainPhotoPath: photo.path,
      spacePhotos: const {},
      videoPath: null,
    ).timeout(const Duration(seconds: 5));

    repo.log.add('publish:returned');
    final statusAtReturn = vm.publishStatus;

    // Deja terminar la fase B.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // publish debe retornar ANTES de que la subida termine, con status success.
    // ignore: avoid_print
    print('repo.log: ${repo.log}');
    // ignore: avoid_print
    print('statusLog: $statusLog | statusAtReturn: $statusAtReturn');

    expect(statusAtReturn, PublishStatus.success,
        reason: 'status al retornar publish(). log: ${repo.log}');
    expect(
      repo.log.indexOf('publish:returned'),
      lessThan(repo.log.indexOf('upload:done')),
      reason: 'publish() debe retornar antes de terminar la subida',
    );
  });
}
