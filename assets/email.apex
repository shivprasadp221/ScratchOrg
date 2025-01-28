String recipient = '{{recipient}}';
String orgDetails = '{{orgDetails}}';
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new String[] {recipient});
mail.setSubject('New scratch org has been created.');
mail.setPlainTextBody(orgDetails+'.');
Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
