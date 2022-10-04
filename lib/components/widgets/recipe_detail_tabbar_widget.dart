import 'package:flutter/material.dart';
import 'package:untare/models/ingredient.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/extensions/double_extension.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

class RecipeDetailTabBarWidget extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailTabBarWidget({Key? key, required this.recipe}) : super(key: key);

  @override
  RecipeDetailTabBarWidgetState createState() => RecipeDetailTabBarWidgetState();
}

class RecipeDetailTabBarWidgetState extends State<RecipeDetailTabBarWidget> {
  late int servings;
  late int newServings;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings ?? 0;
    newServings = servings;
  }

  void increment() {
    setState(() {
      newServings += 1;
    });
  }

  void decrement() {
    if (newServings > 1) {
      setState(() {
        newServings -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return TabBarView(
      children: [
        ingredientTabView(),
        directionsTabView()
      ],
    );
  }

  Widget ingredientTabView() {
    List<Widget> ingredientsList = [];
    List<Ingredient> recipeIngredients = [];

    if (widget.recipe.steps.isNotEmpty) {
      for (var step in widget.recipe.steps) {
        if (step.ingredients.isNotEmpty) {
          for (var ingredient in step.ingredients) {
            recipeIngredients.add(ingredient);
          }
        }
      }
    }

    ingredientsList.addAll(recipeIngredients.map((item) => ingredientComponent(item, servings, newServings, false, context)).toList());

    if (ingredientsList.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 160),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Text('${AppLocalizations.of(context)!.servings}:', style: const TextStyle(fontSize: 15)),
                IconButton(
                  onPressed: () => {
                    decrement()
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(newServings.toString()),
                IconButton(
                    onPressed: () => {
                      increment()
                    },
                    icon: Icon(
                      Icons.add_circle_outline_outlined,
                      color: Theme.of(context).primaryColor,
                    )
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: ingredientsList,
            ),
          )
        ],
      );
    } else {
      return Center(child: Text(AppLocalizations.of(context)!.recipeNoIngredientsPresent));
    }
  }

  Widget directionsTabView() {
    List<Widget> directionsSteps = [];

    if (widget.recipe.steps.isNotEmpty) {
      if (widget.recipe.steps.length > 1) {
        for (int i = 0; i < widget.recipe.steps.length; i++) {
          List<Widget> stepList = [];

          stepList.addAll(widget.recipe.steps[i].ingredients.map((item) => ingredientComponent(item, servings, newServings, true, context)).toList());

          stepList.add(Padding(padding: const EdgeInsets.fromLTRB(20, 12, 15, 10), child: Text(widget.recipe.steps[i].instruction ?? '', style: const TextStyle(fontSize: 15))));

          directionsSteps.add(directionStepLayout(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: stepList), i+1));
        }

      } else if (widget.recipe.steps.length == 1) {
        List<String> splitDirectionsStrings = (widget.recipe.steps.first.instruction != null && widget.recipe.steps.first.instruction != '')
            ? widget.recipe.steps.first.instruction!.split("\n\n")
            : [];

        if (splitDirectionsStrings.length <= 2) {
          List<String> tmpSplitInstructions = splitDirectionsStrings;
          splitDirectionsStrings = [];
          for(int i = 0; i < tmpSplitInstructions.length; i++) {
            splitDirectionsStrings.addAll(tmpSplitInstructions[i].split("\n"));
          }
        }

        for(int i = 0; i < splitDirectionsStrings.length; i++) {
          final splitInstruction = splitDirectionsStrings[i].replaceAll("\r", "");

          if (!splitInstruction.toLowerCase().contains('imported from: http')) {
            directionsSteps.add(
              directionStepLayout(
                context,
                Padding(padding: const EdgeInsets.fromLTRB(20, 12, 15, 10), child: Text(splitInstruction, style: const TextStyle(fontSize: 15))),
                i+1
              )
            );
          }
        }
      }

      return ListView(
        padding: const EdgeInsets.only(top: 175, right: 5, bottom: 0),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: directionsSteps,
      );

    } else {
      return Center(child: Text(AppLocalizations.of(context)!.recipeNoDirectionsPresent));
    }
  }
}

Widget directionStepLayout(BuildContext context, Widget widget, int stepNumber) {
  return Container(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 60,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5),
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Text((stepNumber).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            )
        ),
        Container(
          margin: const EdgeInsets.only(left: 30, bottom: 15),
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1
                  )
              )
          ),
          child: widget,
        )
      ],
    ),
  );
}

Widget ingredientComponent(Ingredient ingredient, int initServing, int newServing, bool isDense, BuildContext context) {
  String amount = (ingredient.amount > 0) ? ('${(ingredient.amount * (((newServing/initServing))*100).ceil()/100).toFormattedString()} ') : '';
  String unit = (ingredient.amount > 0 && ingredient.unit != null) ? ('${ingredient.unit!.name} ') : '';
  String food = (ingredient.food != null) ? ('${ingredient.food!.name} ') : '';
  String note = (ingredient.note != null && ingredient.note != '') ? ('(${ingredient.note!})') : '';

  return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                  width: 0.8
              )
          )
      ),
      child: ListTile(
        dense: isDense,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        title: Wrap(
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(unit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(food, style: const TextStyle(fontSize: 15)),
            Text(
                note,
                style: TextStyle(
                    color: (Theme.of(context).brightness.name == 'light') ? Colors.black45 : Colors.grey[600]!,
                    fontStyle: FontStyle.italic,
                    fontSize: 15
                )
            )
          ],
        )
      )
  );
}