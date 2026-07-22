import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/property_photos_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/review_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/number_selector.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_text_field.dart';
import 'package:vivia_mobile/shared/widgets/amenity_icon.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';

const _kAiFrom = Color(0xFF62E8EC); // cyan claro — inicio del degradado Premium
const _kAiTo   = Color(0xFF26C6DA); // cyan oscuro — fin del degradado Premium

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  final List<String> _roomOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11+',
  ];
  final List<String> _bathroomOptions = ['1', '2', '3', '4', '5', '6', '7+'];
  // Los cajones de estacionamiento pueden ser 0.
  final List<String> _parkingOptions = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7+',
  ];

  final List<int> _yearOptions = List.generate(
    DateTime.now().year - 1950 + 1,
    (i) => DateTime.now().year - i,
  );

  AiGenerationStatus? _lastAiStatus;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    final vm = context.read<PropertyDraftViewModel>();
    _titleController = TextEditingController(text: vm.form.title ?? '');
    _descriptionController = TextEditingController(
      text: vm.form.description ?? '',
    );
    // Año de construcción por defecto: 2000 cuando aún no se ha seleccionado.
    if (vm.form.constructionYear == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && vm.form.constructionYear == null) {
          vm.setConstructionYear(2000);
        }
      });
    }
    vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    final vm = context.read<PropertyDraftViewModel>();
    final current = vm.aiStatus;

    if (current == AiGenerationStatus.loading) {
      if (!_shimmerController.isAnimating) _shimmerController.repeat();
      // Mostrar datos de stream directamente en los campos
      if (vm.aiStreamTitle.isNotEmpty) {
        _titleController.text = vm.aiStreamTitle;
      }
      if (vm.aiStreamDescription.isNotEmpty) {
        _descriptionController.text = vm.aiStreamDescription;
      }
    } else {
      if (_shimmerController.isAnimating) _shimmerController.stop();
      if (_lastAiStatus == AiGenerationStatus.loading &&
          current == AiGenerationStatus.idle) {
        // Rollback: if form fields came back empty, restore from the last
        // saved generation to avoid a second API call.
        final title = vm.form.title?.isNotEmpty == true
            ? vm.form.title!
            : (vm.aiLastTitle ?? '');
        final desc = vm.form.description?.isNotEmpty == true
            ? vm.form.description!
            : (vm.aiLastDescription ?? '');
        _titleController.text = title;
        _descriptionController.text = desc;
        if (vm.form.title?.isEmpty ?? true) vm.setTitle(title);
        if (vm.form.description?.isEmpty ?? true) vm.setDescription(desc);
      }
    }
    _lastAiStatus = current;
  }

  @override
  void dispose() {
    context.read<PropertyDraftViewModel>().removeListener(_onVmChanged);
    _shimmerController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Envuelve [child] con un borde degradado animado cuando [active] es true.
  // Usa el [_shimmerController] que ya corre en el state para no crear
  // animaciones adicionales.
  Widget _maybeAiGlow({required bool active, required Widget child}) {
    if (!active) return child;
    return AnimatedBuilder(
      animation: _shimmerController,
      // El hijo no depende de la animación, así Flutter no lo reconstruye.
      child: child,
      builder: (_, inner) {
        // t va de -0.3 a 1.3 para que el brillo entre y salga limpiamente.
        final t = -0.3 + 1.6 * _shimmerController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.5),
            gradient: LinearGradient(
              colors: const [_kAiTo, _kAiFrom, _kAiTo],
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: inner,
        );
      },
    );
  }

  void _onNext(PropertyDraftViewModel vm) {
    if (_formKey.currentState!.validate()) {
      if (vm.form.rooms == null) {
        _showSnack('Selecciona el número de habitaciones');
        return;
      }
      if (vm.form.bathrooms == null) {
        _showSnack('Selecciona el número de baños');
        return;
      }
      if (vm.form.parkingSpots == null) {
        _showSnack('Selecciona los espacios de estacionamiento');
        return;
      }
      switch (vm.mode) {
        case PropertyFormMode.create:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PropertyPhotosPage()),
          );
        case PropertyFormMode.editPreview:
          // Fin del modo edición de vista previa: las páginas de fotos se
          // saltan y se regresa a la review, que lee el draft actualizado.
          Navigator.of(context).popUntil(
            ModalRoute.withName(ReviewPropertyPage.routeName),
          );
        case PropertyFormMode.editPublished:
          _confirmAndSave(vm);
      }
    }
  }

  String _nextButtonLabel(PropertyFormMode mode) => switch (mode) {
        PropertyFormMode.create => 'Siguiente: Fotografías De La Propiedad',
        PropertyFormMode.editPreview => 'Guardar Y Volver A La Vista Previa',
        PropertyFormMode.editPublished => 'Guardar Cambios',
      };

  Future<void> _confirmAndSave(PropertyDraftViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar cambios'),
        content: const Text(
          'Se actualizará la información visible de tu publicación. '
          'Las fotografías y el video no se modifican desde aquí; '
          'puedes editarlos desde la galería de la publicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final saved = await vm.saveEdits();
    if (!mounted) return;

    if (saved) {
      AppAlert.success(
        context,
        'Los cambios se guardaron correctamente.',
        title: 'Propiedad actualizada',
      );
      Navigator.of(context)
        ..pop()
        ..pop();
      vm.reset();
    } else {
      AppAlert.error(
        context,
        'No se pudieron guardar los cambios. Intenta de nuevo.',
      );
    }
  }

  void _showSnack(String message) {
    AppAlert.show(context, message: message, type: AppAlertType.warning);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<PropertyDraftViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Detalles De La Propiedad',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isLandscape ? 32 : 20,
              16,
              isLandscape ? 32 : 20,
              32,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionHeader(
                    label: 'Habitaciones',
                    iconData: Icons.bed_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // rooms stores actual count (1-11); selector needs index (0-10)
                    selected: vm.form.rooms != null
                        ? (vm.form.rooms! - 1).clamp(0, 10)
                        : null,
                    options: _roomOptions,
                    onSelected: (i) => vm.setRooms(i < 10 ? i + 1 : 11),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Baños',
                    iconData: Icons.bathtub_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // bathrooms stores actual count (1-7); selector needs index (0-6)
                    selected: vm.form.bathrooms != null
                        ? (vm.form.bathrooms! - 1).clamp(0, 6)
                        : null,
                    options: _bathroomOptions,
                    onSelected: (i) => vm.setBathrooms(i < 6 ? i + 1 : 7),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Espacios De Estacionamiento',
                    iconData: Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // parkingSpots stores actual count (0-7); index maps 1:1.
                    selected: vm.form.parkingSpots != null
                        ? vm.form.parkingSpots!.clamp(0, 7)
                        : null,
                    options: _parkingOptions,
                    onSelected: (i) => vm.setParkingSpots(i < 7 ? i : 7),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Año De Construcción (Opcional)',
                    iconData: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 12),
                  _YearDropdown(
                    years: _yearOptions,
                    selected: vm.form.constructionYear,
                    onChanged: vm.setConstructionYear,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 20),

                  _CondominiumRow(
                    value: vm.form.isCondominium,
                    onChanged: vm.setIsCondominium,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Amenidades',
                    iconData: Icons.star_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _AmenitiesSection(vm: vm),
                  const SizedBox(height: 32),

                  _AiGenerateSection(vm: vm),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Título Breve',
                    iconData: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 12),
                  _maybeAiGlow(
                    active: vm.aiStatus == AiGenerationStatus.loading,
                    child: PropertyTextField(
                      controller: _titleController,
                      hint: 'Añade un título breve...',
                      readOnly: vm.aiStatus == AiGenerationStatus.loading,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      onChanged: vm.setTitle,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        if (v.trim().length < 10) {
                          return 'El título debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Descripción De La Propiedad',
                    iconData: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 12),
                  _maybeAiGlow(
                    active: vm.aiStatus == AiGenerationStatus.loading,
                    child: _DescriptionField(
                      controller: _descriptionController,
                      readOnly: vm.aiStatus == AiGenerationStatus.loading,
                      onChanged: vm.setDescription,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: vm.saveStatus == PublishStatus.loading
                          ? null
                          : () => _onNext(vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0x800095FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: vm.saveStatus == PublishStatus.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _nextButtonLabel(vm.mode),
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AiGenerateSection extends StatefulWidget {
  final PropertyDraftViewModel vm;
  const _AiGenerateSection({required this.vm});

  @override
  State<_AiGenerateSection> createState() => _AiGenerateSectionState();
}

class _AiGenerateSectionState extends State<_AiGenerateSection> {
  static const _phrases = [
    'Pensando...',
    'Componiendo...',
    'Ya lo tengo...',
    'Solo un poco más...',
  ];
  int _phraseIndex = 0;
  Timer? _timer;

  @override
  void didUpdateWidget(_AiGenerateSection old) {
    super.didUpdateWidget(old);
    if (widget.vm.aiStatus == AiGenerationStatus.loading && _timer == null) {
      _startTimer();
    } else if (widget.vm.aiStatus != AiGenerationStatus.loading) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _phraseIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _phraseIndex = (_phraseIndex + 1) % _phrases.length;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _phraseIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vm = widget.vm;

    return switch (vm.aiStatus) {
      AiGenerationStatus.loading => _buildLoadingCard(
          colorScheme,
          textTheme,
          vm,
        ),
      AiGenerationStatus.error => _buildErrorCard(
          context,
          colorScheme,
          textTheme,
          vm,
        ),
      AiGenerationStatus.subscriptionCheckFailed => _buildSubscriptionCheckFailedCard(
          context,
          colorScheme,
          textTheme,
          vm,
        ),
      AiGenerationStatus.premiumRequired => _buildPremiumCard(
          context,
          textTheme,
          vm,
        ),
      AiGenerationStatus.idle => _buildIdleButton(
          context,
          colorScheme,
          textTheme,
          vm,
        ),
    };
  }

  Widget _buildIdleButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    PropertyDraftViewModel vm,
  ) {
    final canGenerate = vm.canGenerateAiContent;
    final isLimited = vm.isAiRateLimited;
    final enabled = canGenerate && !isLimited;
    const gradient = LinearGradient(
      colors: [_kAiFrom, _kAiTo],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: enabled ? () => vm.generateAiContent() : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1.0 : 0.45,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: enabled ? gradient : null,
                color: enabled ? null : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: enabled ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Generar con IA',
                    style: textTheme.labelLarge?.copyWith(
                      color: enabled ? Colors.white : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLimited)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Límite de 3 generaciones por 5 min alcanzado. Intenta de nuevo en un momento.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    PropertyDraftViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kAiTo.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAiTo.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _kAiTo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _phrases[_phraseIndex],
                key: ValueKey(_phraseIndex),
                style: textTheme.labelMedium?.copyWith(
                  color: _kAiTo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: vm.cancelAiGeneration,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    PropertyDraftViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.aiError ?? 'Error al generar',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => vm.cancelAiGeneration(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: vm.canGenerateAiContent
                    ? () => vm.generateAiContent()
                    : null,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: _kAiTo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: textTheme.labelMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCheckFailedCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    PropertyDraftViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No pudimos verificar tu suscripción',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Revisa tu conexión e intenta de nuevo.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => vm.cancelAiGeneration(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: vm.canGenerateAiContent
                    ? () => vm.generateAiContent()
                    : null,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: textTheme.labelMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    TextTheme textTheme,
    PropertyDraftViewModel vm,
  ) {
    const gradient = LinearGradient(
      colors: [_kAiFrom, _kAiTo],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kAiTo.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Función exclusiva Premium',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Genera título y descripción con IA en segundos. Actualiza tu plan para desbloquear esta y más funciones.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.88),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _kAiTo,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ver planes Premium'),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => vm.cancelAiGeneration(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.80),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: textTheme.labelMedium,
                  ),
                  child: const Text('Ahora no'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const _DescriptionField({
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null,
      minLines: 4,
      maxLength: 200,
      onChanged: onChanged,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        if (v.trim().length < 20) {
          return 'La descripción debe tener al menos 20 caracteres';
        }
        return null;
      },
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Añade una descripción...',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.55),
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0095FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}

class _YearDropdown extends StatelessWidget {
  final List<int> years;
  final int? selected;
  final ValueChanged<int?> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _YearDropdown({
    required this.years,
    required this.selected,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selected,
      isExpanded: true,
      isDense: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Selecciona el año (opcional)',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.55),
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0095FF), width: 1.5),
        ),
      ),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            'Sin especificar',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ),
        ...years.map(
          (y) => DropdownMenuItem<int>(value: y, child: Text(y.toString())),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CondominiumRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _CondominiumRow({
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '¿Es condominio?',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Checkbox(
            value: value,
            activeColor: const Color(0xFF0095FF),
            onChanged: (v) => onChanged(v ?? false),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  final PropertyDraftViewModel vm;

  const _AmenitiesSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vm.amenitiesStatus == AmenitiesStatus.loading) {
      return Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    if (vm.amenitiesStatus == AmenitiesStatus.error) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'No se pudieron cargar las amenidades',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (vm.amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: vm.amenities.map((amenity) {
          final isSelected = vm.form.amenityIds.contains(amenity.id);
          return CheckboxListTile(
            value: isSelected,
            onChanged: (_) => vm.toggleAmenity(amenity.id),
            secondary: Icon(
              amenityIcon(amenity.name),
              size: 22,
              color: isSelected
                  ? const Color(0xFF0095FF)
                  : colorScheme.onSurfaceVariant,
            ),
            title: Text(
              amenity.name,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            activeColor: const Color(0xFF0095FF),
            controlAffinity: ListTileControlAffinity.trailing,
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }
}
