public class CustomEmailSalesforce implements FieloPLT.EmailProvidersInterface {

    private class EmailResult{
       Messaging.SingleEmailMessage mail = null;
       String errorMessage = null;
    }   	

    // CUSTOMIZATION TAKES PLACE HERE - Add fromAddress parameter
	private EmailResult getSingleMessage(String toAddress, EmailTemplate emailTemplate, Map<String,String> dataValues){
		
        EmailResult emailResult = new EmailResult(); 

		// Create new email message object.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[]{toAddress});

		// CUSTOMIZATION TAKES PLACE HERE - Add logic to get the email from the campaign record, if there is none get from OrgWideEmailAddress
		List<OrgWideEmailAddress> owas = [select id, Address, DisplayName from OrgWideEmailAddress LIMIT 1];
		If (owas.size() > 0) {
			System.debug('owas = ' + owas);
			OrgWideEmailAddress owa = owas[0];  
			System.debug('owa = ' + owa);			  
		    mail.setReplyTo(owa.Address);
		    //mail.setSenderDisplayName(owa.DisplayName);
		    mail.setOrgWideEmailAddressId(owa.id);

			mail.setBccSender(false);
			mail.setUseSignature(false);
			if(emailTemplate != null){
				mail.setSubject(emailTemplate.Subject);

				System.debug('dataValues = ' +  dataValues);								

				//set and replace body with data
				String textBody = emailTemplate.Body;
				if(String.isNotBlank(textBody)){
					if(dataValues != null){
						for(String field : dataValues.keySet()){
							String key = '{!'+ field + '}';
							system.debug('key = ' + key);
							if(String.isNotBlank(dataValues.get(field))) {
								textBody = textBody.replace(key, dataValues.get(field));
							} else {
								textBody = textBody.replace(key, '');						
							}
						}
					}
					system.debug('textBody = ' + textBody);					
					mail.setPlainTextBody(textBody);
				}

				String htmlBody = emailTemplate.HTMLValue;
				if(String.isNotBlank(htmlBody)){
					htmlBody = htmlBody.replace('<![CDATA[','').replace(']]>','');
					System.debug('htmlBody = ' +  htmlBody);
					if(dataValues != null){
						for(String field : dataValues.keySet()){
							String key = '{!' + field + '}';
							System.debug('field = ' +  field);
							System.debug('key = ' +  key);											
                            htmlBody = htmlBody.replace(key, String.isBlank(dataValues.get(field)) ? '' : dataValues.get(field));
						}
					}
					mail.setHtmlBody(htmlBody);
				}
			} else {
				emailResult.errorMessage = 'Email template not found or not active.';
				return emailResult;
			}
		} else {
			emailResult.errorMessage = 'No sender email configured.';			
			return emailResult;
		}
		
		emailResult.mail = mail;
		return emailResult;
	}

	private EmailResult getMemberMessage(Member__c member, EmailTemplate emailTemplate, Map<String,String> dataValues){
		return getSingleMessage(member.FieloPLT__Email__c, emailTemplate, dataValues);
	}

	public void startCampaign(Id campaignId) {
        try{      
            SObjectService.enableAdminPermission(true);		
			EmailService.changeEmailCampaignStatus(new Set<Id>{campaignId}, 'InProgress');
            SObjectService.enableAdminPermission(false);                        
        } catch(Exception e){
            SObjectService.enableAdminPermission(false);           
        }			
	}

