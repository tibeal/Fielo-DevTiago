// Update Course Status
public class CustomScriptException extends Exception {}

List<FieloELR__CourseStatus__c> courseStatuses = new List<FieloELR__CourseStatus__c>();

List<FieloELR__CourseStatus__c> csToUpdate = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = '' AND FieloELR__Course__r.FieloELR__Status__c = 'Active' LIMIT 1];

if (csToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__CourseStatus__c cs: [SELECT Id, FieloELR__Course__c, FieloELR__Member__c FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = '' AND FieloELR__Course__r.FieloELR__Status__c = 'Active' LIMIT 10000]) {
        courseStatuses.add(
            new FieloELR__CourseStatus__c(
                Id = cs.Id,
                FieloELR__ExternalKey__c = String.valueOf(cs.FieloELR__Course__c) + String.valueOf(cs.FieloELR__Member__c)
            )
        );
    }
    if (!courseStatuses.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update courseStatuses;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}