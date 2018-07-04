// Update Question Response
public class CustomScriptException extends Exception {}

List<Id> qrIds = new List<Id>();

List<FieloELR__QuestionResponse__c> qrToUpdate = [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (qrToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__QuestionResponse__c qr: [SELECT Id FROM FieloELR__QuestionResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 50000]) {
        qrIds.add(qr.Id);
        if (math.mod(qrIds.size(),10000)==0) {
            UpdateHandler.updateRecords(qrIds);
            qrIds.clear();
        }
    }
}