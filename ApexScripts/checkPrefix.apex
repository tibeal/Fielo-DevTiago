System.debug(
  Schema.describeSObjects(new String[]{'Attachment','ContentDocument'})[0].getDescribe().getKeyPrefix()
);


List<Schema.DescribeSObjectResult> describes = Schema.describeSObjects(new String[]{'Attachment','ContentDocument'}); //[0].getDescribe().getKeyPrefix();
String attachmentPrefix;
String contentDocumentPrefix;
for (Schema.DescribeSObjectResult d: describes) {
  if(d.getName()=='Attachment') {
    attachmentPrefix = d.getKeyPrefix();
  }
  if(d.getName()=='ContentDocument') {
    contentDocumentPrefix = d.getKeyPrefix();
  }
}

System.debug(
  'attachmentPrefix => ' + attachmentPrefix
);

System.debug(
  'contentDocumentPrefix => ' + contentDocumentPrefix
);


'a0f46000001xwToAAI'.substring(0,3);
