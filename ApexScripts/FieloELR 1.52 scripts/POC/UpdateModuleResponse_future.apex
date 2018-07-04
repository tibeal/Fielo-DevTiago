// Update Module Response
public class CustomScriptException extends Exception {}

List<Id> mrIds = new List<Id>();

List<FieloELR__ModuleResponse__c> mrToUpdate = [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (mrToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__ModuleResponse__c mr: [SELECT Id FROM FieloELR__ModuleResponse__c WHERE FieloELR__ExternalKey__c = '' LIMIT 49999]) {
        mrIds.add(mr.Id);
        if (math.mod(mrIds.size(),10000)==0) {
            UpdateHandler.updateModuleResponse(mrIds);
            mrIds.clear();
        }
    }
    if (!mrIds.isEmpty()) {
        UpdateHandler.updateModuleResponse(mrIds);
    }
}