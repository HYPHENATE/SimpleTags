[![codecov](https://codecov.io/gh/HYPHENATE/SimpleTags/branch/master/graph/badge.svg)](https://codecov.io/gh/HYPHENATE/SimpleTags)
[![HYPHENATE](https://circleci.com/gh/HYPHENATE/SimpleTags.svg?style=svg&&circle-token=297c83f424a06b21dc3b4fa042318223464f67d7)](https://circleci.com/gh/HYPHENATE/SimpleTags)

# Simple Tags
A very simple solution to providing tagging that is reportable in Salesforce. Since the switch to Lightning the easy ability to take a record without using Topics in chatter and then report on them has been limited. This simple application fills that gap. We see this requirement come up a lot in the Nonprofit world the need to tag a grant based on theme, category, location and potentially funder. This can be acheived with dependent multi-select picklists but as we all know reporting on them is a pain.

<img src="https://github.com/HYPHENATE/SimpleTags/blob/master/SimpleTags.png?raw=true" width="800px"/>

## Verion Control

### 1.0.2
- update to provide as an unlocked package option
- update lighting pages based on changes in Winter 21

### 1.0.1 - Initial feedback
- resolve issue where Permission sets were missing apex class method access (https://github.com/HYPHENATE/SimpleTags/issues/2)

### 1.0.0 - Initial release
- Basic Tag Handling
- Configure the Tag Record relationship via custom meta data
- Dedicated permissions for different people
- Example report for tags on Account object

## Part 1: Installation

<a href="https://githubsfdeploy.herokuapp.com?owner=HYPHENATE&repo=SimpleTags">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Unlocked Package Installation URL: 
Production: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t67000000SaEvAAK
Sandbox: https://test.salesforce.com/packaging/installPackage.apexp?p0=04t67000000SaEvAAK

1. Ensure my domain is actived and deployed
2. Ensure path is activated
3. Install using the deploy to salesforce link or the Unlocked package link above
4. Assign the Tag_User, Tag_Viewer and Tag_Manager Permissions Set to relevant users
5. Start configuration

## Part 2: Configuration

1. Go to Account Lightning Page
2. Add tagComponent to the Page
3. Create some Tags using the Tags Tab
4. Visit an account search for the Tag you added
5. Select the tag
6. Expand to other objects using the video below from 7 minutes in:

<a href="https://web.microsoftstream.com/video/41b0fcca-337e-4eb4-aaf1-525764d6453d">Configuration Video</a>

## Part 3: Limitations
- A Tag Link can only be related to a max of 38 different Standard or Custom Objects
- No audit trail if a tag is removed unless you have a backup in place

## Credits

