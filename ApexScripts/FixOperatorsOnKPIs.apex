public class ReportFilter {
    public String column {get;set;}
    public String operator {get;set;}
    public String value {get;set;}
}

List<FieloPLT__KPI__c> kpis = [SELECT Id, FieloPLT__ReportFilter__c FROM FieloPLT__KPI__c WHERE FieloPLT__ReportType__c = 'Standard'];
List<FieloPLT__KPI__c> updateKPIs = new List<FieloPLT__KPI__c>();

Boolean doUpdate;
for (FieloPLT__KPI__c kpi: kpis) {
    if (kpi.FieloPLT__ReportFilter__c != null) {
        List<Map<String,String>> filters = (List<Map<String,String>>)JSON.deserialize(kpi.FieloPLT__ReportFilter__c, List<Map<String,String>>.class);
        doUpdate = false;
        for (Map<String,String> f: filters) {
            if (!f.containsKey('Operator')) {
                f.put('Operator','equals');
                doUpdate = true;
            }
        }
        if (doUpdate) {
          kpi.FieloPLT__ReportFilter__c = JSON.serialize(filters);
          updateKPIs.add(kpi);
        }
    }
}
if (!updateKPIs.isEmpty()) {
  update kpis;
}
