import 'package:test/test.dart';

import 'package:group_m4ker/backend/utils.dart';
import 'package:group_m4ker/backend/generator.dart';
import 'package:group_m4ker/backend/evaluator.dart';

void main() {
  test("CSV", () {
    var jingjie = fromList(promo2019, [
      ["Yang Jingjie"]
    ]).groups[0][0];
    expect(jingjie.name, "Yang Jingjie");
    expect(jingjie.profile.gender, Gender.M);
    expect(jingjie.profile.group4Subject, Subject.PHY);
    expect(jingjie.profile.group4Level, Level.HL);
    expect(jingjie.profile.group6Subject, Subject.CHM);
    expect(jingjie.profile.group6Level, Level.HL);
    expect(jingjie.profile.isStrongLeader, true);

    var lilia = fromList(promo2019, [
      ["Evgeniou Lilia"]
    ]).groups[0][0];
    expect(lilia.name, "Evgeniou Lilia");
    expect(lilia.profile.gender, Gender.F);
    expect(lilia.profile.group4Subject, Subject.BIO);
    expect(lilia.profile.group4Level, Level.HL);
    expect(lilia.profile.group6Subject, Subject.CHM);
    expect(lilia.profile.group6Level, Level.HL);
    expect(lilia.profile.isStrongLeader, true);
  });

  test("Group evaluation", () {
    // Generated with previously implemented algorithm
    List<List<String>> groups = [
      [
        'Gillot Edern',
        'Alcufrom Winston',
        'Delmas Idil',
        'Nguyen Mia',
        'Mire Adrien',
        'Sawko Thais',
      ],
      [
        'Sarkozy De Nagy Bosca Arpad',
        'Esfandiari Nafsika',
        'Yang Jingjie',
        'Vilde Celeste',
        'Hibon Adrien Arya',
        'Mourouga Erell',
      ],
      [
        'Herbette Titouan',
        'Morel Gabriel',
        'Lazo Emily',
        'Rousselet Kayla',
        'Du Buisson Perrine Matthieu',
        'Cavrel Sara',
      ],
      [
        'Somaini Cardelus Federico',
        'Povse Matej',
        'Marenzi Cyrus',
        'Maghraoui Lena',
        'Ismail Natasha',
        'Fabian Ariane',
      ],
      [
        'Tabet Elsa',
        'Elfaizy-Phillips Theodorus',
        'Du Buisson Perrine Lucas',
        'Corvalan Myrna-Paula',
        'Isore William',
        'Ali Cherif Neila',
      ],
      [
        'Levy Gabrielle',
        'Hellouin De Menibus George',
        'Burnham Elliot',
        'Zunino Lavinia',
        'Ypma Louis',
        'Tark Sehyun',
      ],
      [
        'Maghraoui Sarah',
        'Prigent Colin',
        'Sauvage Gaspard',
        'Korchagin Antoine',
        'Higgins Kimberly',
        'Evgeniou Lilia',
      ],
      [
        'Picard Théo',
        'Dao Léo',
        'Ruggiero Eva',
        'Chung Byeola',
        'Du Buisson Perrine Hugo',
        'Bovard Andrea',
      ],
      [
        'Coulom Stella',
        'Amar Paul Benjamin',
        'Deneve Marc',
        'Streimann Helena',
        'Del Monte Giulio',
        'Salleras Adora',
      ],
      [
        'Wen Chih-Liang',
        'Lecommandeur Louise',
        'Spotnitz Amelia',
        'Makhotina Ilkay',
        'Amlani Lucca',
      ],
    ];
    var eva = MeanEvaluator(promo2019);
    print(eva.findIssues(fromList(promo2019, groups)));
  });

  test("Group generation", () {
    var gen = MinJealousyGenerator(promo2019);
    var eva = MeanEvaluator(promo2019);
    print(eva.findIssues(gen.generate()));
  });

  test("Profile", () {
    expect(
        Profile(
              gender: Gender.M,
              group4Subject: Subject.BIO,
              group4Level: Level.SL,
              isStrongLeader: false,
            ) ==
            Profile(
              gender: Gender.M,
              group4Subject: Subject.BIO,
              group4Level: Level.SL,
              isStrongLeader: false,
            ),
        true);
  });
}
