// Update Modules Key Dependencies
public class CustomScriptException extends Exception {}

List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();

List<FieloELR__Module__c> modulesToUpdate = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__KeyDependencies__c like '_______________,%' OR FieloELR__KeyDependencies__c like '_______________' LIMIT 1];

Set<Id> predecessors = new Set<Id>();

if (modulesToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__Module__c m: [SELECT Id, (SELECT FieloELR__Predecessor__c FROM FieloELR__PredecessorModules__r WHERE FieloELR__Predecessor__r.FieloELR__IsActive__c = true ORDER BY Id) FROM FieloELR__Module__c WHERE FieloELR__KeyDependencies__c like '_______________,%' OR FieloELR__KeyDependencies__c like '_______________' LIMIT 10000]) {
        if (!m.FieloELR__PredecessorModules__r.isEmpty()) {
            predecessors.clear();
            for (FieloELR__ModuleDependency__c md: m.FieloELR__PredecessorModules__r) {
                predecessors.add(md.FieloELR__Predecessor__c);
            }
            modules.add(
                new FieloELR__Module__c(
                    Id = m.Id,
                    FieloELR__KeyDependencies__c = String.join(new List<Id>(predecessors), ',')
                )
            );
        } else {
            modules.add(
                new FieloELR__Module__c(
                    Id = m.Id,
                    FieloELR__KeyDependencies__c = ''
                )
            );
        }
    }
    if (!modules.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update modules;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}