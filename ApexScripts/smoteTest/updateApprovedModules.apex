List<FieloELR__CourseStatus__c> csList = [SELECT Id, (SELECT ExternalKey__c FROM FieloELR__ModuleResponses__r WHERE FieloELR__IsApproved__c = true AND FieloELR__NumberOfApprove__c = 1) FROM FieloELR__CourseStatus__c Where FieloELR__Progress__c > 1 AND FieloELR__Course__r.FieloELR__Status__c = 'Active'];
Set<String> approvedModules = new Set<String>();
List<FieloELR__CourseStatus__c> updateList = new List<FieloELR__CourseStatus__c>();
for(FieloELR__CourseStatus__c cs :csList) {
    approvedModules.clear();
    for (FieloELR__ModuleResponse__c mr: cs.FieloELR__ModuleResponses__r) {
        approvedModules.add(mr.ExternalKey__c);
    }
    updateList.add(
        new FieloELR__CourseStatus__c(
            Id = cs.Id,
            FieloELR__ApprovedModules__c = approvedModules.size()
        )
    );
}

if (!updateList.isEmpty()) {
    FieloELR.CourseService.enableAdminPermission(true);
    update updateList;
    FieloELR.CourseService.enableAdminPermission(false);
}
