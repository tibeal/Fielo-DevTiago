FieloELR__Course__c course = [SELECT Id, FieloELR__Program__c FROM FieloELR__Course__c WHERE Id = 'a0j6A000002bNl9QAE'];
FieloPLT__Member__c member = [SELECT Id FROM FieloPLT__Member__c WHERE FieloPLT__Program__c = :course.FieloELR__Program__c LIMIT 1];

System.debug(
  JSON.serializePretty(
    FieloELR.CourseService.getCourses(
        new Set<String>{'Id','Name','FieloELR__Status__c'},
        null,
        new Set<String>{'Id','Name'},
        null,
        course.FieloELR__Program__c,
        member.Id,
        true,
        true,
        true,
        10,
        0,
        'LastModifiedDate',
        ''
    )
  )
);
