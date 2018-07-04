// Update Courses Key Dependencies
public class CustomScriptException extends Exception {}

List<FieloELR__Course__c> courses = new List<FieloELR__Course__c>();

List<FieloELR__Course__c> coursesToUpdate = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__KeyDependencies__c like '_______________,%' OR FieloELR__KeyDependencies__c like '_______________' LIMIT 1];

Set<Id> predecessors = new Set<Id>();

if (coursesToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__Course__c c: [SELECT Id, (SELECT FieloELR__Predecessor__c FROM FieloELR__PredecessorCourses__r WHERE FieloELR__Predecessor__r.FieloELR__Status__c = 'Active' ORDER BY Id) FROM FieloELR__Course__c WHERE FieloELR__KeyDependencies__c like '_______________,%' OR FieloELR__KeyDependencies__c like '_______________' LIMIT 10000]) {
        if (!c.FieloELR__PredecessorCourses__r.isEmpty()) {
            predecessors.clear();
            for (FieloELR__CourseDependency__c cd: c.FieloELR__PredecessorCourses__r) {
                predecessors.add(cd.FieloELR__Predecessor__c);
            }
            courses.add(
                new FieloELR__Course__c(
                    Id = c.Id,
                    FieloELR__KeyDependencies__c = String.join(new List<Id>(predecessors), ',')
                )
            );
        }
    }
    if (!courses.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update courses;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}