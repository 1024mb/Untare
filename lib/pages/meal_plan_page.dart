import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/blocs/meal_plan/meal_plan_state.dart';
import 'package:tare/components/bottom_sheets/meal_plan_more_bottom_sheet_component.dart';
import 'package:tare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/recipes/recipe_grid_component.dart';
import 'package:tare/components/recipes/recipe_list_component.dart';
import 'package:tare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/cubits/recipe_layout_cubit.dart';
import 'package:tare/models/meal_plan_entry.dart';
import 'package:tare/models/meal_type.dart';
import '../components/custom_scroll_notification.dart';


class MealPlanPage extends HideBottomNavBarStatefulWidget {
  MealPlanPage({required isHideBottomNavBar}) : super(isHideBottomNavBar: isHideBottomNavBar);

  @override
  _MealPlanPageState createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  DateTime dateTime = DateTime.now();
  late String rangeTitleText;
  late MealPlanBloc _mealPlanBloc;
  List<MealPlanEntry> mealPlanList = [];
  late DateTime fromDateTime;
  late DateTime toDateTime;
  
  late String fromDate;
  late String toDate;

  @override
  void initState() {
    super.initState();
    fromDateTime = dateTime.subtract(const Duration(days: 28));
    fromDate = DateFormat('yyyy-MM-dd').format(fromDateTime);

    toDateTime = dateTime.add(const Duration(days: 28));
    toDate = DateFormat('yyyy-MM-dd').format(toDateTime);

    rangeTitleText = getTitleText();

    _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);
    _mealPlanBloc.add(FetchMealPlan(from: fromDate, to: toDate));
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  void decreaseDate() {
    setState(() {
      dateTime = dateTime.subtract(Duration(days: 7));
      rangeTitleText = getTitleText();
    });
  }

  void increaseDate() {
    setState(() {
      dateTime = dateTime.add(Duration(days: 7));
      rangeTitleText = getTitleText();
    });
  }

  String getTitleText() {
    DateTime today = DateTime.now();
    DateTime todayNextWeek = today.add(Duration(days: 7));
    DateTime todayLastWeek = today.subtract(Duration(days: 7));

    // Add and subtract one millisecond cause there is no <= and >=
    if (dateTime.add(Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(today))
        && dateTime.subtract(Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(today))) {
      return 'this week';
    } else if (dateTime.add(Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(todayNextWeek))
        && dateTime.subtract(Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(todayNextWeek))) {
      return 'next week';
    } else if (dateTime.add(Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(todayLastWeek))
        && dateTime.subtract(Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(todayLastWeek))) {
      return 'last week';
    }

    return DateFormat('d. MMM').format(findFirstDateOfTheWeek(dateTime)) + ' - ' + DateFormat('d. MMM').format(findLastDateOfTheWeek(dateTime));
  }

