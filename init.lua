done = false
hs.notify.withdrawAll()
hs.execute("pkill afplay")


hs.alert.show("🎁 Hooray! Welcome to emilypancake's first big project on GitHub!")


hs.timer.doAfter(2.1, function()
    hs.alert.show("⚠️ If you have Do not Disturb enabled then") 
end)

hs.timer.doAfter(4.2, function()
    hs.alert.show("⚠️ without notifications, errors or debug mode won't work")
end)

hs.timer.doAfter(6.3, function()
    hs.alert.show("✅ The script will still work without notifications")
end)

hs.timer.doAfter(8.4, function()
    hs.alert.show("Press CMD + SHIFT + 9 to quit script.")
end)

hs.timer.doAfter(10.5, function()
    hs.alert.show("Open Hammerspoon to start.")
end)

hs.timer.doAfter(12.6, function()
    hs.alert.show("For setup, visit popperstopper Github repository.")
end)

debugMode = hs.dialog.blockAlert("Do you want to enable debug mode?", "If Yes, you will get notifications for every successful step and error. \n \n If No [recommended], you'll only get notifications for errors.", "Yes", "No")





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
        notify = hs.notify.new({
            title="⚠️ Error creating folder", 
            informativeText="Do I have permission, like full disk access?", 
            withdrawAfter = 0
        }):send()
        error("Attempted to create new folder but failed. Do I have permission to access files, like full disk access?")
    else
        hs.alert.show("Mode" .. debugMode)
        if debugMode == "Yes" then
            hs.notify.new({
                title = "✅  Created folder at",
                informativeText = folderPath,
                withdrawAfter = 0
            }):send()
        end
    end
else
   if debugMode == "Yes" then
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
        hs.notify.new({
            title = "⚠️ Error finding URL",
            informativeText = "Did Emily's url not work? Do you have internet access? Is your firewall blocking Github or Curl?",
            withdrawAfter = 0
        }):send()
        hs.timer.doAfter(3, function()
            error("Error finding URL. Did Emily's url not work? Do you have internet access? Is your firewall blocking Github or Curl?")
        end)
    else 
        if debugMode == "Yes" then
            hs.notify.new({
                title = "✅  Created silent file at",
                informativeText = audioFilePath,
                withdrawAfter = 0
            }):send()
        end
    end
else
    if debugMode == "Yes" then
        hs.notify.new({
            title = "✅  Accessed silent file at", 
            informativeText = audioFilePath, 
            withdrawAfter = 0
        }):send()
    end
end

function checkAndPlaySilentAudio()
    if debugMode == "Yes" then
        hs.alert.show(audioDevice:name());
    end
    if string.match(string.lower(audioDevice:name()), "headphones") then  -- this only works if your audio device name contains headphones
        output = hs.execute("pgrep afplay") -- finds audio
        if output == "" or output == nil then 
            if debugMode == "Yes" then
                hs.notify.new({
                    title = "✅  Noticed audio is silent",
                    informativeText = "Attempting to enable anti pop!",
                    withdrawAfter = 0
                }):send()
            end
            hs.task.new("/usr/bin/afplay", function(exitCode, standardOutput, standardError)
                hs.notify.new({
                    title = "⚠️ afplay issue",
                    informativeText = "Exit Code: ".. exitCode.. ", Out: ".. standardOutput .. "ErrorOut: " .. standardError,
                    withdrawAfter = 0
                }):send()
                
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



