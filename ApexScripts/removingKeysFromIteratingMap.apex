Map<Date, Integer> datesMap = new Map<Date, Integer>();

datesMap.put(System.today(), 1);
for (Integer i=1;i<=10;i++) {
    datesMap.put(System.today().addDays(i*(-1)), i + 1);
}

System.debug(
    JSON.serializePretty(datesMap)
);

Date periodDate = System.today().addDays(-2);

for( Date dt : datesMap.keyset() ) {
    if (dt < periodDate) {
        datesMap.remove(dt);
    }
}

System.debug(
    JSON.serializePretty(datesMap)
);