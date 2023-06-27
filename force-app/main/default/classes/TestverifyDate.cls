@isTest

private class TestverifyDate{

@isTest static void testCheckDate(){

Date myDate1 = Date.newInstance(2022, 07, 21);
Date myDate2 = Date.newInstance(2022,07,28);
Date myDate5 = verifyDate.CheckDates (myDate1, myDate2);

System.assertEquals(Date.newInstance(2022,07,28), myDate5);

}

@isTest private static void testCheckDat2e() {

Date myDate1 = date.newInstance(2022, 08, 21);
Date myDate2 = date.newInstance(2022,07,21);
Date myDate5 = verifyDate.CheckDates (myDate1, myDate2);

System.assertEquals(date.newInstance(2022,08,31), myDate5);

}

@isTest static void testCheckDate3(){

Date myDate1 = date.newInstance(2022, 08, 21);
Date myDate2 = date.newInstance(2022,08,21);
Date myDate5 = verifyDate.CheckDates (myDate1, myDate2);

System.assertEquals(date.newInstance(2022,08,21), myDate5);

}
}