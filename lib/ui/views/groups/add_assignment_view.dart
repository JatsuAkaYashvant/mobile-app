import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/cv_theme.dart';
import 'package:mobile_app/data/restriction_elements.dart';
import 'package:mobile_app/locator.dart';
import 'package:mobile_app/services/dialog_service.dart';
import 'package:mobile_app/ui/components/cv_html_editor.dart';
import 'package:mobile_app/ui/components/cv_primary_button.dart';
import 'package:mobile_app/ui/components/cv_text_field.dart';
import 'package:mobile_app/ui/views/base_view.dart';
import 'package:mobile_app/utils/snackbar_utils.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/groups/add_assignment_viewmodel.dart';

class AddAssignmentView extends StatefulWidget {
  const AddAssignmentView({super.key, required this.groupId});

  static const String id = 'add_assignment_view';
  final String groupId;

  @override
  _AddAssignmentViewState createState() => _AddAssignmentViewState();
}

class _AddAssignmentViewState extends State<AddAssignmentView> {
  final DialogService _dialogService = locator<DialogService>();
  late AddAssignmentViewModel _model;
  final _formKey = GlobalKey<FormState>();
  String _gradingScale = 'No Scale';
  late String _name;
  final QuillController _controller = QuillController.basic();
  late DateTime _deadline;
  final List<String> _restrictions = [];
  final List<String> _gradingOptions = [
    'No Scale',
    'Letter',
    'Percent',
    'Custom',
  ];
  bool _isRestrictionEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildNameInput() {
    return CVTextField(
      label: 'Name',
      validator:
          (name) => name?.isEmpty ?? true ? 'Please enter a valid name' : null,
      onSaved: (name) => _name = name!.trim(),
      action: TextInputAction.done,
    );
  }

  Widget _buildDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CVHtmlEditor(controller: _controller),
    );
  }

  Widget _buildDeadlineInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DateTimeField(
        key: const Key('cv_assignment_deadline_field'),
        format: DateFormat('yyyy-MM-dd HH:mm:ss'),
        initialValue: DateTime.now().add(const Duration(days: 7)),
        decoration: CVTheme.textFieldDecoration.copyWith(labelText: 'Deadline'),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 5),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 5),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                currentValue ?? DateTime.now(),
              ),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
        onSaved: (deadline) => _deadline = deadline!,
      ),
    );
  }

  Widget _buildGradingScaleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        key: const Key('cv_assignment_grading_dropdown'),
        decoration: CVTheme.textFieldDecoration.copyWith(
          labelText: 'Grading Scale',
        ),
        value: _gradingScale,
        onChanged: (String? value) {
          if (value == null) return;
          setState(() {
            _gradingScale = value;
          });
        },
        items:
            _gradingOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildRestrictionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CheckboxListTile(
        value: _isRestrictionEnabled,
        title: Text(
          'Elements restriction',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Enable elements restriction'),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _isRestrictionEnabled = value;
          });
        },
      ),
    );
  }

  Widget _buildCheckBox(String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          value: _restrictions.contains(name),
          onChanged: (value) {
            if (value == null) return;
            if (value) {
              _restrictions.add(name);
            } else {
              _restrictions.remove(name);
            }
            setState(() {});
          },
        ),
        Text(name),
      ],
    );
  }

  Widget _buildRestrictionComponent(String title, List<String> components) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Wrap(children: components.map((e) => _buildCheckBox(e)).toList()),
        ],
      ),
    );
  }

  Widget _buildRestrictions() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children:
            restrictionElements.entries
                .toList()
                .map<Widget>((e) => _buildRestrictionComponent(e.key, e.value))
                .toList(),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CVPrimaryButton(
        title: 'Create Assignment',
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    if (Validators.validateAndSaveForm(_formKey)) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Shows progress dialog..
      _dialogService.showCustomProgressDialog(title: 'Adding..');

      // [ISSUE] [html_editor] Throws error in Tests
      String _descriptionEditorText;
      try {
        _descriptionEditorText = _controller.document.toPlainText();
      } on NoSuchMethodError {
        debugPrint(
          'Handled html_editor error. NOTE: This should only throw during tests.',
        );
        _descriptionEditorText = '';
      }

      await _model.addAssignment(
        widget.groupId,
        _name,
        _deadline,
        _gradingScale,
        _descriptionEditorText,
        _restrictions,
      );

      _dialogService.popDialog();

      if (_model.isSuccess(_model.ADD_ASSIGNMENT)) {
        await Future.delayed(const Duration(seconds: 1));

        // returns the added assignment..
        Get.back(result: _model.addedAssignment);

        // Show success snackbar..
        SnackBarUtils.showDark(
          'Assignment Added',
          'New assignment was successfully added.',
        );
      } else if (_model.isError(_model.ADD_ASSIGNMENT)) {
        // Show failure snackbar
        SnackBarUtils.showDark(
          'Error',
          _model.errorMessageFor(_model.ADD_ASSIGNMENT),
        );
        _formKey.currentState?.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AddAssignmentViewModel>(
      onModelReady: (model) => _model = model,
      builder:
          (context, model, child) => Scaffold(
            appBar: AppBar(title: const Text('Add Assignment')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildNameInput(),
                    _buildDescriptionInput(),
                    _buildDeadlineInput(),
                    _buildGradingScaleDropdown(),
                    _buildRestrictionsHeader(),
                    if (_isRestrictionEnabled)
                      _buildRestrictions()
                    else
                      Container(),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
