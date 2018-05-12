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

  Student({this.profile, this.name});
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

const String _promo2019CSV =
    """Student,M/F,BIO Level,BIO Group,CHM Level,PHY Level,email
Alcufrom Winston,M,SL,,NA,NA,w.alcufrom19@ejm.org
Ali Cherif Neila,F,HL,G4,HL,NA,n.alicherif19@ejm.org
Amar Paul Benjamin,M,NA,,HL,HL,p.amar19@ejm.org
Amlani Lucca,M,SL,,NA,NA,l.amlani19@ejm.org
Bovard Andrea,F,HL,G4,NA,NA,a.bovard19@ejm.org
Burnham Elliot,M,SL,,NA,NA,e.burnham19@ejm.org
Cavrel Sara,F,SL,,NA,NA,s.cavrel19@ejm.org
Chung Byeola,F,HL,G4,SL,NA,b.chung19@ejm.org
Corvalan Myrna-Paula,F,NA,,NA,SL,m.corvalan19@ejm.org
Coulom Stella,F,SL,,NA,NA,s.coulom19@ejm.org
Dao Léo,M,NA,,NA,HL,l.dao19@ejm.org
Del Monte Giulio,M,SL,,NA,NA,g.delmonte19@ejm.org
Delmas Idil,F,SL,,NA,NA,i.delmas19@ejm.org
Deneve Marc,M,HL,G4,NA,NA,m.deneve19@ejm.org
Du Buisson Perrine Hugo,M,NA,,HL,SL,h.dubuissonperrine19@ejm.org
Du Buisson Perrine Lucas,M,NA,,HL,SL,l.dubuissonperrine19@ejm.org
Du Buisson Perrine Matthieu,M,NA,,NA,SL,m.dubuissonperrine19@ejm.org
Elfaizy-Phillips Theodorus,M,HL,G4,NA,NA,t.elfaizyphillips19@ejm.org
Esfandiari Nafsika,F,HL,G4,SL,NA,n.esfandiari19@ejm.org
Evgeniou Lilia,F,HL,G4,HL,NA,l.evgeniou19@ejm.org
Fabian Ariane,F,SL,,NA,NA,a.fabian19@ejm.org
Gillot Edern,M,NA,,HL,HL,e.gillot19@ejm.org
Hellouin De Menibus George,M,NA,,SL,HL,g.hellouindemenibus19@ejm.org
Herbette Titouan,M,HL,G4,SL,NA,t.herbette19@ejm.org
Hibon Adrien Arya,M,SL,,NA,NA,a.hibon19@ejm.org
Higgins Kimberly,F,NA,,NA,HL,k.higgins19@ejm.org
Ismail Natasha,F,SL,,NA,NA,n.ismail19@ejm.org
Isore William,M,SL,,NA,NA,w.isore19@ejm.org
Korchagin Antoine,M,SL,,NA,NA,a.korchagin19@ejm.org
Lazo Emily,F,NA,,NA,HL,e.lazo19@ejm.org
Lecommandeur Louise,F,HL,G4,NA,NA,l.lecommandeur19@ejm.org
Levy Gabrielle,F,SL,,NA,NA,g.levy19@ejm.org
Maghraoui Lena,F,NA,,SL,HL,l.maghraoui19@ejm.org
Maghraoui Sarah,F,HL,G4,SL,NA,s.maghraoui19@ejm.org
Makhotina Ilkay,F,HL,G4,HL,NA,i.makhotina19@ejm.org
Marenzi Cyrus,M,SL,,NA,NA,c.marenzi19@ejm.org
Mire Adrien,M,HL,G4,HL,NA,a.mire19@ejm.org
Morel Gabriel,M,HL,G4,HL,NA,g.morel19@ejm.org
Mourouga Erell,F,HL,G4,NA,NA,e.mourouga19@ejm.org
Nguyen Mia,F,SL,G4,NA,NA,m.nguyen19@ejm.org
Picard Théo,M,SL,,NA,NA,t.picard19@ejm.org
Povse Matej,M,HL,G4,SL,NA,m.povse19@ejm.org
Prigent Colin,M,SL,,NA,NA,c.prigent19@ejm.org
Rousselet Kayla,F,SL,,NA,NA,k.rousselet19@ejm.org
Ruggiero Eva,F,SL,,NA,NA,e.ruggiero19@ejm.org
Salleras Adora,F,SL,,NA,NA,a.salleras19@ejm.org
Sarkozy De Nagy Bosca Arpad,M,SL,,NA,NA,a.sarkozydenagybosca19@ejm.org
Sauvage Gaspard,M,NA,,NA,SL,g.sauvage19@ejm.org
Sawko Thais,F,HL,G4,HL,NA,t.sawko19@ejm.org
Somaini Cardelus Federico,M,HL,G4,HL,NA,f.somainicardelus19@ejm.org
Spotnitz Amelia,F,SL,,NA,NA,a.spotnitz19@ejm.org
Streimann Helena,F,NA,,HL,HL,h.streimann19@ejm.org
Tabet Elsa,F,HL,G4,NA,NA,e.tabet19@ejm.org
Tark Sehyun,F,SL,G4,NA,NA,s.tark19@ejm.org
Vilde Celeste,F,NA,,NA,SL,c.vilde19@ejm.org
Wen Chih-Liang,M,NA,,SL,HL,c.wen19@ejm.org
Yang Jingjie,M,NA,,HL,HL,j.yang19@ejm.org
Ypma Louis,M,NA,,NA,HL,l.ypma19@ejm.org
Zunino Lavinia,F,HL,G4,HL,NA,l.zunino19@ejm.org""";

