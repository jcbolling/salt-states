#!/usr/bin/env python

# Author: Josh Bolling
# Script/module name: weather.py
# Date created: 07/14/2019
# Description: This script will print the current weather conditions and temperature at Indianapolis International Airport

# Import required modules

import logging
import json

# Try to import the requests module. If module import fails return False
try:
    import requests
    import json
    HAS_REQUESTS = True
    HAS_JSON = True
except ImportError:
    HAS_REQUESTS = False
    HAS_JSON = False

# Initialize logging. This has to happen AFTER the logging module has been imported.

log = logging.getLogger(__name__)

# virtualname variable is used by the documentation build system to get the virtualname of the module without calling the virtual function

__virtualname__ = 'weather'

# Define __virtual__() boilerplate function. This module is typically used to test for a module dependency and provide a nice error if the dependency fails

def __virtual__():
    '''
    Only load the weather module if the requests module can be imported 
    '''
    if HAS_REQUESTS:
        return __virtualname__
    else:
        return False, 'The weather module cannot be executed: the requests module is not available.'

# Define the get function to retreive current weather conditions. Weather station ID is hard-coded in query string so no arguments are required.

def get():
    '''
    This module retrieves the current weather conditions at Indianapolis International Airport

    CLI Example::

        salt <target> weather.get
    '''
    # Request current weather conditions from weather station located at Indianapolis International Airport (KIND).
    request = requests.get('https://api.weather.gov/stations/KIND/observations/current')
    # Create dictionary and store JSON values for current conditions and temperature
    conditions = {

        "current conditions": request.json()["properties"]["textDescription"],
        # Retreive celcius temperature, convert to farenhiet equivient, cast to string and concatente farenhiet designator string
        "temperature": (str(round(1.8*request.json()["properties"]["temperature"]["value"] + 32, 1))) + " F"

    }
    # Return current conditions dictionary to Salt
    return conditions

def get_forecast():
    '''
    This module retrieves the 10-day weather forecast for Indianapolis International Airport

    CLI Example::

        salt <target> weather.get_forecast
    '''
    # Request 10-day weather forcast for Indianapolis International Airport (KIND).
    request = requests.get('https://api.weather.gov/gridpoints/IND/56,65/forecast')
    # Initialize empty dictionary
    forecast = {}
    # Populate forecast_data variable with raw text dictionary representation of the JSON return from the weather.gov API
    forecast_data = json.loads(request.text)

    '''
    Create list containing the first 15 letters of the alphanet to prepend to the name key.
    Salt sorts the forecast dictionary alphabetically so it's necessary to prepend a single
    character to the beginning of the name key to force Salt to sort the dictionary in a way
    that's useful.
    '''
    prepend = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',]
    # Loop over all period fields in forecast_data. Fields accessed two keys deep.
    for i in range(0,len(forecast_data['properties']['periods'])):
        '''
        Build name variable by prepending the character at list index of the current loop iteration
        to the period retrieved from the forecast_data dictionary.
        '''
        name = prepend[i] + " " + "-" + " " + forecast_data['properties']['periods'][i]['name']
        # Populate temperature variable with period temperature during each iteration
        temperature = forecast_data['properties']['periods'][i]['temperature']
        # Populate shortForecast variable with contents of shortForecast field in JSON reply
        shortForecast = forecast_data['properties']['periods'][i]['shortForecast']
        # Populate detailedForecast variable with contents of detaildForecast field in JSON reply
        detailedForecast = forecast_data['properties']['periods'][i]['detailedForecast']
        # Add nested dict to forecast dict during each iteration
        forecast[name] = {"temperature":forecast_data['properties']['periods'][i]['temperature'],
                          "Forecast":forecast_data['properties']['periods'][i]['shortForecast'],
                          "Detail":forecast_data['properties']['periods'][i]['detailedForecast']}
    # Return forecast dictionary to Salt
    return(forecast)