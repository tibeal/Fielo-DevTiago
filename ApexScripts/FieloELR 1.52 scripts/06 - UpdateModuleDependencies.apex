// Update Module Dependency
public class CustomScriptException extends Exception {}

List<FieloELR__ModuleDependency__c> moduleDeps = new List<FieloELR__ModuleDependency__c>();

List<FieloELR__ModuleDependency__c> mdToUpdate = [SELECT Id FROM FieloELR__ModuleDependency__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (mdToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__ModuleDependency__c md: [SELECT Id, FieloELR__Predecessor__c, FieloELR__Module__c FROM FieloELR__ModuleDependency__c WHERE FieloELR__ExternalKey__c = '' LIMIT 10000]) {
        moduleDeps.add(
            new FieloELR__ModuleDependency__c(
                Id = md.Id,
                FieloELR__ExternalKey__c = String.valueOf(md.FieloELR__Predecessor__c) + String.valueOf(md.FieloELR__Module__c)
            )
        );
    }
    if (!moduleDeps.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update moduleDeps;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}