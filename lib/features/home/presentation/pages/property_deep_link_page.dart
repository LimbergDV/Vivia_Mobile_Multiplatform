import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/home/presentation/pages/property_detail_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_by_id_usecase.dart';

/// Pantalla puente para los deep links `vivia://property/{id}`.
///
/// Carga la propiedad por id y abre su detalle sin importar el rol del usuario.
/// Si falla (id inexistente, sin sesión o error de red) muestra un aviso en
/// lugar del detalle.
class PropertyDeepLinkPage extends StatefulWidget {
  final String propertyId;

  const PropertyDeepLinkPage({super.key, required this.propertyId});

  @override
  State<PropertyDeepLinkPage> createState() => _PropertyDeepLinkPageState();
}

class _PropertyDeepLinkPageState extends State<PropertyDeepLinkPage> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    try {
      final detail = await context
          .read<GetPropertyByIdUseCase>()
          .execute(widget.propertyId);
      if (!mounted) return;
      final isLessor = context.read<PropertyViewModel>().isLessor;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PropertyDetailPage(
            property: _toModel(detail),
            role: isLessor ? UserRole.lessor : UserRole.lessee,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  PropertyModel _toModel(PropertyDetail d) => PropertyModel(
        id: d.id,
        title: d.title,
        type: d.propertyType.name,
        price: d.listedPrice,
        location: d.address.formatted,
        area: d.areaM2,
        bedrooms: d.bedrooms,
        bathrooms: d.bathrooms,
        imageUrl: d.imageUrls.isNotEmpty ? d.imageUrls.first : '',
        isFavorite: d.like ?? false,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: _failed
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_off,
                        size: 56, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No pudimos abrir esta propiedad. Puede que ya no esté '
                      'disponible o que necesites iniciar sesión.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
