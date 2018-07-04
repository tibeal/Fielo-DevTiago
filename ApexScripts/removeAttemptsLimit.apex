FieloELR.CourseService.enableAdminPermission(true);
List<FieloELR__Course__c> courses = [SELECT Id FROM FieloELR__Course__c WHERE FieloELR__Status__c = 'Active'];

for (FieloELR__Course__c c: courses) {
    c.FieloELR__Status__c = 'Inactive';
}

update courses;

List<FieloELR__Module__c> modules = [SELECT Id FROM FieloELR__Module__c WHERE FieloELR__IsActive__c = true];

for(FieloELR__Module__c m: modules) {
    m.FieloELR__IsActive__c = false;
}

update modules;

for(FieloELR__Module__c m: modules) {
    m.FieloELR__AttemptsAllowed__c = null;
    m.FieloELR__AttemptsAllowedPerQuestion__c = null;
}

update modules;

for(FieloELR__Module__c m: modules) {
    m.FieloELR__IsActive__c = true;
}

update modules;

for (FieloELR__Course__c c: courses) {
    c.FieloELR__Status__c = 'Active';
}

update courses;
FieloELR.CourseService.enableAdminPermission(false);