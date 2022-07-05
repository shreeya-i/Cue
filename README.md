# Cue

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
As more people and circumstances enter your life, it becomes difficult to remember dates such as birthdays, anniversaries, holidays, etc. Cue is a reminder app that auto-suggests and helps book gifts/restaraunts/etc for any important date a user enters.

### App Evaluation

- **Category:** Productivity / Lifestyle
- **Mobile:** Location services / Notification alerts
- **Story:** Anyone who is need of keeping track of important dates or events, especially ones that need prior preparation e.g. restaurant reservations, flower orders, children's toys, etc, obtains immense value from Cue's services.
- **Market:** Cue's market has no constraints and can be used by a person of any age/gender/socioeconomic/etc status.
- **Habit:** The average user would only need to use Cue to initially add an event and then to accept an action suggestion. Cue's habit forming allows users to rely on the app for automatic suggestion based on the category of the event, rather than to make those searches themselves.
- **Scope:** The stripped-down version of this app would simply include entering an event and recieving a list of  recommendations from Cue, which can easily be done using a Yelp API or similar database. A stretch goal would be for the app to automatically reserve or buy the product once the user approves it.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can sign in with authentication
* User can log in and log out of their account
* The current signed in user is persisted across app restarts
* User can see a calendar of their upcoming events
* The home page calendar is auto-populated with holidays
* User can add an event name, date, and category which appears on the home calendar
* User can update their profile settings
* User can tap on an event to see more details on a new view
* User can switch between Calendar, Event, and Profile screens
* User can view upcoming events with all inputted details on the Events screen
* User can set notification settings for every event, which appear on their phone


**Optional Nice-to-have Stories**

* Event service suggestions based on user location
* Each upcoming event has gift/restaurant suggestions depending on the category
* User can login via Facebook/Gmail
* Cue Calendar can import Google Calendar events
* User can add contacts / number of participants to event who also recieve event reminders
* Cue is automated: auto-buys a product / auto-reserves a restaurant / etc
* Cue can support other types of appointments beyond important events e.g. acquaintance reach out reminders
* User can view stats on the Profile page
* Infinite scrolling calendar
* Event can be set up as reoccurring
* Fetch birthdays from Facebook


### 2. Screen Archetypes

* Login
    * Allows user to login or sign up for a new account
* Home / Calendar
    * Displays all upcoming events in a calendar view, which can be tapped on for more details
    * Includes button to create a new event
* Add Event
    * Allows user to input a new event, including the category, contacts, and Cues requested
* Upcoming Events
    * Lists all of a user's upcoming events, including holidays and self-inputted
    * Displays a list of Cue's auto-suggested gifts
* Event Details
    * Detail view of event, which displays all the information inputted in add event
* Profile
    * Allows user to edit profile settings and view Cue stats

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home / Calendar
* Upcoming Events
* Profile Settings

**Flow Navigation** (Screen to Screen)

* Login
    * Sign Up
* Home
   * Event Details
   * Compose Event
* Upcoming
   * Event Details
* Profile

## Wireframes
[Add picture of your hand sketched wireframes in this section]

![](https://i.imgur.com/NzGesIM.jpg)


### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models

##### Event
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | eventID        | String            | Unique id for the user event |
  | name        | String            | Event name |
  | date        | DateTime            | Event date |
  | category           | String              | Grouping of event e.g. birthday |
  | notifAt           | DateTime            | Date for event notification |
  | gift      | Boolean            | Whether or not the event requires a gift purchase |
  | reservation     | Boolean            | Whether or not the event requires a restaurant reservation  |


##### User
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | username        | String            | Unique login username |
  | password        | String            | Account password |
  | name        | String            | User display name |
  | events           | Array              | List of all events belonging to the user |
  | profileImage           | File            | User display profile picture |
  | location      | String            | User location |


##### Suggestion
  | Property        | Type              | Description |
  | --------------- | ----------------- | ------------|
  | product        | String            | Specific service name e.g. bouquet of flowers |
  | business        | String            | Business name |
  | category        | String            | Category of business |
  | location      | String            | Business address |


  
### Networking
#### List of network requests by screen

- Login Screen
    - (Create/POST) Create a new user object with provided information 
- Compose Event
    - (Update/PUT) Create new event for user
- Home / Calendar Screen
    - (Read/GET) Events associated with logged in user
- Profile Screen
    - (Read/GET) Query logged in user object
    - (Update/PUT) Update user profile image

#### [OPTIONAL:] Existing API Endpoints
##### Yelp API
- Will be listed here
##### Google Calender API
- Will be listed here
