public class F_RewardingSummaryUpdateBatch implements Database.Batchable<sObject> {
    
    public Set<Id> transactionIds;
    public String whereClause;

    public F_RewardingSummaryUpdateBatch(){}

    public F_RewardingSummaryUpdateBatch(Set<Id> transactionIds){
            this.transactionIds = transactionIds;
    }

    public F_RewardingSummaryUpdateBatch(String whereClause){
        this.whereClause = whereClause;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, FieloPLT__Member__c FROM FieloPLT__Transaction__c';

        if(transactionIds != null && !transactionIds.isEmpty()){
            query += ' WHERE Id IN: transactionIds';
        }

        if(String.isNotBlank(whereClause)) {
            query += query.contains('WHERE Id IN') ? ' AND' : ' WHERE';
            query += ' (' + whereClause + ')';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> memberIds = new Set<Id>();
        Set<Id> transactionsProcessedIds = new Set<Id>();
        
        for(FieloPLT__Transaction__c t : (List<FieloPLT__Transaction__c>)scope){
            memberIds.add(t.FieloPLT__Member__c);
            transactionsProcessedIds.add(t.Id);
        }

        String query = 'SELECT Id, FieloPLT__RewardingSummary__c, FieloPLT__Member__c, (SELECT Id, Name, FieloPLT__Balance__c, FieloPLT__Member__c, FieloPLT__Rule__c, FieloPLT__ChallengeReward__c, FieloPLT__PointType__c, FieloPLT__Status__c, FieloPLT__Transaction__c ,FieloPLT__TotalPoints__c ,FieloPLT__UsedPoints__c FROM FieloPLT__Points__r), (SELECT Id, FieloPLT__Description__c, FieloPLT__Member__c, FieloPLT__Rule__c, FieloPLT__ChallengeReward__c, FieloPLT__Status__c, FieloPLT__Transaction__c FROM FieloPLT__Redemptions__r), (SELECT Id, Name, FieloPLT__Badge__c, FieloPLT__Rule__c, FieloPLT__ChallengeReward__c, FieloPLT__Member__c, FieloPLT__Quantity__c, FieloPLT__Status__c FROM FieloPLT__BadgesMembers__r) FROM FieloPLT__Transaction__c WHERE Id in :transactionsProcessedIds';

        List<FieloPLT__Transaction__c> transactions = (List<FieloPLT__Transaction__c>) Database.query(query);

        Boolean hasRules = [SELECT Id FROM FieloPLT__Rule__c LIMIT 1].size() > 0 ? true : false;

        //Searches Rules
        Map<Id, FieloPLT__Rule__c> rulesMap;
        if( hasRules ){
            Map<String, Schema.SObjectField> ruleFieldsMap = Schema.SObjectType.FieloPLT__Rule__c.fields.getMap();
            String queryRules = 'SELECT ';
            for (String fieldName: ruleFieldsMap.keySet()) {
                queryRules += ','+fieldName;
            }
            queryRules = queryRules.replaceFirst(',','');
            queryRules += ' FROM FieloPLT__Rule__c';
            rulesMap = new Map<Id, FieloPLT__Rule__c>( (List<FieloPLT__Rule__c>)Database.query(queryRules));
        }

        Map<Id, FieloPLT__PointType__c> pointTypesMap = new Map<Id, FieloPLT__PointType__c>( [SELECT Id, Name FROM FieloPLT__PointType__c] );
        Map<Id, FieloPLT__Member__c> membersMap = new Map<Id, FieloPLT__Member__c>( [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Id In: memberIds]);
        
        for(FieloPLT__Transaction__c t : transactions){
            //Transaction JSON file
            Map<String, Map<String,Sobject>> rewardingJSON = new Map<String, Map<String,Sobject>>();
            if( String.isBlank(t.FieloPLT__RewardingSummary__c) ){
                Map<Id, String> reflectionClasses = new Map<Id, String>();
                //Adds Points to the JSON file
                for(FieloPLT__Point__c p : t.FieloPLT__Points__r ){
                    //For Rules
                    if( p.FieloPLT__Rule__c != null ){
                        if( rewardingJSON.containsKey( String.valueOf(rulesMap.get(p.FieloPLT__Rule__c).Name) ) ){
                            rewardingJSON.get( String.valueOf(rulesMap.get(p.FieloPLT__Rule__c).Name) ).put( String.valueOf( pointTypesMap.get(p.FieloPLT__PointType__c).Name), p );
                        } else {
                            Map<String,SObject> aux = new Map<String,SObject>();
                            aux.put( 'rule', rulesMap.get(p.FieloPLT__Rule__c) );
                            aux.put( String.valueOf( pointTypesMap.get(p.FieloPLT__PointType__c).Name), p );
                            rewardingJSON.put(String.valueOf(rulesMap.get(p.FieloPLT__Rule__c).Name), aux );
                        }
                    } else {
                        //For Adjust Transactions
                        if( rewardingJSON.containsKey( 'adjust' ) ){
                            rewardingJSON.get( 'adjust' ).put( String.valueOf( pointTypesMap.get(p.FieloPLT__PointType__c).Name), p );
                        } else {
                            Map<String,SObject> aux = new Map<String,SObject>();
                            aux.put( String.valueOf( pointTypesMap.get(p.FieloPLT__PointType__c).Name), p );
                            rewardingJSON.put('adjust', aux );
                        }
                    }
                }

                //Adds Badge Members to JSON file
                for(FieloPLT__BadgeMember__c bm : t.FieloPLT__BadgesMembers__r){
                    //For Rules
                    if( bm.FieloPLT__Rule__c != null ){
                        if( rewardingJSON.containsKey( String.valueOf(rulesMap.get(bm.FieloPLT__Rule__c).Name) ) ){
                            rewardingJSON.get( String.valueOf(rulesMap.get(bm.FieloPLT__Rule__c).Name) ).put( 'badgeMember', bm );
                        } else {
                            Map<String,SObject> aux = new Map<String,SObject>();
                            aux.put( 'rule', rulesMap.get(bm.FieloPLT__Rule__c) );
                            aux.put( 'badgeMember', bm );
                            rewardingJSON.put(String.valueOf(rulesMap.get(bm.FieloPLT__Rule__c).Name), aux );
                        }
                    }
                }
                
                t.FieloPLT__RewardingSummary__c = JSON.serialize(rewardingJSON);
            }
        }

        fieloplt.SobjectService.enableAdminPermission(true);
        update transactions;
    }
    
    public void finish(Database.BatchableContext BC) {
    }
}