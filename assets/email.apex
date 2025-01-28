String orgDetails = '{{orgDetails}}';
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new String[] {'shivprasad.patil@chargebee.com'});
mail.setSubject('New scratch org has been created.');
mail.setPlainTextBody(orgDetails+'.');
Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
