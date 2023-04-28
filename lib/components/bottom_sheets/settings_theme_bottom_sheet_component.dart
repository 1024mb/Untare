import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/cubits/settings_cubit.dart';

Future settingsThemeBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300] : Colors.grey[700]
              ),
              child: Text(
                AppLocalizations.of(context)!.settingsThemeMode,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeThemeTo('dark');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.settingsDarkMode),
                  ),
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeThemeTo('light');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.settingsLightMode),
                  ),
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeThemeTo('system');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.settingsSystemMode),
                  )
                ],
              ),
            )
          ],
        ),
      )
  );
}