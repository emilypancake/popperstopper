skip = false
hs.notify.withdrawAll()
hs.execute("pkill afplay")
debugMode = false

function tutorial()
    hs.hotkey.bind({"cmd", "shift"}, "8", function()
        skip = true
    end)
    
    title = {
        "🎁 Hooray!",
        "⚠️ Do not skip tutorial if you just started!",
        "⚠️ If you have Do not Disturb enabled",
        "To quit the script",
        "To restart the script",
        "For setup"
    }
    message = {
        "Welcome to emilypancake's first big project on GitHub!",
        "CMD + SHIFT + 8 to skip tutorial.",
        "Do not Disturb disables notifications. Without notifications, errors or debug mode won't work. However the script will still prevent popping without notification access. Notifications help you better understand the code.",
        "Press CMD + SHIFT + 9 to quit script at any time.",
        "Quit and reopen the Hammerspoon app to restart.",
        "Visit popperstopper Github repository for instructions!"
    }
    timeSkip = 0

    hs.dialog.blockAlert(title[1], message[1], "OK") -- yep loops exist but for some reason for loops don't stop the pausing mechanism
    if not skip then -- yep because blockAlert doesn't pause with loops then manually it is
        hs.dialog.blockAlert(title[2], message[2], "OK")
    end
    if not skip then
        hs.dialog.blockAlert(title[3], message[3], "OK")
    end
    if not skip then
        hs.dialog.blockAlert(title[4], message[4], "OK")
    end
    if not skip then
        hs.dialog.blockAlert(title[5], message[5], "OK")
    end
    if not skip then
        hs.dialog.blockAlert(title[6], message[6], "OK")
    end
end
tutorial()
debugMode = hs.dialog.blockAlert("Do you want to enable debug mode?", "If Yes, you will get notifications for every successful step and error. \n \n If No [recommended], you'll only get notifications for errors.", "Yes", "No") == "Yes"


hs.hotkey.bind({"cmd", "shift"}, "9", function()
    exitScript = hs.dialog.blockAlert("Do you want to exit the Anti Pop/Crackle script?", "Yes to exit, No to stay.", "Yes", "No")
    if exitScript == "Yes" then
        return
    end
end)

local audioDevice = hs.audiodevice.defaultOutputDevice()

-- create folder for silent audio if doesn't exist, accesses it if it does exist
local folderPath = os.getenv("HOME") .. "/Desktop/StopAnnoyingHeadphonePop" 
local folderExists = hs.fs.attributes(folderPath)
if not folderExists then
    local newFolder = hs.fs.mkdir(folderPath)
    if not newFolder then
        hs.dialog.blockAlert(
        "⚠️ Error creating folder",
        "Failed to create new folder at\n" .. folderPath .. "\n\nDo I have permission to access files, like full disk access?\n\n Please restart the script afterwards!",
        "OK"
        )
        hs.timer.doAfter(3, function()
            error("Error creating folder.")
        end)
    else
        hs.alert.show("Mode" .. debugMode)
        if debugMode then
            hs.notify.new({
                title = "✅  Created folder at",
                informativeText = folderPath,
                withdrawAfter = 0
            }):send()
        end
    end
else
   if debugMode then
        hs.notify.new({
            title = "✅  Accessed folder at",
            informativeText = folderPath,
            withdrawAfter = 0
        }):send()
    end
end

-- download the silent file if doesn't exist, accesses it if it does
audioFilePath = folderPath .. "/silent.mp3"

if not hs.fs.attributes(audioFilePath) then
    local fileUrl = "https://github.com/emilypancake/popperstopper/raw/refs/heads/main/silent.mp3"  -- Replace this with the actual raw URL
    hs.execute("curl -L " .. fileUrl .. " -o " .. audioFilePath)
    if not hs.fs.attributes(audioFilePath) then
        hs.dialog.blockAlert("⚠️ Error finding URL", "Did Emily's url not work?\nDo you have internet access? \nIs your firewall blocking Github or Curl?", "OK")
        hs.timer.doAfter(3, function()
            error("Error finding URL.")
        end)
    else 
        if debugMode then
            hs.notify.new({
                title = "✅  Created silent file at",
                informativeText = audioFilePath,
                withdrawAfter = 0
            }):send()
        end
    end
else
    if debugMode then
        hs.notify.new({
            title = "✅  Accessed silent file at", 
            informativeText = audioFilePath, 
            withdrawAfter = 0
        }):send()
    end
end

function checkAndPlaySilentAudio()
    if debugMode then
        hs.notify.new({
            title = "Device Name:",
            informativeText = audioDevice:name(),
            withdrawAfter = 0
        }):send()
    end
    if string.match(string.lower(audioDevice:name()), "headphones") then 
        if hs.execute("pgrep afplay") == "" then 
            if debugMode then
                hs.notify.new({
                    title = "✅  Noticed audio is silent",
                    informativeText = "Attempting to enable anti pop!",
                    withdrawAfter = 0
                }):send()
            end
            hs.task.new("/usr/bin/afplay", function(exitCode, standardOutput, standardError)
                if exitCode ~= 0 then
                    hs.dialog.blockAlert("⚠️ afplay issue", "Exit Code: ".. exitCode.. "\nOut: ".. standardOutput .. "\nErrorOut: " .. standardError, "OK")
                    error("afplay issue") 
                end     
                
                
            end , {audioFilePath}):start()
        end
    else
        hs.execute("pkill afplay") 
    end
end


checkAndPlaySilentAudio() 
hs.timer.doEvery(3600, function()
    checkAndPlaySilentAudio() 
end)



