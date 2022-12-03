import 'package:flutter/material.dart';
import 'package:sqflite_demo/db.dart';

import 'model.dart';

class CreateEntry extends StatefulWidget {
  final bool editMode;
  final Details detailsValues;

  const CreateEntry({
    Key? key,
    required this.editMode,
    required this.detailsValues,
  }) : super(key: key);

  @override
  State<CreateEntry> createState() => _CreateEntryState();
}

enum GenderEnum { other, male, female }

class _CreateEntryState extends State<CreateEntry> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final _ageList = List<int>.generate(100, (i) => i + 1);
  GenderEnum? _selectedGenderValue = GenderEnum.other;
  int _selectedAgeValue = 1;
  late Details _localObject;

  @override
  void initState() {
    super.initState();
    if (widget.editMode == true) {
      _firstNameController.text = widget.detailsValues.firstName;
      _lastNameController.text = widget.detailsValues.lastName;
      _selectedAgeValue = widget.detailsValues.age;
      _selectedGenderValue = covert(widget.detailsValues.gender);

      _localObject = Details(
        id: widget.detailsValues.id,
        firstName: widget.detailsValues.firstName,
        lastName: widget.detailsValues.lastName,
        gender: widget.detailsValues.gender,
        age: widget.detailsValues.age,
      );
    }
  }

  GenderEnum covert(String value) {
    switch (value) {
      case 'male':
        return GenderEnum.male;
      case 'female':
        return GenderEnum.female;
      default:
        return GenderEnum.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.editMode == true ? 'Update entry' : 'Create entry',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    commonTextFormField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        validationMessage: 'Please enter first name'),
                    const SizedBox(
                      height: 20,
                    ),
                    commonTextFormField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        validationMessage: 'Please enter last name'),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text('Age'),
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                          value: _selectedAgeValue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _ageList.map((int items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(
                                items.toString(),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedAgeValue = newValue ?? 1;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Gender'),
                    Column(
                      children: <Widget>[
                        commonRadioListTile(
                            title: 'Other', value: GenderEnum.other),
                        commonRadioListTile(
                            title: 'Male', value: GenderEnum.male),
                        commonRadioListTile(
                            title: 'Female', value: GenderEnum.female),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _localObject = Details(
                                firstName: _firstNameController.value.text,
                                lastName: _lastNameController.value.text,
                                gender: _selectedGenderValue
                                    .toString()
                                    .split('.')
                                    .last,
                                age: _selectedAgeValue,
                              );

                              if (widget.editMode == true) {
                                _editExistingDetail();
                              } else {
                                _createNewDetail();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.editMode == true
                                        ? 'Updated'
                                        : 'Created',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            widget.editMode == true ? 'Update' : 'Create',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget commonTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validationMessage,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) return validationMessage;
        return null;
      },
    );
  }

  Widget commonRadioListTile({
    required String title,
    required GenderEnum value,
  }) {
    return RadioListTile<GenderEnum>(
      title: Text(title),
      value: value,
      groupValue: _selectedGenderValue,
      onChanged: (GenderEnum? value) {
        setState(() {
          _selectedGenderValue = value;
        });
      },
    );
  }

  Future<void> _createNewDetail() async {
    final details = Details(
      firstName: _localObject.firstName,
      lastName: _localObject.lastName,
      gender: _localObject.gender,
      age: _localObject.age,
    );
    await DetailsDatabase.instance.create(details);
    return;
  }

  Future<void> _editExistingDetail() async {
    final details = widget.detailsValues.copy(
      firstName: _localObject.firstName,
      lastName: _localObject.lastName,
      gender: _localObject.gender,
      age: _localObject.age,
    );
    await DetailsDatabase.instance.update(details);
    return;
  }
}
