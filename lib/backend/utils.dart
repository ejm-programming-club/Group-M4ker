import 'package:flutter/foundation.dart';

enum Gender { M, F }
enum Level { SL, HL }
enum Subject { BIO, CHM, PHY }

/// The profile of a student, containing information about one's
/// gender, subject (biology, chemistry, physics) levels (SL / HL),
/// and leadership skills.
class Profile {
  Gender gender;
  Level bioLevel, chmLevel, phyLevel;
  bool isStrongLeader;

  Profile({
    @required this.gender,
    @required this.bioLevel,
    @required this.chmLevel,
    @required this.phyLevel,
    @required this.isStrongLeader,
  });

  @override
  bool operator ==(other) {
    return other is Profile &&
        gender == other.gender &&
        bioLevel == other.bioLevel &&
        chmLevel == other.chmLevel &&
        phyLevel == other.phyLevel &&
        isStrongLeader == other.isStrongLeader;
  }

  @override
  int get hashCode => super.hashCode;
}

/// A student defined by his/her name and [Profile].
class Student {
  Profile profile;
  String name;

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
  final List<Student> students;

  Promo({@required this.students});
}

bool isNull(String s) => s.length == 0 || s == "NA";

Promo promoFromCsv(String csv) {
  List<Student> students = <Student>[];

  for (String row in csv.split('\n').sublist(1)) {
    // Student,M/F,BIO Level,BIO Group,CHM Level,PHY Level,email[,leadership]
    List<String> fields = row.split(',');
    Level bioLevel, chmLevel, phyLevel;

    if (!isNull(fields[2])) {
      bioLevel = fields[2] == "SL" ? Level.SL : Level.HL;
    } else {
      phyLevel = fields[5] == "SL" ? Level.SL : Level.HL;
    }

    if (!isNull(fields[4])) {
      chmLevel = fields[4] == "SL" ? Level.SL : Level.HL;
    }

    students.add(Student(
        name: fields[0],
        profile: Profile(
          gender: fields[1] == "M" ? Gender.M : Gender.F,
          bioLevel: bioLevel,
          chmLevel: chmLevel,
          phyLevel: phyLevel,
          isStrongLeader: false,
        )));
  }
  return Promo(students: students);
}

Student findFrom(List<Student> promo, String name) {
  for (Student student in promo) {
    if (student.name == name) return student;
  }
  throw Exception;
}
