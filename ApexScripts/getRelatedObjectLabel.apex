System.debug(
  Schema.describeSObjects(new String[]{ 'FieloPRP__InvoiceItem__c' })
    .get(0).fields.getMap()
    .get('FieloPRP__Product__c')
    .getDescribe().getReferenceTo()[0].getDescribe().getLabelPlural()
);
