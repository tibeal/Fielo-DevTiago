FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__r.Name = 'Developers Program' LIMIT 1];

FieloELR.ModuleService.ModuleWrapper moduleWrapper = FieloELR.ModuleService.takeModule(
    'a0m6A000006lJaNQAU',
    member.Id,
    new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
    new Set<String> {'FieloELR__QuestionText__c'},
    new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c'}
);
system.debug(
  JSON.serializePretty(moduleWrapper)
);