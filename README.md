# WX-Temp

This demo app is a coding challenge I made in less than eight hours for a possible employer.  The week I was asked to accomplish this task I didn't have more time to work on it, but I had accomplished the requirements, plus some extra.  There are still aspects of the code that can be cleaned up and commented on.  This code is really a show case of how I am currently setting up my workspaces and insight to how I have been separating the model into a framework.  

Additional features in the app:

* I included a communication manager (singleton) that implements Apple's Reachability code to determine if a network connection is available.  The app will display a layover (popup) view warning that the device is offline and is waiting for a network connection. 
* I included a UITextField to allow a user to input a zip-code (airport identifier like KMSP or any other accepted WXUnderground API input) to get that locations temp.


This is a demo app and NOT a finished product!

#### Please Note:

* I am not maintaining this code or adding to it beyond what has been already accomplished.  

* I am not maintaining the WeatherUnderground account, either, and won't be checking if it's still active.  


# Coding Challenge

Requirements: 

* Support iOS 8 + 
* iPhone only (no need to support iPad)
* Support Portrait and Landscape orientations 
* Swift Or Objective C (either is fine) 


Create a mobile application that uses the WeatherUnderground API (Weather Underground’s API provides free access to their service for developers. You can sign up for an API key at http://www.wunderground.com/weather/api/  ), and the user/devices current geo location to download the current temperature. At a minimum once you have the current temperature (temp_f or temp_c either is fine) display the temperature along with the city name on a new page, feel free to expand on this and impress us.  

The intent for this coding is challenge is to take less than 8 hours, please do not spend more than 12 hours on these tasks. If you feel like it is taking too much time we recommend that you comment how you would accomplish various tasks. 

In this code challenge we will be paying particular attention to the following items: 

* Functionality: Does the application meet the technical requirements and work reliably, as well as handle special conditions?  
* Architecture: How do you structure your application and its classes? Would the application be  extensible? How do you encapsulate data parsing and access?  
* Coding practices and use of IDE: How do you organize your files and groups? What practices do you  adhere to make the code accessible and usable to other developers? 
* Fit and finish: Do you adhere to the platform’s recommended practices? 
	
	
When you have finished please create an account on GitHub (if you don’t have one already) and provide a link to the project. 
