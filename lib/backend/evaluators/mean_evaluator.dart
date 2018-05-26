import '../evaluator.dart';
import '../utils.dart';

class MeanEvaluator implements Evaluator {
  @override
  Promo promo;

  MeanEvaluator(this.promo);

  @override
  List<List<String>> findIssues(Grouping grouping) {
    GroupStats promoStats = GroupStats.of(promo.students);
    var errors = <List<String>>[];
    for (List<Student> group in grouping.groups) {
      var groupErrors = <String>[];
      var groupStats = GroupStats.of(group);
      var sizeCoeff = group.length / promo.students.length;

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
