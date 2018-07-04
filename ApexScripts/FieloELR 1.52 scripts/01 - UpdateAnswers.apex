// Update Answers
public class CustomScriptException extends Exception {}

List<FieloELR__Answer__c> answers = new List<FieloELR__Answer__c>();

List<FieloELR__Answer__c> answersToUpdate = [SELECT Id, FieloELR__AnswerOption__c, FieloELR__QuestionResponse__c FROM FieloELR__Answer__c WHERE FieloELR__ExternalKey__c = '' LIMIT 1];

if (answersToUpdate.isEmpty()) {
    throw new CustomScriptException('No Rows Found');
} else {
    for(FieloELR__Answer__c a: [SELECT Id, FieloELR__AnswerOption__c, FieloELR__QuestionResponse__c FROM FieloELR__Answer__c WHERE FieloELR__ExternalKey__c = '' LIMIT 10000]) {
        answers.add(
            new FieloELR__Answer__c(
                Id = a.Id,
                FieloELR__ExternalKey__c = String.valueOf(a.FieloELR__QuestionResponse__c) + String.valueOf(a.FieloELR__AnswerOption__c)
            )
        );
    }
    if (!answers.isEmpty()) {
        FieloELR.CourseService.enableAdminPermission(true);
        update answers;
        FieloELR.CourseService.enableAdminPermission(false);
    }
}