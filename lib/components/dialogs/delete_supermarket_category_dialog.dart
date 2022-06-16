import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/futures/future_api_cache_supermarket_categories.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future deleteSupermarketCategoryDialog(BuildContext context) async {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final ShoppingListBloc _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  final List<SupermarketCategory> supermarketCategories = await getSupermarketCategoriesFromApiCache();
  final List<DropdownMenuItem> supermarketCategoriesWidgetList =
  supermarketCategories.map((category) => DropdownMenuItem(
    value: category,
    child: Text(category.name),
  )).toList();

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: FormBuilder(
                key: _formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Wrap(
                  spacing: 15,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(AppLocalizations.of(context)!.removeSupermarketCategory, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                    FormBuilderDropdown(
                      name: 'category',
                      allowClear: true,
                      items: supermarketCategoriesWidgetList,
                      decoration: InputDecoration(
                          label: Text(AppLocalizations.of(context)!.category)
                      ),
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required()]
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              _formBuilderKey.currentState!.save();

                              if (_formBuilderKey.currentState!.validate()) {
                                _shoppingListBloc.add(DeleteSupermarketCategory(supermarketCategory: _formBuilderKey.currentState!.value['category']));
                                Navigator.pop(dContext);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.remove)
                        )
                    )
                  ],
                )
            )
        )
    );
  });
}