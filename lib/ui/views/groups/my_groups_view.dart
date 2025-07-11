import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mobile_app/cv_theme.dart';
import 'package:mobile_app/locator.dart';
import 'package:mobile_app/models/groups.dart';
import 'package:mobile_app/services/dialog_service.dart';
import 'package:mobile_app/ui/components/cv_add_icon_button.dart';
import 'package:mobile_app/ui/views/base_view.dart';
import 'package:mobile_app/ui/views/groups/components/group_member_card.dart';
import 'package:mobile_app/ui/views/groups/components/group_mentor_card.dart';
import 'package:mobile_app/ui/views/groups/edit_group_view.dart';
import 'package:mobile_app/ui/views/groups/new_group_view.dart';
import 'package:mobile_app/utils/snackbar_utils.dart';
import 'package:mobile_app/viewmodels/groups/my_groups_viewmodel.dart';
import 'package:mobile_app/gen_l10n/app_localizations.dart';

class MyGroupsView extends StatefulWidget {
  const MyGroupsView({super.key});

  static const String id = 'my_groups_view';

  @override
  _MyGroupsViewState createState() => _MyGroupsViewState();
}

class _MyGroupsViewState extends State<MyGroupsView>
    with SingleTickerProviderStateMixin {
  final DialogService _dialogService = locator<DialogService>();
  late MyGroupsViewModel _model;
  late TabController _tabController;

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset('assets/images/group/no_group.svg', height: 250),
        _buildSubHeader(
          title: AppLocalizations.of(context)!.my_groups_explore_message,
        ),
      ],
    );
  }

  Widget _buildSubHeader({required String title}) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16.0,
        vertical: 48.0,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Future<void> onCreateGroupPressed() async {
    var _result = await Get.toNamed(NewGroupView.id);

    if (_result is Group) _model.onGroupCreated(_result);
  }

  Future<void> onEditGroupPressed(Group group) async {
    var _result = await Get.toNamed(EditGroupView.id, arguments: group);

    if (_result is Group) _model.onGroupUpdated(_result);
  }

  Future<void> onDeleteGroupPressed(String groupId) async {
    var _dialogResponse = await _dialogService.showConfirmationDialog(
      title: AppLocalizations.of(context)!.my_groups_delete_group,
      description:
          AppLocalizations.of(context)!.my_groups_delete_group_confirmation,
      confirmationTitle:
          AppLocalizations.of(context)!.my_groups_delete.toUpperCase(),
    );

    if (_dialogResponse?.confirmed ?? false) {
      _dialogService.showCustomProgressDialog(
        title: AppLocalizations.of(context)!.my_groups_deleting_group,
      );

      await _model.deleteGroup(groupId);

      _dialogService.popDialog();

      if (_model.isSuccess(_model.DELETE_GROUP)) {
        SnackBarUtils.showDark(
          AppLocalizations.of(context)!.my_groups_group_deleted,
          AppLocalizations.of(context)!.my_groups_group_deleted_success,
        );
      } else if (_model.isError(_model.DELETE_GROUP)) {
        SnackBarUtils.showDark(
          AppLocalizations.of(context)!.my_groups_error,
          _model.errorMessageFor(_model.DELETE_GROUP),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MyGroupsViewModel>(
      onModelReady: (model) {
        _model = model;
        _model.fetchMentoredGroups();
        _model.fetchMemberGroups();
        _tabController = TabController(length: 2, vsync: this);
      },
      builder:
          (context, model, child) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: onCreateGroupPressed,
              backgroundColor: CVTheme.primaryColor,
              child: const Icon(Icons.add),
            ),
            appBar: AppBar(
              title: TabBar(
                controller: _tabController,
                labelColor: CVTheme.textColor(context),
                indicatorColor: CVTheme.primaryColor,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.my_groups_owned),
                  Tab(text: AppLocalizations.of(context)!.my_groups_joined),
                ],
              ),
            ),
            body: Builder(
              builder: (context) {
                var _ownedGroups = <Widget>[];
                var _joinedGroups = <Widget>[];

                if (_model.isSuccess(_model.FETCH_OWNED_GROUPS)) {
                  for (var group in _model.ownedGroups) {
                    _ownedGroups.add(
                      GroupMentorCard(
                        group: group,
                        onEdit: () => onEditGroupPressed(group),
                        onDelete: () => onDeleteGroupPressed(group.id),
                      ),
                    );
                  }
                  if (_model.previousMentoredGroupsBatch?.links.next != null) {
                    _ownedGroups.add(
                      CVAddIconButton(onPressed: _model.fetchMentoredGroups),
                    );
                  }
                }
                if (_model.isSuccess(_model.FETCH_MEMBER_GROUPS)) {
                  for (var group in _model.memberGroups) {
                    _joinedGroups.add(GroupMemberCard(group: group));
                  }

                  if (_model.previousMemberGroupsBatch?.links.next != null) {
                    _joinedGroups.add(
                      CVAddIconButton(onPressed: _model.fetchMemberGroups),
                    );
                  }
                }

                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _ownedGroups.isEmpty
                        ? _emptyState()
                        : ListView(children: _ownedGroups),
                    _joinedGroups.isEmpty
                        ? _emptyState()
                        : ListView(children: _joinedGroups),
                  ],
                );
              },
            ),
          ),
    );
  }
}
