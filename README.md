#Sway

## Description
An app for capturing, sharing, and collaborating on musical ideas.

## User Stories

![User Flow](https://github.com/teamVCH/sway/blob/master/wireframes/userflow.png)

### Compositions List
* The user is presented with a list of compositions. Each item in the list includes the name of the composition's originator, the title, the running time, and possibly other information, such as the number of collaborators, favorites count. 
	
	* The user can filter the list by tags without leaving the screen
	* The user can select any single item in the list to go to the **Composition Details** page
	* The user can play/preview any composition from this page (optional)
       

### Composition Details
* Detailed information about the composition is shown, including all summary information, tags, favorites count, creation date, and a list of collaborators and a brief description about their contribution (could just be a series of tags)
* The user can:
     * Play the composition
     * Scrub the composition - Move the player cursor to a specific point to listen (optional) 
     * Like the composition (optional: leave a comment)
     * Click on any avatar, which will open that user's **User Profile** page
     * The user can join the collaboration, which will open the **Record Composition** page with the composition's audio imported as the **Backing Track**

### Record New Composition
* A large, red Record button is shown to the user, which toggles recording on/off

	* **New Recording** - The user can record audio via the microphone (the user will be reminded to use headphones)
	* **Save as Draft** - The user can save recorded audio as a Draft
	* **Share** - The user can Share their recorded audio which publishes the audio, making it available for others to listen and collaborate on. The composition will then appear in the home feed.
	* **Record Options** - The user can select a backing track as a simple audio template, which is meant as a guide to get started. It will not be mixed into the final audio. (optional)

### Collaborate on Existing Composition
* Collaborate using an existing audio composition as a backing track. The new collaboration will include all previous parts mixed together as a single audio source.
 
	* **Load from Draft** - The user can load an existing composition from their own profile or their drafts to create a new composition. 
	* **New Collaboration** - The user can load a published compostion from another user and create a new bounced (combined) composition.


### User Profile
* Details about the user
	* Header: avatar, bio and links and other data 
	* Body: a **Compositions List** including all the user's compositions in reverse chronological order 
      * If the user displayed is also the account owner, controls for editing the profile content will be available

### Settings
* Settings to control the app behavior
	* Connectivity options (Facebook, Dropbox)

### Credits
Thanks to icons from the Noun Project: Edward Boatman, useiconic.com, Kirill Ulitin, & Pantelis Gkavos