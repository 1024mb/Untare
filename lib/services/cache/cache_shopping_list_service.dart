// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/app_setting.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheShoppingListService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<ShoppingListEntry>? getShoppingListEntries(String checked, String idFilter) {
    List<dynamic>? cache = box.get('shoppingListEntries');
    List<ShoppingListEntry>? cacheShoppingListEntries = (cache != null) ? cache.cast<ShoppingListEntry>() : null;
    List<ShoppingListEntry>? shoppingListEntries;

    shoppingListEntries = cacheShoppingListEntries;
    if (cacheShoppingListEntries != null && cacheShoppingListEntries.isNotEmpty) {
      shoppingListEntries = [];

      for (var entry in cacheShoppingListEntries) {
        if (checked == 'true') {
          if (entry.checked) {
            shoppingListEntries.add(entry);
          }
        } else if (checked == 'false') {
          if (!entry.checked) {
            shoppingListEntries.add(entry);
          }
        } else if (checked == 'both') {
          shoppingListEntries.add(entry);
        } else if (checked == 'recent') {
          if (!entry.checked) {
            shoppingListEntries.add(entry);
          } else {
            AppSetting? appSetting = box.get('settings');

            int recentDays = 7;
            if (appSetting != null && appSetting.userServerSetting != null) {
              recentDays = appSetting.userServerSetting!.shoppingRecentDays;
            }

            if (entry.completedAt != null) {
              DateTime completedAtDate = DateTime.parse(entry.completedAt!);
              DateTime todayMinusRecentDays = DateTime.now().subtract(Duration(days: recentDays));

              if (completedAtDate.year >= todayMinusRecentDays.year
                  && completedAtDate.month >= todayMinusRecentDays.month
                  && completedAtDate.day >= todayMinusRecentDays.day) {
                shoppingListEntries.add(entry);
              }
            } else {
              shoppingListEntries.add(entry);
            }
          }
        }

        // @todo Implement id filter
      }
    }

    return shoppingListEntries;
  }

  upsertShoppingListEntries(List<ShoppingListEntry> shoppingListEntries) {
    List<dynamic>? cacheEntities = box.get('shoppingListEntries');

    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      // Delete entries from cache
      cacheEntities.removeWhere((element) {
        return shoppingListEntries.indexWhere((e) => e.id == element.id) < 0;
      });

      for (var entity in shoppingListEntries) {
        int cacheEntityIndex = cacheEntities.indexWhere((cacheEntity) => cacheEntity.id == entity.id);

        // If we found the entity in cache entities, overwrite data, if not add entity
        if (cacheEntityIndex >= 0) {
          cacheEntities[cacheEntityIndex] = entity;
        } else {
          cacheEntities.add(entity);
        }
      }
    } else {
      cacheEntities = [];
      cacheEntities.addAll(shoppingListEntries);
    }

    box.put('shoppingListEntries', cacheEntities);
    upsertEntityList(shoppingListEntries, 'shoppingListEntries');
  }

  upsertShoppingListEntry(ShoppingListEntry shoppingListEntry) {
    upsertEntity(shoppingListEntry, 'shoppingListEntries');
  }

  deleteShoppingListEntry(ShoppingListEntry shoppingListEntry) {
    deleteEntity(shoppingListEntry, 'shoppingListEntries');
  }

  List<SupermarketCategory>? getSupermarketCategories() {
    List<dynamic>? categories = box.get('supermarketCategories');

    if (categories != null) {
      return categories.cast<SupermarketCategory>();
    }

    return null;
  }

  upsertSupermarketCategories(List<SupermarketCategory> categories) {
    upsertEntityList(categories, 'supermarketCategories');
  }

  upsertSupermarketCategory(SupermarketCategory category) {
    upsertEntity(category, 'supermarketCategories');
  }

  deleteSupermarketCategory(SupermarketCategory category) {
    deleteEntity(category, 'supermarketCategories');
  }
}