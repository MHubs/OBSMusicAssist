script iTunesBridge
    
    property parent : class "NSObject"
    
    
    to isRunning() -- () -> NSNumber (Bool)
    -- AppleScript will automatically launch apps before sending Apple events;
    -- if that is undesirable, check the app object's `running` property first
        return running of application "iTunes"
    end isRunning


to playerState() -- () -> NSNumber (PlayerState)
    tell application "iTunes"
        if running then
            set currentState to player state
    -- ASOC does not bridge AppleScript's 'type class' and 'constant' values
            set i to 1
            repeat with stateEnumRef in {stopped, playing, paused, fast forwarding, rewinding}
                if currentState is equal to contents of stateEnumRef then return i
                set i to i + 1
            end repeat
        end if
        return 0 -- 'unknown'
    end tell
end playerState


to trackInfo() -- () -> ["trackName":NSString, "trackArtist":NSString, "trackAlbum":NSString]?
    tell application "iTunes"
        try
            return {trackName:name, trackArtist:artist, trackAlbum:album} of current track
        on error number -1728 -- current track is not available
            return missing value -- nil
        end try
    end tell
end trackInfo

end script
