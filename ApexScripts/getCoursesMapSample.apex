FieloPLT__Member__c member = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE FieloPLT__Program__r.Name = 'Developers Program' LIMIT 1];

System.debug(
  JSON.serializePretty(
    FieloELR.CourseService.getCoursesMap(
        new Set<String>{'Id','FieloELR__SubscriptionMode__c','FieloELR__Status__c'},
        new Set<String>{'Id','Name'},
        new Set<String>{'Id','Name'},
        null,
        null,
        member.FieloPLT__Program__c,
        member.Id,
        false,
        true,
        10,
        0,
        'LastModifiedDate',
        ''
    )
  )
);