  @override
  Widget build(BuildContext context) {
    final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
    return NestedScrollView(
        headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverAppBar(
          expandedHeight: 120,
          leadingWidth: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.black87),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(15, 0, 0, 50),
            expandedTitleScale: 1.3,
            title: Text(
              'Meal plan',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          actions: [
            IconButton(
                tooltip: 'More',
                splashRadius: 20,
                onPressed: () {
                  mealPlanMoreBottomSheet(context);
                },
                icon: Icon(
                  Icons.more_vert_outlined,
                  color: Colors.black87,
                )
            )
          ],
          elevation: 1.5,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size(double.maxFinite, 35),
            child:  Container(
              height: 35,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      padding: const EdgeInsets.fromLTRB(8, 1, 8, 12),
                      splashRadius: 20,
                      onPressed: () {
                        decreaseDate();
                      },
                      icon: Icon(Icons.chevron_left_outlined)
                  ),
                  SizedBox(
                    width: 155,
                    child: Text(
                      rangeTitleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                      padding: const EdgeInsets.fromLTRB(8, 1, 8, 12),
                      splashRadius: 20,
                      onPressed: () {
                        increaseDate();
                      },
                      icon: Icon(Icons.chevron_right_outlined)
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    },
    body: BlocConsumer<MealPlanBloc, MealPlanState>(
        listener: (context, state) {
          if (state is MealPlanCreated) {
            mealPlanList.add(state.mealPlan);
          } else if (state is MealPlanUpdated) {
            mealPlanList[mealPlanList.indexWhere((element) => element.id == state.mealPlan.id)] = state.mealPlan;
          } else if (state is MealPlanDeleted) {
            mealPlanList.removeWhere((element) => element.id == state.mealPlan.id);
          } else if (state is MealPlanUpdatedType) {
            mealPlanList.forEach((element) {
              if (element.mealType.id == state.mealType.id) {
                MealType newMealType = element.mealType.copyWith(name: state.mealType.name);
                MealPlanEntry entry = element.copyWith(mealType: newMealType);
                mealPlanList[mealPlanList.indexWhere((element) => element.id == entry.id)] = entry;
              }
            });
          } else if (state is MealPlanDeletedType) {
            List<int> idsToRemove = [];
            mealPlanList.forEach((element) {
              if (element.mealType.id == state.mealType.id) {
                idsToRemove.add(element.id!);
              }
            });

            idsToRemove.forEach((element) {
              mealPlanList.removeWhere((el) => el.id == element);
            });
          }
        },
        builder: (context, state) {
          if (state is MealPlanLoading) {
            return buildLoading();
          } else if (state is MealPlanFetched) {
            mealPlanList = state.mealPlanList;
          }

          return Container(

            child: NotificationListener<ScrollNotification>(
              onNotification: customScrollNotification.handleScrollNotification,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                children: buildMealPlanLayout(context, mealPlanList, dateTime),
              ),
            )
          );
        }
      )
    );
  }
}

List<Widget> buildMealPlanLayout(BuildContext context, List<MealPlanEntry> mealPLanList, DateTime dateTime) {
  List<Widget> mealPlanLayout = [];
  DateTime firstDayOfWeek = dateTime.subtract(Duration(days: dateTime.weekday - 1));

  for(int i = 0; i < 7; i++) {
    DateTime day = firstDayOfWeek.add(Duration(days: i));

    mealPlanLayout.add(buildDayLayout(context, mealPLanList, day));
  }

  return mealPlanLayout;
}

Widget buildDayLayout(BuildContext context, List<MealPlanEntry> mealPlanList, DateTime day) {
  DateTime today = DateTime.now();
  bool isToday = (today.year == day.year && today.month == day.month && today.day == day.day);
  List<MealPlanEntry> dailyMealPlanList = [];
  List<Widget> dailyMealPlanWidgetList = [];

  mealPlanList.forEach((mealPlan) {
    DateTime temp = DateTime.parse(mealPlan.date);
    if (day.year == temp.year && day.month == temp.month && day.day == temp.day) {
      dailyMealPlanList.add(mealPlan);
    }
  });

  return Container(
    decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1
            )
        )
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Row(
            children: [
              Text(
                  DateFormat('EEEE').format(day),
                  style: TextStyle(
                      fontWeight: (dailyMealPlanList.isNotEmpty) ? FontWeight.bold : FontWeight.normal,
                      color: (dailyMealPlanList.isNotEmpty) ? Colors.black87 : Colors.black45
                  )
              ),
              SizedBox(width: 8),
              (isToday)
                  ? Text('today', style: TextStyle(color: primaryColor))
                  : Text(DateFormat('d. MMM').format(day), style: TextStyle(color: Colors.black45))
            ],
          ),
          trailing: IconButton(
              onPressed: () {
                upsertMealPlanEntryDialog(context, date: day, referer: 'meal-plan');
              },
              icon: Icon(Icons.add)
          ),
        ),
        BlocBuilder<RecipeLayoutCubit, String>(
            builder: (context, layout) {
              dailyMealPlanWidgetList.clear();
              dailyMealPlanList.forEach((mealPlan) {
                if (mealPlan.recipe != null) {
                  if (layout == 'list') {
                    dailyMealPlanWidgetList.add(
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey[100]!,
                                    width: 1
                                )
                            )
                        ),
                        child: recipeListComponent(mealPlan.recipe!, context, referer: 'mealList' + mealPlan.id.toString(), mealPlan: mealPlan),
                      )

                    );
                  } else {
                    dailyMealPlanWidgetList.add(
                        Container(
                            width: 180,
                            child: recipeGridComponent(mealPlan.recipe!, context, referer: 'mealGrid' + mealPlan.id.toString(), mealPlan: mealPlan)
                        )
                    );
                    dailyMealPlanWidgetList.add(SizedBox(width: 5));
                  }
                }
              });

              if (layout == 'list') {
                return Container(
                  child: Column(
                    children: dailyMealPlanWidgetList,
                  )
                );
              } else {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  scrollDirection: Axis.horizontal,
                  padding: (dailyMealPlanWidgetList.isNotEmpty) ? const EdgeInsets.fromLTRB(12, 0, 7, 8) : null,
                  child: Row(
                    children: dailyMealPlanWidgetList,
                  ),
                );
              }
            }
        )
      ],
    ),
  );
}
