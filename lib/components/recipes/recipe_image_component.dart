import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untare/models/recipe.dart';

Widget buildRecipeImage(Recipe recipe, BorderRadius borderRadius, double height, {BoxShadow? boxShadow, String? referer}) {

  if (recipe.image != null) {
    return Hero(
        tag: recipe.id.toString() + referer.toString(),
        child: CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 0),
          fadeOutDuration: const Duration(milliseconds: 0),
          imageUrl: recipe.image ?? '',
          imageBuilder: (context, imageProvider) => Container(
            height: height,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[100]! : Colors.grey[700],
              borderRadius: borderRadius,
              boxShadow: [
                if (boxShadow != null) boxShadow
              ],
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => Shimmer.fromColors(
            enabled: true,
            baseColor: (Theme.of(context).brightness.name == 'light') ? Colors.grey[100]! : Colors.grey[700]!,
            highlightColor: (Theme.of(context).brightness.name == 'light') ? Colors.grey[200]! : Colors.grey[600]!,
            child: Container(
              height: height,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[100] : Colors.grey[700],
                borderRadius: borderRadius,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              height: height,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness.name == 'light') ? Colors.black12 : Colors.grey[700],
                borderRadius: borderRadius,
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.black38 : Colors.grey[400],
                ),
              ),
            );
          },
        )
    );
  }

  return Builder(builder: (BuildContext context) {
    return Container(
      height: height,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness.name == 'light') ? Colors.black12 : Colors.grey[700],
        borderRadius: borderRadius,
      ),
      child: Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant_menu_outlined,
          color: (Theme.of(context).brightness.name == 'light') ? Colors.black38 : Colors.grey[400],
        ),
      ),
    );
  });
}