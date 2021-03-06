global without sharing class FieloCMSPRP_ApprovalHistoryAPI implements FieloCMS.DataInterface{
    global Map<Id, Object> getBulkData(List<FieloCMS__Component__c> components){
        Map<Id,Object> newMapData = new Map<Id,Object>();
        List<ProcessInstanceStep> pis = new List<ProcessInstanceStep>();
        List<Note> notes = new List<Note>();
        String recordId = '';
        for(FieloCMS__Component__c c : components){
            if(c.FieloCMS__Limit__c == null)
                c.FieloCMS__Limit__c = 5;

            recordId = ApexPages.CurrentPage().getParameters().get( c.FieloCMS__DetailParameter__c );

            String query = 'SELECT Id,' +
                'TargetObjectid, ' +
                'Status, ' +
                '(select id,actor.name from Workitems), ' +
                '(SELECT Id, StepStatus, Comments,Actor.Name FROM Steps ORDER BY CreatedDate) ' +//WHERE StepStatus = \'Rejected\'
                'FROM ProcessInstance where TargetObjectId = :recordId ORDER BY CreatedDate';

            for(ProcessInstance pi: (List<ProcessInstance>)Database.query(query) ){
                if (pi.Steps != null) {
                    if (!pi.Steps.isEmpty()) {
                        for (ProcessInstanceStep step: pi.Steps) {
                            notes.add(
                                new Note(
                                    Title = step.StepStatus,
                                    Body = step.Comments
                                )
                            );
                        }
                    }
                }
            }

            newMapData.put(c.Id,(Object) notes);

        }
        return newMapData;
    }

    global List<sObject> getData(FieloCMS__Component__c component, Integer pageNumber, String orderBy, String filters){
        return null;
    }
}
