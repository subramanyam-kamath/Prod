trigger AccountAddressTrigger on Account (before insert, before update) {

List<Account> UpdateAccount  =new List<Account>([Select Id,BillingPostalCode,ShippingPostalCode,Match_Billing_Address__c from Account where Id IN:Trigger.new]);

{
for(Account a : trigger.new){
If(a.Match_Billing_Address__c==true ){
a.ShippingPostalCode=a.BillingPostalCode;

}
}

}
}