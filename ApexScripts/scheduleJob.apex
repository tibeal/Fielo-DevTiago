KPIDomainRenewalBatchSchedule c = new KPIDomainRenewalBatchSchedule();
String sch = String.format('0 {0} * * * ?', new List<String>{String.valueOf(System.now().minute()+2)});
String jobName = String.format('{6}_{0}-{1}-{2}T{3}:{4}:{5}',
  new List<String>{
    String.valueOf(System.now().year()),
    String.valueOf(System.now().month()),
    String.valueOf(System.now().day()),
    String.valueOf(System.now().hour()),
    String.valueOf(System.now().minute()),
    String.valueOf(System.now().second()),
    String.valueOf(c).split(':')[0]
  }
);
System.debug(jobName);
System.debug(sch);
System.schedule(jobName,  sch, c);
