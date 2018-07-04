// Update Course Dependency
public class CustomScriptException extends Exception {}

List<FieloELR__CourseDependency__c> courseDeps = new List<FieloELR__CourseDependency__c>();

List<FieloELR__CourseDependency__c> cdToUpdate = [SELECT Id FROM FieloELR__CourseDependency__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (cdToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__CourseDependency__c cd: [SELECT Id, FieloELR__Course__c, FieloELR__Predecessor__c FROM FieloELR__CourseDependency__c WHERE FieloELR__ExternalKey__c = '' LIMIT 10000]) {
        courseDeps.add(
            new FieloELR__CourseDependency__c(
                Id = cd.Id,
                FieloELR__ExternalKey__c = ((string)cd.FieloELR__Course__c) + ((string)cd.FieloELR__Predecessor__c)
            )
        );
    }
    if (!courseDeps.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update courseDeps;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}