// Update Module Response
public class CustomScriptException extends Exception {}

List<FieloELR__ModuleResponse__c> moduleResps = new List<FieloELR__ModuleResponse__c>();

List<FieloELR__ModuleResponse__c> mrToUpdate = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (mrToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__ModuleResponse__c mr: [SELECT Id, FieloELR__Module__c, FieloELR__Member__c FROM FieloELR__ModuleResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 10000]) {
        moduleResps.add(
            new FieloELR__ModuleResponse__c(
                Id = mr.Id,
                FieloELR__ExternalKey__c = String.valueOf(mr.FieloELR__Module__c) + String.valueOf(mr.FieloELR__Member__c)
            )
        );
    }
    if (!moduleResps.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update moduleResps;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}