import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/enums/view_state.dart';
import 'package:mobile_app/models/cv_contributors.dart';
import 'package:mobile_app/ui/components/cv_header.dart';
import 'package:mobile_app/ui/components/cv_primary_button.dart';
import 'package:mobile_app/ui/components/cv_social_card.dart';
import 'package:mobile_app/ui/components/cv_subheader.dart';
import 'package:mobile_app/ui/views/about/about_privacy_policy_view.dart';
import 'package:mobile_app/ui/views/about/about_tos_view.dart';
import 'package:mobile_app/ui/views/about/components/contributor_avatar.dart';
import 'package:mobile_app/ui/views/base_view.dart';
import 'package:mobile_app/viewmodels/about/about_viewmodel.dart';
import 'package:mobile_app/gen_l10n/app_localizations.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});
  static const String id = 'about_view';

  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  late AboutViewModel _model;

  Widget _buildTosAndPrivacyButtons() {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              child: CVPrimaryButton.small(
                title: AppLocalizations.of(context)!.terms_of_service,
                onPressed: () => Get.toNamed(AboutTosView.id),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              child: CVPrimaryButton.small(
                title: AppLocalizations.of(context)!.privacy_policy,
                onPressed: () => Get.toNamed(AboutPrivacyPolicyView.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsList() {
    switch (_model.stateFor(_model.FETCH_CONTRIBUTORS)) {
      case ViewState.Success:
        var _contributorsAvatars = <Widget>[];
        for (var contributor in _model.cvContributors) {
          if (contributor.type == Type.USER) {
            _contributorsAvatars.add(
              ContributorAvatar(contributor: contributor),
            );
          }
        }
        return Wrap(
          alignment: WrapAlignment.center,
          children: _contributorsAvatars,
        );
      case ViewState.Busy:
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 32),
          child: Text(
            AppLocalizations.of(context)!.loading_contributors,
            textAlign: TextAlign.center,
          ),
        );
      case ViewState.Error:
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 32),
          child: Text(
            _model.errorMessageFor(_model.FETCH_CONTRIBUTORS),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AboutViewModel>(
      onModelReady: (model) {
        _model = model;
        _model.fetchContributors();
      },
      builder:
          (context, model, child) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                children: <Widget>[
                  CVHeader(
                    title: AppLocalizations.of(context)!.about_title,
                    subtitle: AppLocalizations.of(context)?.about_subtitle,
                    description:
                        AppLocalizations.of(context)?.about_description,
                  ),
                  _buildTosAndPrivacyButtons(),
                  CircuitVerseSocialCard(
                    imagePath: 'assets/images/contribute/email.png',
                    title: AppLocalizations.of(context)!.email_us_at,
                    description: 'support@circuitverse.org',
                    url: 'mailto:support@circuitverse.org',
                  ),
                  CircuitVerseSocialCard(
                    imagePath: 'assets/images/contribute/slack.png',
                    title: AppLocalizations.of(context)!.join_slack,
                    description:
                        AppLocalizations.of(context)!.about_slack_channel,
                    url: 'https://circuitverse.org/slack',
                  ),
                  const Divider(),
                  CVSubheader(
                    title: AppLocalizations.of(context)!.contributors,
                    subtitle:
                        AppLocalizations.of(context)?.contributors_subtitle,
                  ),
                  _buildContributorsList(),
                ],
              ),
            ),
          ),
    );
  }
}
