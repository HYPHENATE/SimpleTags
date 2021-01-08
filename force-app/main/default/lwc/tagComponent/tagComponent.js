import { LightningElement, api, track } from 'lwc';

import getTags from '@salesforce/apex/TagController.getExistingTags';
import searchTags from '@salesforce/apex/TagController.searchTags';
import addTags from '@salesforce/apex/TagController.addtagtorecord';
import removeTagLink from '@salesforce/apex/TagController.removeTagLink';
import userCanWorkWithTags from '@salesforce/apex/TagController.userCanWorkWithTags';
import userCanView from '@salesforce/apex/TagController.userCanView';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labels from './labels';

export default class TagComponent extends LightningElement {

    label = labels;

    // setup api elements
    @api recordId;
    @api objectApiName;

    // setup tracking
    tags;
    errors;
    searchKey;
    searchTags;
    searchTagsPresent;
    selectedValue;
    canViewTags;
    canManageTags;
    loading = true;
    timeoutId;

    // handle can view tags check
    handleuserCanView(){
        userCanView({
            objectName: this.objectApiName
        })
        .then((results) => {
            this.canViewTags = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.canViewTags = undefined;
        });
    }

    // handle can manage tags check
    handleuserCanWorkWithTags(){
        userCanWorkWithTags({
            objectName: this.objectApiName
        })
        .then((results) => {
            this.canManageTags = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.canManageTags = undefined;
        });
    }

    // get our tags to display
    handleGetTags() {
        getTags({
            recordId: this.recordId,
            objectName: this.objectApiName
        })
        .then((results) => {
            this.tags = results;
            this.errors = undefined;  
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.tags = undefined;
        });
    }

    // intial call back get out data
    connectedCallback() {
        this.handleGetTags();        
        this.handleuserCanWorkWithTags();
        this.handleuserCanView();
        clearTimeout(this.timeoutId); // n
        this.timeoutId = setTimeout(this.loadTags.bind(this), 500);
    }

    // confirming loading complete
    loadTags(){
        this.loading = false;
    }

    // handle errors no output for it back handling anyway
    errorCallback(error) {
        this.errors = error;
    }

    // handle search process
    handleChange(event){
        
        this.searchKey = event.target.value;
        
        if(this.searchKey.length > 2){
            searchTags({
                recordId: this.recordId,
                objectName: this.objectApiName,
                searchTerm: this.searchKey
            })
            .then((results) => {
                this.searchTags = results;
                this.errors = undefined;  
                if(results.length > 0){
                    this.searchTagsPresent = true;
                } else {
                    this.searchTagsPresent = false;
                }
            })
            .catch((error) => {
                this.errors = JSON.stringify(error);
                this.searchTags = undefined;
            });
        } else {
            this.searchTagsPresent = null;
            this.searchTags = null;
        }
    }

    // handle the removal of a tag
    handleRemove(event){
        removeTagLink({
            tagName: event.target.label,
            objectName: this.objectApiName,
            recordId: this.recordId
        })
        .then((results) => {
            this.errors = undefined;  
            this.handleGetTags();
            if(results == TagRemoveSuccess){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: results,
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: results,
                        variant: 'error'
                    })
                );
            }
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.handleGetTags();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
        });
    }


    // handle the selection of a value from the search options
    setSelectedValue(event) {
        this.selectedValue = event.target.dataset.itemid;
        this.searchTags = null;
        this.searchKey = null;

        addTags({
            tagId: this.selectedValue,
            recordId: this.recordId,
            objectName: this.objectApiName
        })
        .then((results) => {
            this.errors = undefined;  
            this.handleGetTags();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: results,
                    variant: 'success'
                })
            );
        })
        .catch((error) => {
            this.errors = JSON.stringify(error);
            this.handleGetTags();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
        });
    }
}