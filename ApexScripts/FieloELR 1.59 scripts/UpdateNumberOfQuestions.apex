List<FieloELR__Module__c> updModules = new List<FieloELR__Module__c>();

for (FieloELR__Module__c module: [SELECT Id, (SELECT Id FROM FieloELR__Questions__r) FROM FieloELR__Module__c]) {
    updModules.add(
        new FieloELR__Module__c(
            Id = module.Id,
            NumberOfQuestions__c = module.FieloELR__Questions__r.size()
        )
    );
}

if (!updModules.isEmpty())
    update updModules;