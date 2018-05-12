import 'dart:io';

typedef void PBarUpdateCallback(double);

enum Gender { M, F }
enum Level { SL, HL }
enum Subject { BIO, CHM, PHY }

/// The profile of a student, containing information about one's
/// gender, group 4 subject and level, group 6 subject and level,
/// and leadership.
///
/// At EJM, the group 4 subject must be either biology or physics;
/// the group 6 subject, chemistry, is optional.
class Profile {
  final Gender gender;
  final Subject group4Subject;
  final Level group4Level;
  final Subject group6Subject;
  final Level group6Level;
  final bool isStrongLeader;

  Profile({
    this.gender,
    this.group4Subject,
    this.group4Level,
    this.group6Subject,
    this.group6Level,
    this.isStrongLeader,
  }) {
    assert(gender != null);
    assert(group4Subject == Subject.BIO || group4Subject == Subject.PHY);
    assert(group4Level != null);
    assert(group6Subject == null
        ? group6Level == null
        : group6Subject == Subject.CHM && group6Level != null);
  }

  @override
  int get hashCode => identityHashCode([
        gender,
        group4Subject,
        group4Level,
        group6Subject,
        group6Level,
        isStrongLeader
      ]);

  @override
  bool operator ==(other) => other is Profile && hashCode == other.hashCode;
}

/// A student defined by his/her name and [Profile].
class Student {
  final Profile profile;
  final String name;

  Student(this.profile, this.name);
}

/// An arrangement of groups of students.
class Grouping {
  final List<List<Student>> groups;

  Grouping(this.groups);

  void swap(int groupInd1, personInd1, int groupInd2, int personInd2) {
    Student temp = groups[groupInd1][personInd1];
    groups[groupInd1][personInd1] = groups[groupInd2][personInd2];
    groups[groupInd2][personInd2] = temp;
  }
}

class GroupStats {
  final int maleCount;
  final int femaleCount;
  final int bioCount;
  final int chmCount;
  final int phyCount;
  final int slCount;
  final int hlCount;
  final int strongLeadersCount;

  GroupStats({
    this.maleCount,
    this.femaleCount,
    this.bioCount,
    this.chmCount,
    this.phyCount,
    this.slCount,
    this.hlCount,
    this.strongLeadersCount,
  });

  factory GroupStats.of(List<Student> group) {
    int maleCount = 0;
    int femaleCount = 0;
    int bioCount = 0;
    int chmCount = 0;
    int phyCount = 0;
    int slCount = 0;
    int hlCount = 0;
    int strongLeadersCount = 0;

    for (final Student student in group) {
      final Profile profile = student.profile;
      if (profile.gender == Gender.M)
        maleCount++;
      else
        femaleCount++;

      if (profile.group4Subject == Subject.BIO)
        bioCount++;
      else
        phyCount++;
      if (profile.group4Level == Level.SL)
        slCount++;
      else
        hlCount++;

      if (profile.group6Subject != null) {
        chmCount++;
        if (profile.group6Level == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.isStrongLeader) strongLeadersCount++;
    }

    return GroupStats(
      maleCount: maleCount,
      femaleCount: femaleCount,
      bioCount: bioCount,
      chmCount: chmCount,
      phyCount: phyCount,
      slCount: slCount,
      hlCount: hlCount,
      strongLeadersCount: strongLeadersCount,
    );
  }
}

List<Student> loadPromoFromCSV(String filename) {
  // TODO do this
  return [];
}

abstract class Generator {
  final List<Student> promo;

  Generator(this.promo);

  List<List<Student>> generate(
      {int numberOfGroups = 10, PBarUpdateCallback pBarUpdateCallback});
}

abstract class Evaluator {
  List<Student> promo;

  Evaluator(this.promo);

  List<List<String>> findIssues(Grouping grouping);
}

class MeanEvaluator implements Evaluator {
  @override
  List<Student> promo;
  GroupStats promoStats;

  MeanEvaluator(this.promo) {
    promoStats = GroupStats.of(promo);
  }

  @override
  List<List<String>> findIssues(Grouping grouping) {
    int numberOfGroups = grouping.groups.length;

    var errors = <List<String>>[];
    for (List<Student> group in grouping.groups) {
      var groupErrors = <String>[];
      var groupStats = GroupStats.of(group);

      double idealMaleCount = promoStats.maleCount / numberOfGroups;
      double idealFemaleCount = promoStats.femaleCount / numberOfGroups;
      double idealBioCount = promoStats.bioCount / numberOfGroups;
      double idealChmCount = promoStats.chmCount / numberOfGroups;
      double idealPhyCount = promoStats.phyCount / numberOfGroups;
      double idealSLCount = promoStats.slCount / numberOfGroups;
      double idealHLCount = promoStats.hlCount / numberOfGroups;
      double idealLeadersCount = promoStats.strongLeadersCount / numberOfGroups;

      if ((groupStats.maleCount - idealMaleCount).abs() >= 1)
        groupErrors
            .add("Expected $idealMaleCount males; got ${groupStats.maleCount}");
      if ((groupStats.femaleCount - idealFemaleCount).abs() >= 1)
        groupErrors.add("Expected $idealFemaleCount females; got ${groupStats
            .femaleCount}");

      if ((groupStats.bioCount - idealBioCount).abs() >= 1)
        groupErrors.add(
            "Expected $idealBioCount biologists; got ${groupStats.bioCount}");
      if ((groupStats.chmCount - idealChmCount).abs() >= 1)
        groupErrors.add(
            "Expected $idealChmCount chemists; got ${groupStats.chmCount}");
      if ((groupStats.phyCount - idealPhyCount).abs() >= 1)
        groupErrors.add(
            "Expected $idealPhyCount physicists; got ${groupStats.phyCount}");

      if ((groupStats.slCount - idealSLCount).abs() >= 1)
        groupErrors
            .add("Expected $idealSLCount SLs; got ${groupStats.slCount}");
      if ((groupStats.hlCount - idealHLCount).abs() >= 1)
        groupErrors
            .add("Expected $idealHLCount SLs; got ${groupStats.hlCount}");

      if ((groupStats.strongLeadersCount - idealLeadersCount).abs() >= 1)
        groupErrors
            .add("Expected $idealLeadersCount strong leaders; got ${groupStats
                .strongLeadersCount}");

      errors.add(groupErrors);
    }
    return errors;
  }
}
