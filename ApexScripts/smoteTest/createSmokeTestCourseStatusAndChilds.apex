Id memberId = [SELECT Id FROM FieloPLT__Member__c WHERE FieloPLT__Program__r.Name = 'Training Center' LIMIT 1].Id;

Id courseId = 'a0j6A000003nbRXQAY';

// delete [Select Id From FieloELR__CourseStatus__c Where FieloELR__Course__c = :courseId AND FieloELR__Member__c = :memberId];

List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();
List<FieloELR__QuestionResponse__c> questionResponses = new List<FieloELR__QuestionResponse__c>();
List<FieloELR__Answer__c> answers = new List<FieloELR__Answer__c>();
List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();

//Course Status
//courseStatus = [SELECT Id FROM FieloELR__CourseStatus__c WHERE FieloELR__Course__c = :courseId AND FieloELR__Member__c = :memberId];

/*if (courseStatus.isEmpty()) {
    courseStatus.add(new FieloELR__CourseStatus__c(FieloELR__Course__c = courseId, FieloELR__Member__c = memberId));
    insert courseStatus;
}*/

modules = [SELECT Id, Name, (SELECT Id FROM FieloELR__Questions__r) FROM FieloELR__Module__c WHERE FieloELR__Course__c = :courseId ORDER BY Name];

Map<Id, FieloELR__Module__c> modulesMap = new Map<Id, FieloELR__Module__c>(modules);

Map<Id, FieloELR__Question__c> questionMap = new Map<Id, FieloELR__Question__c>(
    [SELECT Id, Name, FieloELR__Type__c, (SELECT Id, FieloELR__Question__c, FieloELR__IsCorrect__c, FieloELR__AnswerOptionText__c FROM FieloELR__AnswerOptions__r WHERE FieloELR__IsCorrect__c = true) FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id in :modules]
);

//Module Response
for (FieloELR__Module__c module: modules) {
    FieloELR__ModuleResponse__c mr = new FieloELR__ModuleResponse__c(FieloELR__Module__c = module.Id, FieloELR__Member__c = memberId);

    insert mr;

    questionResponses.clear();
    for (FieloELR__Question__c q: modulesMap.get(mr.FieloELR__Module__c).FieloELR__Questions__r) {
        questionResponses.add(
            new FieloELR__QuestionResponse__c(
                FieloELR__Question__c = q.Id,
                FieloELR__ModuleResponse__c = mr.Id
            )
        );
        answers.clear();
        for (FieloELR__AnswerOption__c ao: questionMap.get(q.Id).FieloELR__AnswerOptions__r) {
            if (questionMap.get(q.Id).FieloELR__Type__c == 'Short Answer') {
                if (ao.FieloELR__Question__c == q.Id && ao.FieloELR__IsCorrect__c) {
                    questionResponses.get(questionResponses.size()-1).FieloELR__TextValue__c = ao.FieloELR__AnswerOptionText__c;
                    break;
                }
            }
        }
    }

    insert questionResponses;

    for(FieloELR__QuestionResponse__c qr: questionResponses) {
        for (FieloELR__AnswerOption__c ao: questionMap.get(qr.FieloELR__Question__c).FieloELR__AnswerOptions__r) {
            if (questionMap.get(qr.FieloELR__Question__c).FieloELR__Type__c != 'Short Answer') {
                if (ao.FieloELR__Question__c == qr.FieloELR__Question__c && ao.FieloELR__IsCorrect__c) {
                    answers.add(
                        new FieloELR__Answer__c(
                            FieloELR__QuestionResponse__c = qr.Id,
                            FieloELR__AnswerOption__c = ao.Id
                        )
                    );
                }
            }
        }
    }

    if (!answers.isEmpty()) {
        insert answers;
    }

    update new FieloELR__ModuleResponse__c(
        Id = mr.Id,
        FieloELR__IsSubmitted__c = true
    );
}