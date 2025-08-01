import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/cv_theme.dart';
import 'package:mobile_app/data/restriction_elements.dart';
import 'package:mobile_app/locator.dart';
import 'package:mobile_app/models/assignments.dart';
import 'package:mobile_app/services/dialog_service.dart';
import 'package:mobile_app/ui/components/cv_html_editor.dart';
import 'package:mobile_app/ui/components/cv_primary_button.dart';
import 'package:mobile_app/ui/components/cv_text_field.dart';
import 'package:mobile_app/ui/views/base_view.dart';
import 'package:mobile_app/utils/snackbar_utils.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/groups/update_assignment_viewmodel.dart';
import 'package:mobile_app/gen_l10n/app_localizations.dart';

class UpdateAssignmentView extends StatefulWidget {
  const UpdateAssignmentView({super.key, required this.assignment});

  static const String id = 'update_assignment_view';
  final Assignment assignment;

  @override
  _UpdateAssignmentViewState createState() => _UpdateAssignmentViewState();
}

class _UpdateAssignmentViewState extends State<UpdateAssignmentView> {
  final DialogService _dialogService = locator<DialogService>();
  late UpdateAssignmentViewModel _model;
  final _formKey = GlobalKey<FormState>();
  late String _name;
  final QuillController _controller = QuillController.basic();
  late DateTime _deadline;
  List _restrictions = [];
  bool _isRestrictionEnabled = false;

  @override
  void initState() {
    super.initState();
    _restrictions = json.decode(widget.assignment.attributes.restrictions);
    _isRestrictionEnabled = _restrictions.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildNameInput() {
    return CVTextField(
      initialValue: widget.assignment.attributes.name,
      label: AppLocalizations.of(context)!.update_assignment_name,
      validator:
          (name) =>
              name?.isEmpty ?? true
                  ? AppLocalizations.of(
                    context,
                  )!.update_assignment_name_validation_error
                  : null,
      onSaved: (name) => _name = name!.trim(),
    );
  }

  Widget _buildDescriptionInput() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.update_assignment_description,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CVHtmlEditor(controller: _controller),
        ],
      ),
    );
  }

  Widget _buildDeadlineInput() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: DateTimeField(
        key: const Key('cv_assignment_deadline_field'),
        format: DateFormat('yyyy-MM-dd HH:mm:ss'),
        initialValue: widget.assignment.attributes.deadline,
        decoration: CVTheme.textFieldDecoration.copyWith(
          labelText: AppLocalizations.of(context)!.update_assignment_deadline,
        ),
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

  Widget _buildRestrictionsHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 16.0),
      child: CheckboxListTile(
        value: _isRestrictionEnabled,
        title: Text(
          AppLocalizations.of(context)!.update_assignment_elements_restriction,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          AppLocalizations.of(
            context,
          )!.update_assignment_enable_elements_restriction,
        ),
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
      padding: const EdgeInsetsDirectional.all(8.0),
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
      padding: const EdgeInsetsDirectional.all(8),
      child: Column(
        children:
            restrictionElements.entries
                .toList()
                .map<Widget>((e) => _buildRestrictionComponent(e.key, e.value))
                .toList(),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: CVPrimaryButton(
        key: const Key('update_assignment_button'),
        title: AppLocalizations.of(context)!.update_assignment_title,
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    if (Validators.validateAndSaveForm(_formKey)) {
      FocusScope.of(context).requestFocus(FocusNode());

      _dialogService.showCustomProgressDialog(
        title: AppLocalizations.of(context)!.update_assignment_updating,
      );

      String _descriptionEditorText;
      try {
        _descriptionEditorText = _controller.document.toPlainText();
      } on NoSuchMethodError {
        debugPrint(
          'Handled html_editor error. NOTE: This should only throw during tests.',
        );
        _descriptionEditorText = '';
      }

      await _model.updateAssignment(
        widget.assignment.id,
        _name,
        _deadline,
        _descriptionEditorText,
        _restrictions,
      );

      _dialogService.popDialog();

      if (_model.isSuccess(_model.UPDATE_ASSIGNMENT)) {
        await Future.delayed(const Duration(seconds: 1));
        Get.back(result: _model.updatedAssignment);
        SnackBarUtils.showDark(
          AppLocalizations.of(context)!.update_assignment_updated,
          AppLocalizations.of(context)!.update_assignment_update_success,
        );
      } else if (_model.isError(_model.UPDATE_ASSIGNMENT)) {
        SnackBarUtils.showDark(
          AppLocalizations.of(context)!.update_assignment_error,
          _model.errorMessageFor(_model.UPDATE_ASSIGNMENT),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<UpdateAssignmentViewModel>(
      onModelReady: (model) => _model = model,
      builder:
          (context, model, child) => Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.update_assignment_title,
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildNameInput(),
                    _buildDescriptionInput(),
                    _buildDeadlineInput(),
                    _buildRestrictionsHeader(),
                    if (_isRestrictionEnabled)
                      _buildRestrictions()
                    else
                      Container(),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
