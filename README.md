#Sway

## Description
An app for capturing, sharing, and collaborating on musical ideas and sketches.

## User Stories

![Listen Flow](https://github.com/teamVCH/sway/blob/master/wireframes/listen-flow.png)

![Record Flow](https://github.com/teamVCH/sway/blob/master/wireframes/record-flow_and_settings.png)

### Compositions List
* The user is presented with a list of compositions. Each item in the list includes the name of the composition's originator, the title, the running time, and possibly other information, such as the number of collaborators, favorites count. 
	
	* The user can filter the list by tags without leaving the screen
	* The user can select any single item in the list to go to the **Composition Details** page
	* The user can play/preview any composition from this page (optional)

### Composition Details
* Detailed information about the composition is shown, including all summary information, tags, favorites count, creation date, and a list of collaborators and a brief description about their contribution (could just be a series of tags)
* The user can:
	* Play/scrub the composition
	* Like the composition (optional: leave comment)
	* Click on any avatar, which will open that user's **User Profile** page
	* The user can join the collaboration, which will open the **Record Composition** page with the composition's audio imported as the **Backing Track**

### User Profile
* Details about the user
	* Header: avatar, bio and links and other data 
	* Body: a **Compositions List** including all the users compositions in reverse chronological order 
* If the user displayed is also the account owner, controls for editing the profile content will be available

### Record Composition
* The user is able to record audio over a backing track, bounce the two tracks into a single audio file which can either be saved as a draft or shared as a composition or a collaboration.
* The page organized as a vertical stack of three panels: two idential display sections on top and one large control section on the bottom
	* [Top] Display Section: A waveform display of an audio track
		* Upper: The waveform display of the **Backing Track**, which is the read-only portion of the audio
		* Lower: The waveform display of the **Recording Track**, which captures the microphone input
	* [Bottom] Control Section: all the user controls for the recording
		* Middle: A large, red **Record** button in the center, which toggles recording on/off
		* Top:
			* A horizontal slider at the center which is the scrubbing control
			* A **Play/Stop** button at the left end of the slider
			* A time label at the right end of the slider indicating the current time position of the recording
		* Bottom:
			* A **Save as Draft** button
			* A **Load from Draft** button
			* A **Share** button
* The **Backing Track** will be different depending on which mode the user is in: **New Composition** or **New Collaboration**
	* **New Composition**: The backing track is an audio template, which is typically minimal and meant as a guide to get started. The default will be a simple click track or beat. It will not be mixed into the final audio.
	* **New Collaboration**: The backing track is the existing audio of the published composition, including all previous collaboration parts mixed together as a single audio source.
* The **Recording Track** is the audio captured via the microphone (the user will be reminded to use headphones)
* The **Save as Draft** function persists the audio session and all data such that it can be reloaded later via **Load from Draft**
* The Share function publishes the audio, making it available for others to listen and collaborate on. In **New Composition** mode, only the Recording Track data will be shared; in **New Collaboration** mode, the bounced (combined) audio will be shared

### Settings
* Settings to control the app behavior
	* Connectivity options (Facebook, Dropbox)

