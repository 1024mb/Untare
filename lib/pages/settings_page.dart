import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tare/blocs/authentication/authentication_bloc.dart';
import 'package:tare/blocs/authentication/authentication_event.dart';
import 'package:tare/components/bottom_sheets/settings_default_page_bottom_sheet_component.dart';
import 'package:tare/components/bottom_sheets/settings_layout_bottom_sheet_component.dart';
import 'package:tare/components/dialogs/edit_share_dialog.dart';
import 'package:tare/components/dialogs/edit_shopping_list_recent_days_dialog.dart';
import 'package:tare/components/dialogs/edit_shopping_list_refresh_dialog.dart';
import 'package:tare/cubits/settings_cubit.dart';
import 'package:tare/extensions/string_extension.dart';
import 'package:tare/models/app_setting.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().initServerSetting();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    SettingsCubit _settingsCubit = context.read<SettingsCubit>();
    bool? themeModeSwitch = (_settingsCubit.state.theme == 'dark');

    return Scaffold(
      body:  NestedScrollView(
          headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 90,
                leadingWidth: 0,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
                  expandedTitleScale: 1.3,
                  title: Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).appBarTheme.titleTextStyle != null) ? Theme.of(context).appBarTheme.titleTextStyle!.color : null
                    ),
                  ),
                ),
                elevation: 1.5,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                pinned: true,
              )
            ];
          },
          body: BlocBuilder<SettingsCubit, AppSetting>(
              builder: (context, setting) {
                String defaultPageLayout = setting.defaultPage.capitalize();
                if (setting.defaultPage == 'recipes') {
                  defaultPageLayout = AppLocalizations.of(context)!.recipesTitle;
                } else if (setting.defaultPage == 'plan') {
                  defaultPageLayout = AppLocalizations.of(context)!.mealPlanTitle;
                } else if (setting.defaultPage == 'shopping') {
                  defaultPageLayout = AppLocalizations.of(context)!.shoppingListTitle;
                }

                return SettingsList(
                  sections: [
                    SettingsSection(
                        title: Text(AppLocalizations.of(context)!.settingsCustomization),
                        tiles: [
                          SettingsTile.navigation(
                            onPressed: (context) => settingsDefaultPageBottomSheet(context),
                            leading: Icon(Icons.pageview_outlined),
                            title: Text(AppLocalizations.of(context)!.settingsDefaultPage),
                            value: Text(defaultPageLayout),
                          ),
                          SettingsTile.navigation(
                            onPressed: (context) => settingsLayoutBottomSheet(context),
                            leading: Icon(Icons.design_services_outlined),
                            title: Text(AppLocalizations.of(context)!.settingsRecipeLayout),
                            value: Text((setting.layout == 'card') ? AppLocalizations.of(context)!.settingRecipeLayoutCard : AppLocalizations.of(context)!.settingRecipeLayoutList),
                          ),
                          SettingsTile.switchTile(
                            onToggle: (bool value) {
                              setState(() {
                                themeModeSwitch = value;
                              });
                              if (value) {
                                _settingsCubit.changeThemeTo('dark');
                              } else {
                                _settingsCubit.changeThemeTo('light');
                              }
                            },
                            initialValue: themeModeSwitch,
                            leading: Icon(Icons.format_paint),
                            title: Text(AppLocalizations.of(context)!.settingsDarkMode),
                          ),
                        ]
                    ),
                    if (setting.userServerSetting != null)
                      SettingsSection(
                          title: Text(AppLocalizations.of(context)!.shoppingListTitle),
                          tiles: [
                            SettingsTile(
                              leading: Icon(Icons.share_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsSharedWith),
                              value: Text(setting.userServerSetting!.shoppingShare.isNotEmpty ? setting.userServerSetting!.shoppingShare.map((user) => user.username).toList().join(',') : '-'),
                              onPressed: (context) => editShareDialog(context, setting.userServerSetting!, 'shopping'),
                            ),
                            SettingsTile(
                              leading: Icon(Icons.refresh_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsRefreshInterval),
                              description: Text(AppLocalizations.of(context)!.settingsRefreshIntervalDescription.replaceFirst('%s', setting.userServerSetting!.shoppingAutoSync.toString())),
                              onPressed: (context) => editShoppingListRefreshDialog(context, setting.userServerSetting!),
                            ),
                            SettingsTile(
                              leading: Icon(Icons.calendar_today_sharp),
                              title: Text(AppLocalizations.of(context)!.settingsRecentDays),
                              description: Text(AppLocalizations.of(context)!.settingsRecentDaysDescription.replaceFirst('%s', setting.userServerSetting!.shoppingRecentDays.toString())),
                              onPressed: (context) => editShoppingListRecentDaysDialog(context, setting.userServerSetting!),
                            ),
                           /* SettingsTile.switchTile(
                              enabled: false,
                              leading: Icon(Icons.add_shopping_cart_outlined),
                              onToggle: (bool value) {

                              },
                              initialValue: setting.userServerSetting!.mealPlanAutoAddShopping,
                              title: Text('Auto add meal plan'),
                              description: Text('Automatically add meal plan ingredients to shopping list'),
                            ),*/
                          ]
                      ),
                    if (setting.userServerSetting != null)
                      SettingsSection(
                          title: Text(AppLocalizations.of(context)!.mealPlanTitle),
                          tiles: [
                            SettingsTile(
                              enabled: false,
                              leading: Icon(Icons.share_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsSharedWith),
                              value: Text(setting.userServerSetting!.planShare.isNotEmpty ? setting.userServerSetting!.planShare.map((user) => user.username).toList().join(',') : '-'),
                              onPressed: (context) => editShareDialog(context, setting.userServerSetting!, 'plan'),
                            ),
                          ]
                      ),
                    if (setting.userServerSetting != null)
                      SettingsSection(
                          title: Text(AppLocalizations.of(context)!.settingsMiscellaneous),
                          tiles: [
                            /*SettingsTile(
                              enabled: false,
                              leading: Icon(Icons.scale_outlined),
                              title: Text('Default unit'),
                              value: Text(setting.userServerSetting!.defaultUnit),
                            ),
                            SettingsTile.switchTile(
                              enabled: false,
                              leading: Icon(Icons.settings),
                              onToggle: (bool value) {

                              },
                              initialValue: setting.userServerSetting!.useFractions,
                              title: Text('Use fractions'),
                            ),
                            SettingsTile.switchTile(
                              enabled: false,
                              leading: Icon(Icons.settings),
                              onToggle: (bool value) {

                              },
                              initialValue: setting.userServerSetting!.useKj,
                              title: Text('Use KJ'),
                            ),
                            SettingsTile(
                              enabled: false,
                              leading: Icon(Icons.settings),
                              title: Text('Ingredient decimal places'),
                              value: Text(setting.userServerSetting!.ingredientDecimal.toString()),
                            ),
                            SettingsTile(
                              enabled: false,
                              leading: Icon(Icons.search_outlined),
                              title: Text('Search style'),
                              value: Text(setting.userServerSetting!.searchStyle),
                            ),
                            SettingsTile.switchTile(
                              enabled: false,
                              leading: Icon(Icons.comment_outlined),
                              onToggle: (bool value) {

                              },
                              initialValue: setting.userServerSetting!.comments,
                              title: Text('Comments'),
                              description: Text('If you want to be able to create and see comments underneath recipes'),
                            ),*/
                          ]
                      ),
                    SettingsSection(
                        title: Text(AppLocalizations.of(context)!.settingsLogout),
                        tiles: [
                          SettingsTile(
                              onPressed: (context) => _authenticationBloc.add(UserLoggedOut()),
                              leading: Icon(Icons.logout_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsLogout)
                          )
                        ]
                    )
                  ],
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  lightTheme: SettingsThemeData(
                      tileHighlightColor: Theme.of(context).primaryColor,
                      titleTextColor: Theme.of(context).primaryColor,
                      settingsListBackground: Theme.of(context).scaffoldBackgroundColor
                  ),
                  darkTheme: SettingsThemeData(
                      tileHighlightColor: Theme.of(context).primaryColor,
                      titleTextColor: Theme.of(context).primaryColor,
                      settingsListBackground: Theme.of(context).scaffoldBackgroundColor
                  ),
                );
              }
          )
      )
    );
  }
}