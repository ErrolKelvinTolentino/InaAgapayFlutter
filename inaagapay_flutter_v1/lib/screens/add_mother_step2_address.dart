import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep2Address extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep2Address({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep2Address> createState() => _AddMotherStep2AddressState();
}

class _AddMotherStep2AddressState extends State<AddMotherStep2Address> {
  late bool _sameAsAssigned;

  @override
  void initState() {
    super.initState();
    _sameAsAssigned = widget.form.isAddressSameAsAssignedBhc;
    if (_sameAsAssigned) {
      _applyAssignedDefaults();
    }
  }

  void _applyAssignedDefaults() {
    // Hard-coded defaults per requirements when using assigned BHC.
    widget.form.province = 'Bulacan';
    widget.form.cityMunicipality = 'Baliwag';
    widget.form.barangay = widget.form.assignedBhcName;
  }

  Widget _addressFields() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Province'),
          initialValue: widget.form.province,
          onChanged: (v) => widget.form.province = v,
          readOnly: _sameAsAssigned,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'City / Municipality'),
          initialValue: widget.form.cityMunicipality,
          onChanged: (v) => widget.form.cityMunicipality = v,
          readOnly: _sameAsAssigned,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Barangay'),
          initialValue: widget.form.barangay,
          onChanged: (v) => widget.form.barangay = v,
          readOnly: _sameAsAssigned,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Barangay Health Center: ${widget.form.assignedBhcName ?? 'Set via midwife profile'}',
        ),
        const SizedBox(height: 8),
        RadioListTile<bool>(
          value: true,
          groupValue: _sameAsAssigned,
          onChanged: (v) {
            setState(() {
              _sameAsAssigned = true;
              widget.form.isAddressSameAsAssignedBhc = true;
              _applyAssignedDefaults();
            });
          },
          title: const Text('Option 1: Same as assigned BHC'),
        ),
        RadioListTile<bool>(
          value: false,
          groupValue: _sameAsAssigned,
          onChanged: (v) {
            setState(() {
              _sameAsAssigned = false;
              widget.form.isAddressSameAsAssignedBhc = false;
            });
          },
          title: const Text('Option 2: Custom address'),
          subtitle: const Text('Manual entry until PH places API is available'),
        ),

        _addressFields(),

        TextField(
          decoration: const InputDecoration(labelText: 'Street'),
          onChanged: (v) => widget.form.street = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'House Number'),
          onChanged: (v) => widget.form.houseNumber = v,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
            ElevatedButton(onPressed: widget.onNext, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
