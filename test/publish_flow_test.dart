import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/repositories/lessor_repository.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/watch_draft_status_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/review_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 120));
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

// PNG válido de 1x1 para que Image.file no truene el decode.
final Uint8List kPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('Publicar navega a home tras la respuesta del POST',
      (tester) async {
    final dir = Directory.systemTemp.createTempSync('publish_test');
    final photo = File('${dir.path}/main.png')..writeAsBytesSync(kPng);

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
    vm.setStreet('Calle 1');
    vm.setExteriorNumber('10');
    vm.setTitle('Casa de prueba');
    vm.setDescription('Descripción');
    vm.setPrice('10000');
    vm.setArea('120');
    vm.setRooms(2);
    vm.setBathrooms(1);
    vm.setParkingSpots(1);
    vm.setMainPhotoPath(photo.path);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('go'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReviewPropertyPage()),
                  ),
                  child: const Text('HOME_STUB'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('go')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 6 && !tester.any(find.text('Publicar')); i++) {
      await tester.drag(
          find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Publicar'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Publicar'), findsOneWidget);
    debugPrint('>>> review page visible');

    // Toda la interacción bajo runAsync para que el IO real (lectura del
    // archivo) y los delays de los fakes corran de verdad.
    await tester.runAsync(() async {
      await tester.tap(find.text('Publicar'));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    debugPrint('>>> after publish wait: status=${vm.publishStatus} '
        'log=${repo.log}');

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 5)); // snackbar timers

    final onHome = find.text('HOME_STUB');
    debugPrint('>>> HOME_STUB found: ${tester.any(onHome)}; '
        'Publicar still visible: ${tester.any(find.text('Publicar'))}');

    expect(repo.log, contains('createDraft:done'));
    expect(onHome, findsOneWidget,
        reason: 'Debió regresar a home. Log: ${repo.log}');
  });
}
