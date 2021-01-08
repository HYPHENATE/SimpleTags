/**
 * @description     controller apex class for accessing tags from any object
 * @author          daniel@hyphen8.com
 * @date            18/04/2020
 * @group           Controller
*/

public with sharing class TagController {

    /**
     * @description     confirm if the user can view tags only
     * @param           string objectName used so we can check that specific field for access as well
     * @return          boolean true they can create / edit / delete or false they can only view
    */
    @AuraEnabled
    public static boolean userCanView(string objectName){

        // return boolean
        boolean returnvalue;

        // get the correct objectName
        string actualObjectName = TagHelper.getCorrectObjectName(objectName);

        boolean accessTagLinks = TagHelper.isAccessible('Tag_Link__c', new List<String>{'Id', 'Name', 'Tag__c', 'TagName__c', actualObjectName});
        boolean accessTags = TagHelper.isAccessible('Tag__c', new List<String>{'Id', 'Name'});
        
        if(accessTagLinks && accessTags){
            returnvalue = true;
        } else {
            returnvalue = false;
        }
        return returnvalue;
    }

    /**
     * @description     confirm if the user can create / edit / delete tags
     * @param           string objectName used so we can check that specific field for access as well
     * @return          boolean true they can create / edit / delete or false they can only view
    */
    @AuraEnabled
    public static boolean userCanWorkWithTags(string objectName){

        // return boolean
        boolean returnvalue;

        // get the correct objectName
        string actualObjectName = TagHelper.getCorrectObjectName(objectName);

        boolean accessTagLinks = TagHelper.isAccessible('Tag_Link__c', new List<String>{'Id', 'Name', 'Tag__c', 'TagName__c', actualObjectName});
        system.debug('accessTagLinks > ' + accessTagLinks);
        boolean accessTags = TagHelper.isAccessible('Tag__c', new List<String>{'Id', 'Name'});
        system.debug('accessTags > ' + accessTags);
        boolean createTagLinks = TagHelper.isCreateable('Tag_Link__c', new List<String>{'Tag__c', actualObjectName});
        system.debug('createTagLinks > ' + createTagLinks);
        boolean deleteTagLinks = TagHelper.isDeletable('Tag_Link__c');
        system.debug('deleteTagLinks > ' + deleteTagLinks);

        if(accessTagLinks && accessTags && createTagLinks && deleteTagLinks){
            returnvalue = true;
        } else {
            returnvalue = false;
        }
        return returnvalue;
    }

    /**
     * @description     create tag link dynamically on any object
     * @param           tagId - the id of the tag
     * @param           recordId - the recordid we are currently on
     * @param           objectName -  the object name
     * @return          string - message confirmation what happened
    */
    @AuraEnabled
    public static string addtagtorecord(string tagId, string recordId, string objectName){
        
        // setup return string
        string returnvalue;
        // get the correct objectName
        string actualObjectName = TagHelper.getCorrectObjectName(objectName);

        // try and add the tag link to record then catch and return an error
        try {
            // generate sobject for tag link
            SObject taglink = new Tag_Link__c();
            // put our selected tag against the link
            taglink.put('Tag__c', tagId);
            // put our record id link in
            taglink.put(actualObjectName, recordId);
            // insert our tag link
            database.insert(taglink);
            // set the return message
            returnvalue = Label.TagLinkAddedSuccess;
        } catch (Exception e){
            // get the error message
            string errorMsg = e.getMessage();
            // set the return message
            returnvalue = errorMsg;
        }

        // return error
        return returnvalue;
    }

    /**
     * @description     method to get a list of tags for current record
     * @param           recordId - the id for the record we are on
     * @param           objectName - the name of the object we are on
     * @return          List<Tag_Link__c>
    */
    @AuraEnabled
    public static List<Tag_Link__c> getExistingTags(string recordId, string objectName){
        
        // get the correct objectName
        string actualObjectName = TagHelper.getCorrectObjectName(objectName);

        // build up query string
        string query = 'SELECT ID, TagName__c FROM Tag_Link__c WHERE ' + actualObjectName + '=:recordId ORDER BY TagName__c';

        // perform query
        List<Tag_Link__c> returntags = Database.query(query);

        // return tags
        return returntags;
    }

    /**
     * @description         searchTags method to support pulling back available tags excluding those already used
     * @param               recordId   the id for the record we are currently on
     * @param               objectName the object for the record we are currently on
     * @param               searchTerm search term entered to find a tag
     * @return              return List<Tag__c> list of tages for selection
    */
    @AuraEnabled
    public static List<Tag__c> searchTags(string recordId, string objectName, string searchTerm){

        // get the correct objectName
        string actualObjectName = TagHelper.getCorrectObjectName(objectName);
        // build the query to check what tags are linked to the current record
        string existingTagSearch = 'SELECT ID, Tag__c, TagName__c FROM Tag_Link__c WHERE ' + actualObjectName + '=:recordId';
        // perform actual query
        List<Tag_Link__c> existingTags = Database.query(existingTagSearch);
        // set for confirming an existing tags linked to record
        Set<ID> existingTagIds = new Set<ID>();
        // loop through the tags and add to set
        for(Tag_Link__c tl:existingTags){
            existingTagIds.add(tl.Tag__c);
        }
        // set up the searchKey
        string searchKey = '%' + searchTerm + '%';
        // perform actual search for tags that are availabe
        List<Tag__c> tagsToReturn = [SELECT ID, Name FROM Tag__c WHERE ID NOT IN:existingTagIds AND Name LIKE:searchKey AND Status__c=:'Active'];
        return tagsToReturn;
        
    }

    /**
     * @description     remove tag from record
     * @param           tagName
     * @param           objectName
     * @param           recordId
     * @return          string confirm deletion worked
    */
    @AuraEnabled
    public static string removeTagLink(string tagName, string objectName, string recordId){

        try {
            
            // get the correct objectName
            string actualObjectName = TagHelper.getCorrectObjectName(objectName);

            // get the tagId
            ID tagId = [SELECT ID FROM Tag__c WHERE Name=:tagName].id;

            // build the query
            string query = 'SELECT ID FROM Tag_Link__c WHERE ' + actualObjectName + '=:recordId AND Tag__c=:tagId';

            // get list to delete
            List<Tag_Link__c> tagstodelete = Database.query(query);

            // delete the tag
            delete tagstodelete;
            
            // return a success message
            return Label.TagRemoveSuccess;

        } catch (Exception e){
            system.debug(e.getMessage());
            return Label.TagRemoveError;
        }
    }
}