// Update Question Response
public class CustomScriptException extends Exception {}

List<FieloELR__QuestionResponse__c> questionResps = new List<FieloELR__QuestionResponse__c>();

List<FieloELR__QuestionResponse__c> qrToUpdate = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (qrToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__QuestionResponse__c qr: [SELECT Id, FieloELR__Question__c, FieloELR__ModuleResponse__c FROM FieloELR__QuestionResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 10000]) {
        questionResps.add(
            new FieloELR__QuestionResponse__c(
                Id = qr.Id,
                FieloELR__ExternalKey__c = String.valueOf(qr.FieloELR__Question__c) + String.valueOf(qr.FieloELR__ModuleResponse__c)
            )
        );
    }
    if (!questionResps.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update questionResps;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}