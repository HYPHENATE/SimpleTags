/**
 * @description     Test class for Tag App
 * @author          daniel@hyphen8.com
 * @date            18/04/2020
 * @group           Tests
*/
@isTest
public with sharing class TagController_Test {
    
    /**
     * @description     test a basic search
    */
    public static testmethod void basicSearch(){
        
        // set up test data
        Tag__c tag = new Tag__c(Name='DEMO TAG', Status__c='Active');
        insert tag;
        Account account = new Account(Name='DEMO');
        insert account;

        
        // pull back list of tag links
        List<Tag__c> tagLinks = TagController.searchTags(account.Id, 'Account', 'DEMO TAG');

        // confirm we have the right amount of tag links
        system.assertEquals(1, tagLinks.size(), 'Expected number of tag in response');
        
    }

    /**
     * @description     test a basic search where 1 tag linked and one not and pull back existing tags
    */
    public static testmethod void basicSearchExistingTags(){
        
        // set up test data
        Tag__c tagLinked = new Tag__c(Name='DEMO TAG', Status__c='Active');
        insert tagLinked;
        Tag__c tagNotLinked = new Tag__c(Name='TAG DEMO', Status__c='Active');
        insert tagNotLinked;
        Account account = new Account(Name='DEMO');
        insert account;
        Tag_Link__c tagLink = new Tag_Link__c(Tag__c=tagLinked.Id, Account__c=account.Id);
        insert tagLink;

        
        // pull back list of tag links
        List<Tag__c> tagLinks = TagController.searchTags(account.Id, 'Account', 'TAG DEMO');

        // confirm we have the right amount of tags
        system.assertEquals(1, tagLinks.size(), 'Expected number of tags in response');

        // pull back existing tags
        List<Tag_Link__c> existingTagLinks = TagController.getExistingTags(account.Id, 'Account');

        // confirm we have the right amount of tag links
        system.assertEquals(1, existingTagLinks.size(), 'Expected number of tag links in response');
        
    }

    /**
     * @description     test adding a tag then searching for and checking existing list
    */
    public static testmethod void basicAddTag(){
        
        // set up test data
        Tag__c tagLinked = new Tag__c(Name='DEMO TAG', Status__c='Active');
        insert tagLinked;
        Tag__c tagNotLinked = new Tag__c(Name='TAG DEMO', Status__c='Active');
        insert tagNotLinked;
        Account account = new Account(Name='DEMO');
        insert account;

        
        // pull back list of tag links
        List<Tag__c> tagLinks = TagController.searchTags(account.Id, 'Account', 'DEMO');

        // confirm we have the right amount of tags
        system.assertEquals(2, tagLinks.size(), 'Expected number of tags in response');

        // pull back existing tags
        List<Tag_Link__c> existingTagLinks = TagController.getExistingTags(account.Id, 'Account');

        // confirm we have the right amount of tag links
        system.assertEquals(0, existingTagLinks.size(), 'Expected number of tag links in response');

        // add a tag with correct data
        string addTag = TagController.addtagtorecord(tagLinked.Id, account.Id, 'Account');

        // verify response
        system.assertEquals(addTag, Label.TagLinkAddedSuccess, 'Got Correct Response');

        // add a tag with correct data
        string addTagBad = TagController.addtagtorecord(tagLinked.Id, account.Id, 'AccountError');

        // verify response
        system.assertNotEquals(addTagBad, Label.TagLinkAddedSuccess, 'Got Correct Response');

        // pull back list of tag links
        List<Tag__c> tagLinksPostAdd = TagController.searchTags(account.Id, 'Account', 'DEMO');

        // confirm we have the right amount of tags
        system.assertEquals(1, tagLinksPostAdd.size(), 'Expected number of tags in response');

        // pull back existing tags
        List<Tag_Link__c> existingTagLinksPostAdd = TagController.getExistingTags(account.Id, 'Account');

        // confirm we have the right amount of tag links
        system.assertEquals(1, existingTagLinksPostAdd.size(), 'Expected number of tag links in response');

        // perform a remove of a tag
        string removeTagGood = TagController.removeTagLink('DEMO TAG', 'Account', account.Id);

        // check we got the right response
        system.assertEquals(removeTagGood, Label.TagRemoveSuccess, 'We got the right response');

        // perform a remove of a tag
        string removeTagBad = TagController.removeTagLink('DEMO TAG', 'AccountERROR', account.Id);

        // check we got the right response
        system.assertEquals(removeTagBad, Label.TagRemoveError, 'We got the right response');

    }

    /**
     * @description     perform permission checks on Viewer Permision set error
    */
    public static @IsTest void viewpermissioncheckerror(){

        // get some strings ready for testing
        ID profileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;
        
        Test.startTest();
        System.runAs(user){
            boolean usernoaccessview = TagController.userCanView('Account');
            system.assertEquals(false, usernoaccessview, 'User Does not have the correct permissions');
            boolean usernoaccessmanage = TagController.userCanWorkWithTags('Account');
            system.assertEquals(false, usernoaccessmanage, 'User Does not have the correct permissions');            
        }
        Test.stopTest();
        
    }

    /**
     * @description     perform permission checks on Viewer Permision set success
    */
    public static @IsTest void viewpermissionchecksuccess(){

        // get some strings ready for testing
        ID profileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Tag_Viewer'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(user){
            boolean useraccessview = TagController.userCanView('Account');
            system.assertEquals(true, useraccessview, 'User Does have the correct permissions');
            boolean usernoaccessmanage = TagController.userCanWorkWithTags('Account');
            system.assertEquals(false, usernoaccessmanage, 'User Does not have the correct permissions');             
        }
        Test.stopTest();
        
    }

    /**
     * @description     perform permission checks on User Permision set success
    */
    public static @IsTest void userpermissionchecksuccess(){

        // get some strings ready for testing
        ID profileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Tag_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(user){
            boolean useraccessview = TagController.userCanView('Account');
            system.assertEquals(true, useraccessview, 'User Does have the correct permissions');
            boolean useraccessmanage = TagController.userCanWorkWithTags('Account');
            system.assertEquals(true, useraccessmanage, 'User Does not have the correct permissions');             
        }
        Test.stopTest();
        
    }

    /**
     * @description     perform permission checks on Manager Permision set success
    */
    public static @IsTest void managerpermissionchecksuccess(){

        // get some strings ready for testing
        ID profileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Tag_Manager'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(user){
            boolean useraccessview = TagController.userCanView('Account');
            system.assertEquals(true, useraccessview, 'User Does have the correct permissions');
            boolean useraccessmanage = TagController.userCanWorkWithTags('Account');
            system.assertEquals(true, useraccessmanage, 'User Does have the correct permissions');             
        }
        Test.stopTest();
        
    }

    /**
      * @description    simple test with current user permissions
    */
    public static testmethod void testAccessgeneric() {
        System.assertEquals(true, TagHelper.isAccessible('Account', new List<String>{'Name', 'Phone'}), 'Current user has access to object and fields');
        System.assertEquals(true, TagHelper.isAccessible('Account', new List<String>()), 'Current user has access to object');
        System.assertEquals(true, TagHelper.isUpdateable('Account', new List<String>{'Name', 'Phone'}), 'Current user can update object and fields');
        System.assertNotEquals(true, TagHelper.isUpdateable('Account', new List<String>{'createddate'}), 'Current user can not update to object and fields');
        System.assertEquals(true, TagHelper.isCreateable('Account', new List<String>{'Name', 'Phone'}), 'Current user can create to object and fields');
        System.assertNotEquals(true, TagHelper.isCreateable('Account', new List<String>{'id'}), 'Current user can not create account ID field');
        System.assertEquals(true, TagHelper.isDeletable('Account'), 'Current user has delete access to object and fields');
    }
  
  
    /**
    * @description  test method with incorrect permissions for user
    **/
    public static testmethod void testwithwrongpermissionsgeneric()
    {
        // insert a account
        Account account = new Account(Name='Demo');
        insert account;
        // get some strings ready for testing
        ID profileId = [SELECT Id FROM Profile WHERE Name = 'Read Only' LIMIT 1].Id;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+randomId; 
        User user = new User(
            FirstName = 'DEMO',
            LastName = 'DEMO', 
            Email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'GMT',  
            LocaleSidKey = 'en_GB', 
            LanguageLocaleKey = 'en_US', 
            ProfileId  = profileid); 
        insert user;
        system.runas(user){
            System.assertEquals(true, TagHelper.isAccessible('Account', new List<String>{'Name'}), 'Read only user can read accounts');
            System.assertEquals(true, TagHelper.isAccessible('Account', new List<String>()), 'Read only user can read accounts');
            System.assertEquals(false, TagHelper.isAccessible('Account', new List<String>{'AccountNumber'}), 'Read only user can not read this field');
            System.assertEquals(false, TagHelper.isUpdateable('Account', new List<String>{'Name'}), 'Read only user can not update');
            System.assertEquals(false, TagHelper.isCreateable('Account', new List<String>{'Name', 'Phone'}), 'Read only user can not create with fields');
            System.assertEquals(false, TagHelper.isCreateable('Account', new List<String>{'Name'}), 'Read only user can not create');
            System.assertEquals(false, TagHelper.isDeletable('Account'), 'Read only user can not delete');
        }
    }

}