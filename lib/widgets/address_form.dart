import 'package:flutter/material.dart';

class AddressForm extends StatefulWidget {
  final TextEditingController? controller;
  final bool isEditable;
  final Function(String)? onChanged;
  final String? initialValue;
  final String? label;
  final String? hint;
  final int? maxLines;
  final bool isRequired;

  const AddressForm({
    Key? key,
    this.controller,
    this.isEditable = true,
    this.onChanged,
    this.initialValue,
    this.label,
    this.hint,
    this.maxLines = 4,
    this.isRequired = true,
  }) : super(key: key);

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  late TextEditingController _controller;
  bool _isValid = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(covariant AddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if it was created in this widget
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  String? _validateAddress(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'Please enter your address';
    }
    if (value != null && value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.isEditable,
      maxLines: widget.maxLines,
      minLines: 3,
      decoration: InputDecoration(
        labelText: widget.label ?? 'Shipping Address',
        hintText: widget.hint ?? 'Enter your complete shipping address',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.location_on_outlined),
        errorText: _errorText,
        errorMaxLines: 2,
        suffixIcon: widget.isEditable
            ? IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  // TODO: Implement get current location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location feature coming soon!'),
                    ),
                  );
                },
              )
            : null,
      ),
      validator: widget.isRequired
          ? (value) {
              final error = _validateAddress(value);
              setState(() => _errorText = error);
              return error;
            }
          : null,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        if (_errorText != null) {
          setState(() => _errorText = _validateAddress(value));
        }
      },
    );
  }
}
