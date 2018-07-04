// Update Course Status
public class CustomScriptException extends Exception {}

List<Id> csIds = new List<Id>();

List<FieloELR__CourseStatus__c> csToUpdate = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (csToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__CourseStatus__c cs: [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__ExternalKey__c = '' LIMIT 49999]) {
        csIds.add(cs.Id);
        if (math.mod(csIds.size(),10000)==0) {
            UpdateHandler.updateCourseStatus(csIds);
            csIds.clear();
        }
    }
    if (!csIds.isEmpty()) {
        UpdateHandler.updateCourseStatus(csIds);
    }
}