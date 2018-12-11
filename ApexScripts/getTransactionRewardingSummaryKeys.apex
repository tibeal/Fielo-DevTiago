FieloPLT__Transaction__c tran = [SELECT Id, RewardingSummary__c FROM FieloPLT__Transaction__c WHERE Id = 'a0r3B000001Hle4QAC'][0];

Map<String, Map<String,Sobject>> rewardingJSON = (Map<String, Map<String, Sobject>>)JSON.deserialize(tran.RewardingSummary__c, Map<String, Map<String,Sobject>>.class);

for(String clave : rewardingJSON.keySet()) {
    for(String rewardingType : rewardingJSON.get(clave).keySet()) {
        system.debug(rewardingType);
    }
}
