System.debug( Schema.describeSObjects(new String[]{'ProcessInstanceHistory'})[0].fields.getMap().get('StepStatus').getDescribe().getLabel() );


Map<String,Schema.SObjectField> fieldMap = Schema.describeSObjects(new String[]{'ProcessInstance'})[0].fields.getMap();

for (String fieldName: fieldMap.keySet()) {
  system.debug(fieldName + ' = ' + fieldMap.get(fieldName).getDescribe().getLabel());
}