	public Boolean executeCampaign(Id campaignId, Set<Id> memberIds, Map<Id,Map<String,String>> memberValues){
        // CUSTOMIZATION TAKES PLACE HERE - ADD Email FIELD over here
		EmailCampaign__c emailCampaign = new EmailCampaignsSelector(new Set<String>{'EmailTemplate__r.IsActive__c, EmailTemplate__r.TemplateUniqueName__c','EmailTemplate__r.FieldSet__c'}).selectById(new Set<Id>{campaignId})[0];

		If(!emailCampaign.FieloPLT__EmailTemplate__r.FieloPLT__IsActive__c) {
			SObjectService.enableAdminPermission(true);
			EmailService.changeEmailCampaignErrorDescription(campaignId, 'Template is not active.');			
            SObjectService.enableAdminPermission(false);           
			return false;
		}

		Map<Id,Member__c> membersMap = new Map<Id,Member__c>(new MembersSelector(new Set<String>{'FieloPLT__Email__c'}).selectById(memberIds));
		
		String packagePrefix;
		String devName;	
		List<String> metaFields = emailCampaign.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c.split('__');
		if(metaFields.size() > 1){
			packagePrefix = metaFields[0];
			devName = metaFields[1];
		}else{
			devName = emailCampaign.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c;
		}

		List<EmailTemplate> emailTemplates = [SELECT Id, Body, HTMLValue, Subject FROM EmailTemplate WHERE IsActive = true AND DeveloperName =: devName AND NamespacePrefix =: packagePrefix];
        try{      
            SObjectService.enableAdminPermission(true);
			if(emailTemplates.size() > 0) {
				EmailTemplate emailTemplate = emailTemplates[0];     
				try{
					Messaging.reserveSingleEmailCapacity(memberIds.size());
					Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
					List<Id> membersToSend = new List<Id>();
					System.debug('membersMap = ' + membersMap);
					System.debug('memberValues = ' + memberValues);				
					for(Id memberId : memberIds){
						System.debug('memberId = ' + memberId);
						EmailResult emailResult = getMemberMessage(membersMap.get(memberId), emailTemplate, (memberValues != null ? memberValues.get(memberId) : null));
						if (emailResult.mail != null) {
							mails.add(emailResult.mail);
							membersToSend.add(memberId);	
						} else {
							EmailService.changeEmailCampaignErrorDescription(campaignId, emailResult.errorMessage);			
							return false;				
						}
					} 
					// Send the emails
					Integer index = 0;
					List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails, true);
					// Check the results to update statuses
				    for (Messaging.SendEmailResult result : results)
				    {
						if (!result.isSuccess()) {
							EmailService.changeEmailCampaignErrorDescription(campaignId, formatErrorDescription(concatenateErrors(result.getErrors())));
							return false;
						} else {
							System.debug('Sent: member id = ' + membersToSend[index]);
						}
						index++;
				    }
				} catch(Exception e) {
					EmailService.changeEmailCampaignErrorDescription(campaignId, formatErrorDescription(e.getMessage()));
		            SObjectService.enableAdminPermission(false);           
					return false;
				}			
			} else {
				EmailService.changeEmailCampaignErrorDescription(campaignId, 'Email template not found or not active.');
				SObjectService.enableAdminPermission(false);           			
				return false;
			}
            SObjectService.enableAdminPermission(false);                        
        } catch(Exception e){
            SObjectService.enableAdminPermission(false);           
        }	

		return true;
	}

	public void finishCampaign(Id campaignId, Boolean success, Id jobId) {
		System.debug('success Salesforce = ' + success);
        try{      
            SObjectService.enableAdminPermission(true);		
			if(success){
				EmailCampaign__c emailCampaign = new EmailCampaignsSelector(new Set<String>{'Date__c', 'Type__c', 'Frequency__c'}).selectById(new Set<Id>{campaignId})[0];
				if (emailCampaign.Type__c == 'Recurrent') {
					EmailService.changeEmailCampaignStatus(new Set<Id>{campaignId}, 'Scheduled');
					Date emailCampaignDate = emailCampaign.Date__c;
					List<String> frequency = emailCampaign.Frequency__c.split('\\.');
					if (frequency[0] == 'd') {
			            emailCampaignDate = emailCampaignDate.addDays(Integer.valueOf(frequency[1]));
					} else if (frequency[0] == 'm') {
			            emailCampaignDate = emailCampaignDate.addMonths(Integer.valueOf(frequency[1]));
					}
					EmailService.changeEmailCampaignDate(campaignId, emailCampaignDate);
				} else {
					EmailService.changeEmailCampaignStatus(new Set<Id>{campaignId}, 'Sent');
				}
			} else {
				EmailService.changeEmailCampaignStatus(new Set<Id>{campaignId}, 'Error');
			}
            SObjectService.enableAdminPermission(false);                        
        } catch(Exception e){
            SObjectService.enableAdminPermission(false);           
        }			
	}

	public Map< Date, Map<String,Decimal>> getStatistics(Id campaignId) {
		return null;
	}

	static String concatenateErrors(List<Messaging.SendEmailError> errors) {
	    List<String> messages = new List<String>();
	    for (Messaging.SendEmailError error : errors) messages.add(error.getMessage());
	    return String.join(messages, ';');
	}

	private String formatErrorDescription(String errorDescription) {
		return errorDescription.Length() >= 255 ? errorDescription.substring(0, 255) : errorDescription;    
	}
}