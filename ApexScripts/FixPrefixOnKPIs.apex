List<FieloPLT__KPI__c> stdKPIs = [SELECT Id, FieloPLT__ReportUniqueName__c FROM FieloPLT__KPI__c WHERE FieloPLT__ReportType__c = 'Standard'];

for (FieloPLT__KPI__c kpi: stdKPIs) {
  if (kpi.FieloPLT__ReportUniqueName__c.left('fieloplt__'.length()).equals('fieloplt__')) {
    kpi.FieloPLT__ReportUniqueName__c = kpi.FieloPLT__ReportUniqueName__c.replace('fieloplt__','FieloPLT__');
  }
}
update stdKPIs;