bool isNull(String s) => s.length == 0 || s == "NA";

const List<String> _strongLeaders = [
  "Amar Paul Benjamin",
  "Cavrel Sara",
  "Chung Byeola",
  "Corvalan Myrna-Paula",
  "Evgeniou Lilia",
  "Gillot Edern",
  "Hellouin De Menibus George",
  "Lecommandeur Louise",
  "Maghraoui Lena",
  "Mire Adrien",
  "Picard Théo",
  "Somaini Cardelus Federico",
  "Streimann Helena",
  "Yang Jingjie"
];

List<Student> promo2019 = _getPromo2019();

List<Student> _getPromo2019() {
  List<Student> promo = <Student>[];
  for (String row in _promo2019CSV.split('\n').sublist(1)) {
    "Student,M/F,BIO Level,BIO Group,CHM Level,PHY Level,email";
    List<String> fields = row.split(',');
    Subject group4Subject, group6Subject;
    Level group4Level, group6Level;

    if (!isNull(fields[2])) {
      group4Subject = Subject.BIO;
      group4Level = fields[2] == "SL" ? Level.SL : Level.HL;
    } else {
      group4Subject = Subject.PHY;
      group4Level = fields[5] == "SL" ? Level.SL : Level.HL;
    }

    if (!isNull(fields[4])) {
      group6Subject = Subject.CHM;
      group6Level = fields[4] == "SL" ? Level.SL : Level.HL;
    }

    promo.add(Student(
        name: fields[0],
        profile: Profile(
          gender: fields[1] == "M" ? Gender.M : Gender.F,
          group4Subject: group4Subject,
          group4Level: group4Level,
          group6Subject: group6Subject,
          group6Level: group6Level,
          isStrongLeader: _strongLeaders.contains(fields[0]),
        )));
  }
  return promo;
}

Student findFrom(List<Student> promo, String name) {
  for (Student student in promo) {
    if (student.name == name) return student;
  }
  return null;
}

Grouping fromList(List<Student> promo, List<List<String>> groups) => Grouping(
    groups
        .map((List<String> group) =>
            group.map((String name) => findFrom(promo, name)).toList())
        .toList());

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
    var errors = <List<String>>[];
    for (List<Student> group in grouping.groups) {
      var groupErrors = <String>[];
      var groupStats = GroupStats.of(group);
      var sizeCoeff = group.length / promo.length;

      double idealMaleCount = promoStats.maleCount * sizeCoeff;
      double idealFemaleCount = promoStats.femaleCount * sizeCoeff;
      double idealBioCount = promoStats.bioCount * sizeCoeff;
      double idealChmCount = promoStats.chmCount * sizeCoeff;
      double idealPhyCount = promoStats.phyCount * sizeCoeff;
      double idealSLCount = promoStats.slCount * sizeCoeff;
      double idealHLCount = promoStats.hlCount * sizeCoeff;
      double idealLeadersCount = promoStats.strongLeadersCount * sizeCoeff;

      if ((groupStats.maleCount - idealMaleCount).abs() >= 1)
        groupErrors.add("Expected around ${idealMaleCount.toStringAsFixed(2)} "
            "males; got ${groupStats.maleCount}");
      if ((groupStats.femaleCount - idealFemaleCount).abs() >= 1)
        groupErrors
            .add("Expected around ${idealFemaleCount.toStringAsFixed(2)} "
                "females; got ${groupStats
            .femaleCount}");

      if ((groupStats.bioCount - idealBioCount).abs() >= 1)
        groupErrors.add("Expected around ${idealBioCount.toStringAsFixed(2)} "
            "biologists; got ${groupStats.bioCount}");
      if ((groupStats.chmCount - idealChmCount).abs() >= 1)
        groupErrors
            .add("Expected around ${idealChmCount.toStringAsFixed(2)} chemists;"
                " got ${groupStats.chmCount}");
      if ((groupStats.phyCount - idealPhyCount).abs() >= 1)
        groupErrors.add("Expected around ${idealPhyCount.toStringAsFixed(2)} "
            "physicists; got ${groupStats.phyCount}");

      if ((groupStats.slCount - idealSLCount).abs() >= 1)
        groupErrors
            .add("Expected around ${idealSLCount.toStringAsFixed(2)} SLs; "
                "got ${groupStats.slCount}");
      if ((groupStats.hlCount - idealHLCount).abs() >= 1)
        groupErrors
            .add("Expected around ${idealHLCount.toStringAsFixed(2)} HLs; "
                "got ${groupStats.hlCount}");

      if ((groupStats.strongLeadersCount - idealLeadersCount).abs() >= 1)
        groupErrors.add(
            "Expected around ${idealLeadersCount.toStringAsFixed(2)} strong "
            "leaders; got ${groupStats.strongLeadersCount}");

      errors.add(groupErrors);
    }
    return errors;
  }
}
