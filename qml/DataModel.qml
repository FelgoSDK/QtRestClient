pragma Singleton
import VPlay 2.0
import QtQuick 2.7

Item {
    id: dataModel

    property bool weatherAvailable: false
    property bool weatherFromCache: false

    property var weatherData: []

    Storage {
        id: weatherLocalStorage

        Component.onCompleted: {
            // After the storage has been initialized, check if any weather data is cached.
            // If yes, load it into our model.
            loadModelFromStorage()
        }
    }

    function setModelData(weatherAvailable, weatherForCity, weatherDate, weatherTemp, weatherCondition, weatherIconUrl, weatherFromCache) {
        dataModel.weatherData = {
            'weatherForCity': weatherForCity,
            'weatherDate': weatherDate,
            'weatherTemp': weatherTemp,
            'weatherCondition': weatherCondition,
            'weatherIconUrl': weatherIconUrl
            }
        console.log("Saved weather to dataModel")
        console.log(JSON.stringify(dataModel.weatherData))

        dataModel.weatherAvailable = weatherAvailable
        dataModel.weatherFromCache = weatherFromCache
        saveModelToStorage()
    }

    function saveModelToStorage() {
        weatherLocalStorage.setValue("weatherData", dataModel.weatherData)
    }

    function loadModelFromStorage() {
        console.log("Loading model from storage...")
        var savedWeatherData = weatherLocalStorage.getValue("weatherData")
        if (savedWeatherData) {
            console.log("Found data in cache!")
            dataModel.weatherData = savedWeatherData
            dataModel.weatherAvailable = true
            dataModel.weatherFromCache = true
            console.log(JSON.stringify(dataModel.weatherData))
        }
    }

    function clearData()
    {
        // Reset all data stored in the model and the cache
        setModelData(false, "", undefined, undefined, "", "", false)
    }

    function updateFromJson(parsedWeatherJson) {
        // Use the new parsed JSON file to update the model and the cache
        setModelData(true,
                     parsedWeatherJson.name + ", " + parsedWeatherJson.sys.country,
                     new Date(),    // Note: date.now() and new Date() are different - new Date() returns a QML Date object!
                     parsedWeatherJson.main.temp,
                     parsedWeatherJson.weather[0].main,
                     "http://openweathermap.org/img/w/" + parsedWeatherJson.weather[0].icon + ".png",
                     false)
    }


}
