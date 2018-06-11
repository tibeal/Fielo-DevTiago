// Generate Global Unique Identifier NOT AN ID !!!
public static String generateGUID(){
  	Blob b = Crypto.GenerateAESKey(128);
  	String h = EncodingUtil.ConvertTohex(b);
  	String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
  	return guid;
}

Integer s_num=0;

// Generate a Fake Id
public static String getFakeId(Schema.SObjectType sot) {
   String result = String.valueOf(s_num++);
   return sot.getDescribe().getKeyPrefix() +
      '0'.repeat(12-result.length()) + result;
}


//Sample
FieloPLT__Member__c member = new FieloPLT__Member__c(Id=getFakeId(FieloPLT__Member__c.SObjectType));

System.debug(
	JSON.serializePretty(member)
);
