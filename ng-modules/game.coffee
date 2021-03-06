require('angular')
Location = require('./Location.coffee')

window.TRAVEL_SPEED = 1 # pixels per movement tick of tile travel
window.TRAVELS_PER_MOVE = 5  # TRAVEL_SPEED divisor (for getting < 1 TRAVEL_SPEED)

class Game
    constructor: (gameScope)->
        @scope = gameScope
        @locations = [
            new Location("iss", 1500, "station"),
            new Location("moon", 7000, "station")
        ]
        @gameDir = "" # "/the-oregon-trajectory" #  for conversion between gh-pages and local server
        @_init()  # initializes params

    _init: ()->
        # re-initializes the game
        @distanceTraveled = 0
        @crewHealth = [100, 100]
        @shipHealth = 100

        @rations = 0
        @eatChance = 0.1  # chance of eating per tick

        @fuel = 0
        @fuelExpense = 0.1;
        @fuelChance = 0.7;  # chance of expending fuel per tick

        @radiationChance = .005  # chance of being irradiated per tick
        @money = 5000
        @visited = ['ksc']
        @nextWaypoint = @_getStatsToNextLocation()

    travel: ()->
        # progress 1 time-tick of travel and update the game values
        if @fuel >= @fuelExpense
            @distanceTraveled += TRAVEL_SPEED
            if Math.random() < @fuelChance
                @fuel -= @fuelExpense
        else
            @end()

        if Math.random() < @radiationChance
            @irradiate()

        if @rations < 1  # starvation
            for crew_i of @crewHealth
                @hurtCrew(crew_i, Math.random()*0.6)
        else
            if Math.random() < @eatChance  # if hungry
                @rations -= @crewHealth.length  # eat

        # update next location if needed
        if @distanceTraveled > @nextWaypoint.location
            @nextWaypoint = @_getStatsToNextLocation()
        else  # just update the distance
            @nextWaypoint.distance = @nextWaypoint.location - @distanceTraveled

    hurtCrew: (i, amnt)->
        # hurts crewmember i given amnt (and checks for death)
        amnt = Math.round(amnt)
        @crewHealth[i] -= amnt
        if @crewHealth[i] < 1
            console.log('crew member died!')
            @scope.$broadcast('crew death', i)
            @crewHealth.splice(i, 1)  # remove the crew member
        # recalc ship health
        @_calcShipHealth()

    irradiate: ()->
        # irradiates the crew; use with care
        healthChanged = false
        @crewHealth.forEach( (health, i)=>
            healthChanged = true
            @hurtCrew(i, Math.random())
        )
        if healthChanged
            @_calcShipHealth()
            return

    reset: ()->
        @_init()
        @scope.$broadcast('resetGame')
        return

    end: ()->
        console.log('game over!')
        @scope.$broadcast('switchToModule', 'game-over')
        return

    # === debug helper methods ===
    GODMODE: ()->
        BIG_NUMBER = 99999999999
        @crewHealth = [BIG_NUMBER, BIG_NUMBER]
        @fuel = BIG_NUMBER
        window.TRAVEL_SPEED = 10

    # === "private" methods ===
    _getRemainingLocations: ()->
        # returns array of locations not yet reached
        remainingLocs = []
        for location in @locations
            if location.x > @distanceTraveled
                remainingLocs.push(location)
        return remainingLocs

    _getStatsToNextLocation: ()->
        # returns distance, location, & name of next location as dict
        # {
        #   distance:       111,    # distance to the place
        #   name:      "the place",
        #   location:       333,    # absolute location of the place
        #   fuelEstimate:   444,    # estimate of fuel to get there
        #   rationEstimate: 555     # estimate of rations to get there
        # }
        # location is relative to starting position, distance is relative to current ship position
        remaining = @_getRemainingLocations()

        # get minimum of remaining locations
        next = {}
        next.location = remaining[0].x
        next.name     = remaining[0].name
        for i of remaining
            if remaining[i].x < next.distance  # assumes no equal distances
                next.location = remaining[i].x
                next.name = remaining[i].name

            # calculate distance remaining before arrival
        next.distance = next.location - @distanceTraveled
        next.fuelEstimate = next.distance * @fuelExpense * @fuelChance / TRAVEL_SPEED
        next.rationEstimate = next.distance * @eatChance * @crewHealth.length / TRAVEL_SPEED
        return next

    _calcShipHealth: ()->
        # recalculates shipHealth summary of health of remaing crew members
        if @crewHealth.length < 1
            @end()
            return

        healthSum = @crewHealth.reduce((prev,current)->
            return current + prev
        )
        @shipHealth = healthSum/@crewHealth.length
        return

app = angular.module('game', [])

app.factory('data', ['$rootScope', ($rootScope) ->
    game = new Game($rootScope)
    window.game = game
    return game
])

module.exports = angular.module('game').name
