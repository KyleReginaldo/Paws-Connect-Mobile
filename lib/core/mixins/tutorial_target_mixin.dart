import 'package:flutter/material.dart';

// Global shared keys so all screens reference the same instances
class TutorialKeys {
  // Bottom Navigation Keys
  static final GlobalKey homeTabKey = GlobalKey();
  static final GlobalKey fundraisingTabKey = GlobalKey();
  static final GlobalKey petsTabKey = GlobalKey();
  static final GlobalKey forumTabKey = GlobalKey();

  // App Bar Keys
  static final GlobalKey locationButtonKey = GlobalKey();
  static final GlobalKey notificationsButtonKey = GlobalKey();
  static final GlobalKey profileButtonKey = GlobalKey();

  // Home Screen Keys
  static final GlobalKey searchFieldKey = GlobalKey();
  static final GlobalKey adoptionOverviewKey = GlobalKey();
  static final GlobalKey recentPetsKey = GlobalKey();
  static final GlobalKey fundraisingListKey = GlobalKey();
}

mixin TutorialTargetMixin {
  // Expose shared keys via getters (keeps existing field names in calling code)
  GlobalKey get homeTabKey => TutorialKeys.homeTabKey;
  GlobalKey get fundraisingTabKey => TutorialKeys.fundraisingTabKey;
  GlobalKey get petsTabKey => TutorialKeys.petsTabKey;
  GlobalKey get forumTabKey => TutorialKeys.forumTabKey;

  GlobalKey get locationButtonKey => TutorialKeys.locationButtonKey;
  GlobalKey get notificationsButtonKey => TutorialKeys.notificationsButtonKey;
  GlobalKey get profileButtonKey => TutorialKeys.profileButtonKey;

  GlobalKey get searchFieldKey => TutorialKeys.searchFieldKey;
  GlobalKey get adoptionOverviewKey => TutorialKeys.adoptionOverviewKey;
  GlobalKey get recentPetsKey => TutorialKeys.recentPetsKey;
  GlobalKey get fundraisingListKey => TutorialKeys.fundraisingListKey;

  // Method to get all keys for tutorial targeting
  Map<String, GlobalKey> getTutorialKeys() {
    return {
      'home_tab': homeTabKey,
      'fundraising_tab': fundraisingTabKey,
      'pets_tab': petsTabKey,
      'forum_tab': forumTabKey,
      'location_button': locationButtonKey,
      'notifications_button': notificationsButtonKey,
      'profile_button': profileButtonKey,
      'search_field': searchFieldKey,
      'adoption_overview': adoptionOverviewKey,
      'recent_pets': recentPetsKey,
      'fundraising_list': fundraisingListKey,
    };
  }
}
