# Cue

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Many people find it difficult to remember and plan for events such as birthdays, anniversaries, holidays, etc. Cue is a reminder app that auto-suggests gift/restaraunts/activity/etc bookings (aka Cues) for any important date a user enters.

### App Evaluation

- **Category:** Productivity / Lifestyle
- **Mobile:** Location services / Notification alerts
- **Story:** Anyone who is need of keeping track of important dates or events, especially ones that need prior preparation e.g. restaurant reservations, flower orders, children's toys, etc, obtains immense value from Cue's services.
- **Market:** Cue's market has no constraints and can be used by a person of any age/gender/socioeconomic/etc status.
- **Habit:** The average user would only need to use Cue to initially add an event and then to accept an action suggestion. Cue's habit forming allows users to rely on the app for automatic suggestion based on the category of the event, rather than to make those searches themselves.
- **Scope:** The stripped-down version of this app would simply include entering an event and recieving a list of recommendations from Cue, done using the Yelp API. A stretch goal would be for the app to automatically reserve or buy the product once the user approves it.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can sign in with authentication
- [x] User can log in and log out of their account
- [x] The current signed in user is persisted across app restarts
- [x] User can add an event name, date, and category which appears on the home calendar
- [x] User can update their profile settings
- [x] User can tap on an event to see more details on a new view
- [x] User can switch between Calendar, Event, and Profile screens
- [x] User can view upcoming events with all inputted details on the Events screen
- [x] User can set notification settings for every event, which appear on their phone


**Optional Nice-to-have Stories**

- [ ] User can see a calendar view (rather than table view) of their upcoming events
- [x] Event service suggestions based on user location
- [x] Each upcoming event has gift/restaurant suggestions depending on the category
- [x] User can login via Facebook/Gmail
- [x] Cue Calendar can import Google Calendar events
- [ ] User can add contacts / number of participants to event who also recieve event reminders
- [ ] Cue is automated: auto-buys a product / auto-reserves a restaurant / etc
- [x] Infinite scrolling calendar
- [ ] Event can be set up as reoccurring
- [ ] Fetch birthdays from Facebook
- [x] Users can search through their home timeline events
- [x] Yelp suggestions can be filtered based on properties
- [x] Events can be assigned Cues
- [x] Yelp suggestions offer more details about the business


### 2. Screen Archetypes

* Login
    * Allows user to login or sign up for a new account
* Home / Calendar
    * Displays all upcoming events in a calendar view, which can be tapped on for more details
    * Includes button menu to create a new event or import from Google Calendar
* Add Event
    * Allows user to input a new event, including the category, address, date, and Cues requested
* Event Details
    * Detail view of event, which displays all the information inputted in add event as well as booking suffegestions
* Suggestion Details
    * Detail view of Yelp suggestion, which displays information, showcases location, allows the user to contact and assign the business to an event
* Profile
    * Allows user to edit profile settings or logout

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home / Calendar
* Edit Profile

**Flow Navigation** (Screen to Screen)

* Login
    * Sign Up
* Home
   * Event Details
        * Suggestion Details
   * Compose Event
   * Import Google Calendar Events
* Edit Profile

## Wireframes

![](https://i.imgur.com/NzGesIM.jpg)



## Schema 
### Models

##### Event
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | objectId        | String            | Unique id for the user event |
  | eventName        | String            | Event name |
  | author        | Pointer to User            | Event user |
  | eventDate        | DateTime            | Event date |
  | selectedCues           | Array              | Categories for suggestions e.g. active life |
  | searchRadius           | Number            | Distance to search for suggestions |
  | cuesString      | String            | Selected cues in string format |
  | address     | String            | Address to search suggestions for |
  | selectedCueId     | String            | ObjectId of assigned cue |


##### User
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | username        | String            | Unique login username |
  | password        | String            | Account password |
  | name        | String            | User display name |
  | profilePicture           | File            | User display profile picture |
  | address      | String            | User location |


##### Cue
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | name        | String            | Business name |
  | distance        | String            | Distance of business from event address |
  | imageUrl      | String            | Associated URL with business photo |
  | price      | String            | Pricing range e.g. $$ |
  | phone      | String            | Associated number with business photo |
  
  
##### Notification
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | user        | Pointer            | Associated user with notification |
  | text        | String            | Notification text |
  | postDate      | Date            | Date and time to post notification |

  
### Networking
#### List of network requests by screen

- Login Screen
    - (Create/POST) Create a new user object with provided information 
    - (Read/GET) Get existing user
- Compose Event
    - (Create/POST) Create new event for user
- Home / Calendar Screen
    - (Read/GET) Events associated with logged in user, as well as their details
- Profile Screen
    - (Read/GET) Query logged in user object
    - (Update/PUT) Update user profile image

#### [OPTIONAL:] Existing API Endpoints
##### Yelp API
- (http://api.yelp.com/v3/businesses/search)
##### Google Calender API
- (https://www.googleapis.com/calendar/v3/calendars/primary/events)
