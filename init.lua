hs.notify.withdrawAll()

debugMode = hs.dialog.blockAlert("Do you want to enable debug mode?", "If Yes, you will get notifications for every successful step and error. If No, you'll only get notifications for errors.", "Yes", "No")


notify = hs.notify.new({
    title = "🎁  Anti Pop/Crackle app opening!", 
    informativeText = "Hooray! Welcome to my first big project on GitHub! Press CMD + SHIFT + 9 to quit.",
    withdrawAfter = 0
}):send()

hs.hotkey.bind({"cmd", "shift"}, "9", function()
    exitScript = hs.dialog.blockAlert("Do you want to exit the Anti Pop/Crackle script?", "Yes to exit, No to stay.", "Yes", "No")
    if exitScript == "Yes" then
        os.exit()
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
    
    if string.match(string.lower(audioDevice:name()), "headphones") then  -- this only works if your audio device name contains headphones
        local output = hs.execute("pgrep afplay")   -- grep is like control f 
        output = output and output:gsub("%s+", "") 

        if output == nil or output == "" then 
            hs.execute("afplay " .. audioFilePath) 
        end
    else
        hs.execute("pkill afplay") 
    end
end

hs.timer.doEvery(60, function()
    checkAndPlaySilentAudio() 
end)
checkAndPlaySilentAudio()

