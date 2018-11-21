// This Code shoudl be run unter the page ModuleResponseView
Visualforce.remoting.Manager.invokeAction(
    'FieloELR.ModuleResponseViewController.retrieve',
    'FieloELR__ModuleResponse__c',
    'a0s6A000001fhFFQAY',
    'Id, Name, FieloELR__Module__c, FieloELR__Module__r.Name, FieloELR__GradePercent__c, FieloELR__Member__c, FieloELR__Member__r.Name',
    function(result){
        console.log(JSON.stringify(result, null, 2));
    },
    {
        escape: false
    }
);