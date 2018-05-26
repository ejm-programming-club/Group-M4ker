import 'package:flutter/foundation.dart';

enum Gender { M, F }
enum Level { SL, HL }
enum Subject { BIO, CHM, PHY }

/// The profile of a student, containing information about one's
/// gender, subject (biology, chemistry, physics) levels (SL / HL),
/// and leadership skills.
class Profile {
  final Gender gender;
  final Level bioLevel, chmLevel, phyLevel;
  final bool isStrongLeader;

  static final Map<int, Profile> _cache = {};

  Profile._internal({
    this.gender,
    this.bioLevel,
    this.chmLevel,
    this.phyLevel,
    this.isStrongLeader = false,
  });

  factory Profile({
    Gender gender,
    Level bioLevel,
    Level chmLevel,
    Level phyLevel,
    bool isStrongLeader = false,
  }) {
    int hashCode = identityHashCode(gender) +
        31 * identityHashCode(bioLevel) +
        31 * 31 * identityHashCode(chmLevel) +
        31 * 31 * 31 * identityHashCode(phyLevel) +
        31 * 31 * 31 * 31 * identityHashCode(isStrongLeader);
    if (_cache.containsKey(hashCode)) return _cache[hashCode];
    Profile profile = Profile._internal(
      gender: gender,
      bioLevel: bioLevel,
      chmLevel: chmLevel,
      phyLevel: phyLevel,
      isStrongLeader: isStrongLeader,
    );
    _cache[hashCode] = profile;
    return profile;
  }
}

/// A student defined by his/her name and [Profile].
class Student {
  final Profile profile;
  final String name;

  Student({this.profile, this.name});

  /// Utility method to check if this student is taking the specified [Subject].
  bool takes(Subject subject) {
    return {
          Subject.BIO: profile.bioLevel,
          Subject.CHM: profile.chmLevel,
          Subject.PHY: profile.phyLevel,
        }[subject] !=
        null;
  }
}

class StudentPos {
  final int groupInd, memberInd;
  static final Map<int, StudentPos> _cache = {};

  StudentPos._internal(this.groupInd, this.memberInd);

  factory StudentPos(int groupInd, int memberInd) {
    int hashCode =
        identityHashCode(groupInd) + identityHashCode(memberInd) * 31;
    if (!_cache.containsKey(hashCode))
      _cache[hashCode] = StudentPos._internal(groupInd, memberInd);
    return _cache[hashCode];
  }
}

/// An arrangement of groups of students.
class Grouping {
  final List<List<Student>> groups;

  Grouping(this.groups);

  void swap(StudentPos pos1, StudentPos pos2) {
    Student temp = groups[pos1.groupInd][pos1.memberInd];
    groups[pos1.groupInd][pos1.memberInd] =
        groups[pos2.groupInd][pos2.memberInd];
    groups[pos2.groupInd][pos2.memberInd] = temp;
  }

  @override
  String toString() {
    return "[" +
        groups
            .map((members) =>
                "\n  [" +
                members
                    .map((member) => '"' + member.name.toString() + '"')
                    .join(", ") +
                "]")
            .join(',') +
        "\n]";
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

      if (profile.bioLevel != null) {
        bioCount++;
        if (profile.bioLevel == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.chmLevel != null) {
        chmCount++;
        if (profile.chmLevel == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.phyLevel != null) {
        phyCount++;
        if (profile.phyLevel == Level.SL)
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

/// Une promotion des étudiants / class of a certain year / 一届学生
class Promo {
  final String name;
  final List<Student> students;

  Promo({this.name, @required this.students});
}
