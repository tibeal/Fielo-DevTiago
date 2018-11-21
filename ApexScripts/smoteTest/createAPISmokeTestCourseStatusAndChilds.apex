Id courseId = 'a285E000000MVNGQA4';

FieloELR__Course__c course = [SELECT Id, FieloELR__Program__c FROM FieloELR__Course__c WHERE Id = :courseId];

Id memberId = [SELECT Id FROM FieloPLT__Member__c WHERE FieloPLT__Program__c = :course.FieloELR__Program__c LIMIT 1].Id;

List<FieloELR__CourseStatus__c> courseStatus = new List<FieloELR__CourseStatus__c>();
List<FieloELR__QuestionResponse__c> questionResponses = new List<FieloELR__QuestionResponse__c>();
List<FieloELR__Answer__c> answers = new List<FieloELR__Answer__c>();
List<FieloELR__ModuleResponse__c> moduleResponses = new List<FieloELR__ModuleResponse__c>();
List<FieloELR__Module__c> modules = new List<FieloELR__Module__c>();

modules = [SELECT Id, Name, (SELECT Id FROM FieloELR__Questions__r) FROM FieloELR__Module__c WHERE FieloELR__Course__c = :courseId ORDER BY Name];

Map<Id, FieloELR__Module__c> modulesMap = new Map<Id, FieloELR__Module__c>(modules);

Map<Id, FieloELR__Question__c> questionMap = new Map<Id, FieloELR__Question__c>(
    [SELECT Id, Name, FieloELR__Type__c, (SELECT Id, FieloELR__Question__c, FieloELR__IsCorrect__c, FieloELR__AnswerOptionText__c FROM FieloELR__AnswerOptions__r WHERE FieloELR__IsCorrect__c = true) FROM FieloELR__Question__c WHERE FieloELR__Module__r.Id in :modules]
);

//Module Response
FieloELR.ModuleService.ModuleWrapper mw;
for (FieloELR__Module__c module: modules) {
    mw = FieloELR.ModuleService.takeModule(
        module.Id,
        memberId,
        new Set<String> {'Id', 'FieloELR__AttemptsAllowed__c'},
        new Set<String> {'FieloELR__QuestionText__c'},
        new Set<String> {'FieloELR__AnswerOptionText__c','FieloELR__MatchingText__c'}
    );

    FieloELR__ModuleResponse__c mr = mw.moduleResponse;

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

    /* update new List<FieloELR__ModuleResponse__c> {
        new FieloELR__ModuleResponse__c(
            Id = mr.Id,
            FieloELR__IsSubmitted__c = true
        )
    }; */
}