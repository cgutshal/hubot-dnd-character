# Description:
#   You've got to start a new character and you're out of ideas.  Let me help.
# Notes:
#   Put the help here

helpText = """```
Create a randomized character idea:     who is my character
Create a randomized quest:              what is our quest
Create a randomized weapon:             what am I wielding
Add or remove character adjective:      (add|remove) adjective "<adjective>"
Add or remove character race:           (add|remove) race "<race>"
Add or remove character class:          (add|remove) class "<class>"
Add or remove character location:       (add|remove) location "<location>"
Add or remove character backstory:      (add|remove) backstory "<backstory>"
Add or remove quest deed:               (add|remove) deed "<deed>"
Add or remove weapon property:          (add|remove) property "<property>"
Add of remove weapon mineral            (add|remove) mineral "<mineral>"
Add or remove weapon:                   (add|remove) weapon "<weapon>"
Add or remove failure:                  (add|remove) failure "<failure>"
Add or remove reward:                   (add|remove) reward "<reward>"
List item types:                        list <type>
```"""


keyToDb =
    'adjective': 'dndAdjectives'
    'race': 'dndRaces'
    'class': 'dndClasses'
    'location': 'dndLocations'
    'backstory': 'dndBackstories'
    'deed':'dndDeedToDo'
    'failure':'ifTheDeedisFailed'
    'weapon': 'dndWeapon'
    'property':'magicProperty'
    'mineral': 'dndMineral'
    'reward': 'dndReward'

pluralize =
    'adjective': 'Adjectives'
    'race': 'Races'
    'class': 'Classes'
    'location': 'Locations'
    'backstory': 'Backstories'
    'deed': 'Deeds'
    'failure': 'Failures'
    'weapon': 'Weapons'
    'property':'Properties'
    'mineral': 'Minerales'
    'reward': 'Rewards'


defaults =
    'adjective': "tough"
    'race': "elf"
    'class': "ranger"
    'location': "the woodland kingdoms"
    'backstory': "doesn't take shit from anyone"
    'deed': "save a kitten"
    'failure': "a prince cries himself to sleep"
    'weapon': "Sword"
    'property': "Fire"
    'mineral': "Steel"
    'reward': 'a donut'

    
randItem = (list) ->
    list[Math.floor(Math.random() * list.length)]

module.exports = (robot) ->
    getDb = (key) ->
        dbName = keyToDb[key]
        if dbName
            robot.brain.get(dbName) or [ defaults[key] ]
        else
            null

    saveDb = (key, db) ->
        dbname = keyToDb[key]
        if dbname
            robot.brain.set dbname, db

    respondToKey = (cb) ->
        (msg) ->
            [_, key, content] = msg.match
            db = getDb key

            if not db
                msg.reply "Error: key not valid: '#{key}'"
            else
                cb {msg, content, key, db}

    robot.respond /character help/i, (msg) ->
        msg.send helpText

    rollCharacter = ->
        adj = randItem getDb 'adjective'
        race = randItem getDb 'race'
        dclass = randItem getDb 'class'
        location = randItem getDb 'location'
        backstory = randItem getDb 'backstory'
        "#{adj} #{race} #{dclass} from #{location} who #{backstory}."


    rollQuest = ->
        adj = randItem getDb 'adjective'
        race = randItem getDb 'race'
        dclass = randItem getDb 'class'
        location = randItem getDb 'location'
        deed = randItem getDb 'deed'
        failure = randItem getDb 'failure'
        reward = randItem getDb 'reward'
        "A #{adj} #{race} from #{location} asks the party to #{deed} before #{failure}! In exhange you will recieve #{reward}"

    rollWeapon = ->
        adj = randItem getDb 'adjective'
        weapon = randItem getDb 'weapon'
        property = randItem getDb 'property'
        mineral = randItem getDb 'mineral'
        race = randItem getDb 'race'
        "You are wielding a #{adj} #{weapon} of #{property} that was forged with #{mineral}. The kingdom of #{race}s fear this weapon."    

    robot.respond /(roll me a|create me a|who is my) character/i, (msg) ->
        msg.send rollCharacter()

    robot.respond /(roll us some|create us some|who are our) characters/i, (msg) ->
        msg.send "The intrepid souls of '#{msg.message.user.room}' ..."
        for own key, user of robot.brain.users when user.name != robot.name
            #user = "#{user.name}" if "#{user.name}" != robot.name
            char = rollCharacter()
            msg.send "  #{user.name}, the #{char}"
        msg.send "  ... have banded together to brave the odds in search of The Quest for the Meanigful MacGuffin!"

    robot.respond /(what is our) quest/i, (msg) ->
        msg.send rollQuest()

    robot.respond /(what am I wielding)/i, (msg) ->
        msg.send rollWeapon()
        
    robot.respond /add (\w+) "([^\"]+)"/i, respondToKey ({msg, content, key, db}) ->
        if content not in db
            db.push content
            saveDb key, db
            msg.reply "Added new #{key}: '#{content}'"

        else
            msg.reply "Error: '#{content}' already in #{key}"

    robot.respond /remove (\w+) "([^\"]+)"/i, respondToKey ({msg, content, key, db}) ->
        index = db.indexOf content
        if index > -1
            db.splice index, 1
            saveDb key, db
            msg.reply "Removed '#{content}' from #{key}"

        else
            msg.reply "Couldn't find '#{content}' in #{key}"

    robot.respond /list (\w+)/i, respondToKey ({msg, key, db}) ->
        msg.send "#{pluralize[key]}:\n```'#{ db.join('\n') }'\n```"
