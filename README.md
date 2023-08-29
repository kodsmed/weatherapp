# weatherapp

A simple weather app that uses the [OpenWeatherMap API](https://openweathermap.org/api) to display the current weather for a given location. As well as the weather for the next 5 days.

Recommended virtual unit is Samsung A22 API 33 (android-x64 emulator)

## Demo

[https://youtu.be/f-4QaWD_HiI](https://youtu.be/f-4QaWD_HiI)

## Requirements

### For grades E - D

| Requirement | Implemented | Where|
|-------------|-------------|------|
| Show the current location and the temperature | Yes | Current Weather, 1st and 3rd row. |
| Have two screens, one for the current weather and one for the About | Yes | Current Weather and About |

### For grade C

All of the above + the following

| Requirement | Implemented | Where|
|-------------|-------------|------|
| Show suitable graphics for the current weather | Yes | The background changes on the current weather page and icons on the forecast |
| Show time and description of the weather | Yes | The final row of text on the Current Weather page says when the data was fetched |

### For grade B

All of the above + the following

| Requirement | Implemented | Where|
|-------------|-------------|------|
| Show the weather forecast that is available for the API (five days, three hours) | Yes | The forecast page shows the forecast for the next 5 days |

### For grade A

All of the above + the following

"Amaze us! The images of the app above are probably about a B, to get an A you need something "more". Background depending on the weather? Animations? Cool transitions? Air and pollution data? The ability to save locations? You decide!"

### Extras

| Requirement | Where |
|-------------|-------|
| Background changes depending on the weather | Current Weather page |
| Icons used are not the default ones provided by the API | Forecast page |
| Some spam protection is implemented | Current and Forecast page |
| It is possible to choose between Imperial and Metric units | Settings page |
| It is possible to choose between English and Swedish | Settings page |
| The settings are saved between sessions | Settings page |
| The settings carry over to every page | All pages |