import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/property_details_page.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_dropdown_field.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_text_field.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_type_toggle.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  PropertyListingType _listingType = PropertyListingType.venta;
  HomeNavItem _selectedNav = HomeNavItem.add;

  final _postalCodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedCity;
  String? _selectedState;
  String? _selectedColonia;
  String? _selectedPropertyType;

  final List<String> _cities = [
    'Tuxtla Gutiérrez',
    'San Cristóbal',
    'Tapachula',
    'Comitán',
  ];
  final List<String> _states = [
    'Chiapas',
    'CDMX',
    'Jalisco',
    'Nuevo León',
  ];
  final List<String> _colonias = [
    'Centro',
    'Las Flores',
    'El Bosque',
    'Vista Hermosa',
  ];
  final List<String> _propertyTypes = [
    'Pisos y departamentos',
    'Casa',
    'Terreno',
    'Local comercial',
    'Oficina',
  ];

  @override
  void dispose() {
    _postalCodeController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  String get _priceLabel => _listingType == PropertyListingType.venta
      ? 'Precio Total'
      : 'Precio De Renta Mensual';

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final form = NewPropertyForm(
        listingType: _listingType.name,
        postalCode: _postalCodeController.text,
        city: _selectedCity,
        state: _selectedState,
        colonia: _selectedColonia,
        propertyType: _selectedPropertyType,
        price: _priceController.text,
        area: _areaController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailsPage(form: form),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: (item) => setState(() => _selectedNav = item),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 32 : 20,
            20,
            isLandscape ? 32 : 20,
            32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar Una Propiedad',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                PropertyTypeToggle(
                  selected: _listingType,
                  onChanged: (t) => setState(() => _listingType = t),
                ),
                const SizedBox(height: 28),

                FormSectionHeader(
                  label: 'Ubicación',
                  iconData: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),

                PropertyTextField(
                  controller: _postalCodeController,
                  hint: 'Escriba el código postal',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _DropdownWrapper(
                        child: PropertyDropdownField<String>(
                          value: _selectedCity,
                          hint: 'Ciudad',
                          items: _cities
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCity = v),
                          validator: (v) =>
                          v == null ? 'Requerido' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DropdownWrapper(
                        child: PropertyDropdownField<String>(
                          value: _selectedState,
                          hint: 'Estado',
                          items: _states
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedState = v),
                          validator: (v) =>
                          v == null ? 'Requerido' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FormSectionHeader(
                  label: 'Nombre De La Colonia',
                  iconData: Icons.home_outlined,
                ),
                const SizedBox(height: 12),

                _DropdownWrapper(
                  child: PropertyDropdownField<String>(
                    value: _selectedColonia,
                    hint: 'Elija la colonia',
                    items: _colonias
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedColonia = v),
                    validator: (v) =>
                    v == null ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(height: 24),

                FormSectionHeader(
                  label: 'Tipo De Propiedad',
                  iconData: Icons.home_outlined,
                ),
                const SizedBox(height: 12),

                _DropdownWrapper(
                  child: PropertyDropdownField<String>(
                    value: _selectedPropertyType,
                    hint: 'Pisos y departamentos',
                    items: _propertyTypes
                        .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPropertyType = v),
                    validator: (v) =>
                    v == null ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(height: 24),

                FormSectionHeader(
                  label: _priceLabel,
                  iconData: Icons.sell_outlined,
                ),
                const SizedBox(height: 12),

                PropertyTextField(
                  controller: _priceController,
                  hint: 'Escriba el precio',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 24),

                FormSectionHeader(
                  label: 'Area Del Terreno',
                  iconData: Icons.crop_square_outlined,
                ),
                const SizedBox(height: 12),

                PropertyTextField(
                  controller: _areaController,
                  hint: 'Escriba el área en m2',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0095FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Siguiente: Detalles De La Propiedad',
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
      ),
    );
  }
}

class _DropdownWrapper extends StatelessWidget {
  final Widget child;

  const _DropdownWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      child: child,
    );
  }
}