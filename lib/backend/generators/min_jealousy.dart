import '../generator.dart';
import '../utils.dart';

/// Generates groups aiming to minimise the jealousy between groups.
///
/// Jealousy is described by the difference between the counts of
/// males, females, biologists, chemists, physicists, SLs, HLs, leaders
/// in each pair of groups.
class MinJealousyGenerator implements Generator {
  Promo promo;

  MinJealousyGenerator(this.promo);

  num diffGroups(List<Student> group1, List<Student> group2) {
    var cnt1 = GroupStats.of(group1);
    var cnt2 = GroupStats.of(group2);

    double diff = 0.0;
    diff += (cnt1.maleCount - cnt2.maleCount).abs();
    diff += (cnt1.femaleCount - cnt2.femaleCount).abs();

    diff += (cnt1.bioCount - cnt2.bioCount).abs();
    diff += (cnt1.chmCount - cnt2.chmCount).abs();
    diff += (cnt1.phyCount - cnt2.phyCount).abs();

    diff += (cnt1.slCount - cnt2.slCount).abs();
    diff += (cnt1.hlCount - cnt2.hlCount).abs();

    diff += (cnt1.strongLeadersCount - cnt2.strongLeadersCount).abs();

    return diff;
  }

  num evaluate(Grouping grouping) {
    num diff = 0;

    for (int i = 0; i < grouping.groups.length; i++) {
      for (int j = 0; j < i; j++) {
        diff += diffGroups(grouping.groups[i], grouping.groups[j]);
      }
    }

    return diff;
  }

  @override
  Grouping generate({int numberOfGroups: 10}) {
    List<List<Student>> groups = <List<Student>>[];
    for (int i = 0; i < numberOfGroups; i++) groups.add([]);
    List<Student> students = List.from(promo.students);
    students.shuffle();

    // Fill
    int i = 0;
    for (Student student in students) {
      groups[i].add(student);

      i++;
      if (i == numberOfGroups) i = 0;
    }
    Grouping gp = Grouping(groups);

    // Optimise
    while (true) {
      num currentScore = evaluate(gp);
      num bestScore = double.infinity;
      StudentPos bestPos1, bestPos2;

      for (int i = 0; i < gp.groups.length; i++) {
        for (int j = 0; j < i; j++) {
          for (int k = 0; k < gp.groups[i].length; k++) {
            for (int l = 0; l < gp.groups[j].length; l++) {
              var pos1 = StudentPos(i, k);
              var pos2 = StudentPos(j, l);
              gp.swap(pos1, pos2);
              num newScore = evaluate(gp);
              if (newScore < bestScore) {
                bestScore = newScore;
                bestPos1 = pos1;
                bestPos2 = pos2;
              }
              gp.swap(pos1, pos2);
            }
          }
        }
      }
      if (bestScore >= currentScore) {
        break;
      }

      gp.swap(bestPos1, bestPos2);
    }

    // Ensure no issues found
    /*if (MeanEvaluator(promo)
        .findIssues(gp)
        .where((List<String> issues) => issues.isNotEmpty)
        .isNotEmpty) {
      return generate(numberOfGroups: numberOfGroups);
    }*/

    return gp;
  }
}
