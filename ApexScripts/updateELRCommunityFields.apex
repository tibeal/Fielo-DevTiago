List<FieloELR__Module__c> modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__Course__c != null];

for(FieloELR__Module__c module: modules) {
    module.FieloELR__QuestionDisplayMode__c = 'One by one';
    module.FieloELR__QuestionSubmissionMode__c = 'One by one';
    module.FieloELR__GiveImmediateFeedback__c = true;
}

CourseService.enableAdminPermission(true);
update modules;
CourseService.enableAdminPermission(false);