-- audio = require("moduleAudio")  --new version not working for some reason
-- require("moduleAudio") --didnt work either


-- Lua template based service script (called from launch)
local serviceVersion = "1.06" -- Please update the service version here


--[[

Add in any comments, service notes, author, etc... here

--]]

-- Please do not change the code inside the VISYTEL SECTION
-- VISYTEL SECTION START
local templateAuthor = "Andrew Keil (Visytel Pty Ltd)"
local supportEmail = "support@visytel.com"
local templateVersion = "1.11"
local vc = require("visytel.visytelcore")
vc.infoLog(string.format("STARTED VERSION: %s",serviceVersion))
vc.infoLog(string.format("Template by: %s - Email: %s",templateAuthor,supportEmail))
vc.infoLog(string.format("Template version: %s Visytel core version: %s (%s)",templateVersion,vc.version(),_VERSION))
-- VISYTEL SECTION END

-- Setup script wide variables here
local recFile

function PreAnswer()
	vc.infoLog("PRE ANSWER SECTION")
	-- Add your pre answer code from here
	
	-- End of your pre answer code
	vc.infoLog("PRE ANSWER SECTION COMPLETE")
end	

function AnswerCaller()
	vc.answer()
	vc.sleep(1000)
end	
-- pintro|vanswer-6|vname-10|vaddress-15|vpostcode-10|vDoB-6|vtelephone-10|vemail-11|qDPQ1-1|poutro
function MainService()
	--GLOBALS
	PATH_SEPARATOR = "/"
	--GLOBALS

	-- pintro|vanswer-6|vname-10|vaddress-15|vpostcode-10|vDoB-6|vtelephone-10|vemail-11|qDPQ1-1|poutro
  

	vc.infoLog("MAIN SERVICE SECTION")
	if (vc.ready()) then

		local v_TO = vc.getVariable("v_TO")	-- Source called number
		local v_FROM = vc.getVariable("v_FROM") -- Source calling number
		local sessionUUID = vc.getVariable("uuid") -- Get Session UUID		
		local v_CALLFLOW = vc.getVariable("v_CALLFLOW") 				-- Source v_CALLFLOW		

		-- local v_RECORDINGSPATH = vc.getVariable("v_RECORDINGSPATH") 	-- Source v_RECORDINGSPATH
		-- vc.infoLog(string.format("v_RECORDINGSPATH = %s", v_RECORDINGSPATH))
		vc.infoLog(string.format("ServiceID = %s", v_SERVICEID))		
		
		local callflow_table = {}
		local cfTaskStingTable = vc.split(v_CALLFLOW,"[^|]+") -- Split up v_CALLFLOW based on "|" character dividing each task
		local i
    local playRecordOptions = {audioExtension = ".wav", silenceThreadhold = 50, silenceSecs = 3} 
    local playOptionsInteruptFalse = {playRecordOptions, interuptPrompt = false}
    local playOptionsInteruptTrue = {playRecordOptions, interuptPrompt = true, interruptKeys ='1234567890*#'}
    local promptFileName = ""
    
		
    local gencap = {}
    function gencap.singleSplit(stringToSplit, splitOn)
      local splitTable = {}
      splitTable = vc.split(stringToSplit, splitOn)
      return splitTable[1], splitTable[2]				
    end          
    
    function gencap.playFile(fileToPlay, playOptions)
      vc.infoLog(string.format("playOptions.playRecordOptions.audioExtension = %s", playOptions[1].audioExtension))	
      vc.infoLog(string.format("fileToPlay = %s", fileToPlay))      
      fileToPlay = fileToPlay .. playOptions[1].audioExtension         
      vc.infoLog(string.format("fileToPlay = %s", interuptString))
      vc.streamFileGetDigit(fileToPlay,playOptions['interruptKeys'],0)      
    end
    
    function singleSplit(stringToSplit, splitOn)
      local splitTable = {}
      splitTable = vc.split(stringToSplit, splitOn)
      return splitTable[1], splitTable[2]				
    end
    
    for i = 1, #cfTaskStingTable do
			vc.infoLog(string.format("v_CALLFLOW task: %s",cfTaskStingTable[i])) -- Currently just log the v_CALLFLOW task
			local cfTaskLetter = string.lower(string.gsub(cfTaskStingTable[i], "(%w)(.*)", "%1"))
			local cfTaskKeyValue = string.lower(string.gsub(cfTaskStingTable[i], "(%w)(.*)", "%2"))
			vc.infoLog(cfTaskLetter)
			vc.infoLog(cfTaskKeyValue)
			-- vc.infoLog(string.format("v_CALLFLOW Letter: %s",cfTaskLetter))
			-- vc.infoLog(string.format("v_CALLFLOW KeyValue: %s",cfTaskKeyValue))
			if cfTaskLetter == 'p' then
        --[[
        pintro
        pintro(DDI) e.g intro09061741921.raw
        
        --]]
				--check if we need to play a custom prompt (based on DDI)
        local customTask = string.match(cfTaskKeyValue, "%(([^)]+)%)") --return a string located within parenthesis 
        vc.infoLog(string.format("customTask = %s", customTask))		
        if customTask then          
          customTask = customTask:lower()
          vc.infoLog(string.format("customWorking String = %s", cfTaskKeyValue))		
          if string.find(customTask,"ddi") then
            local prefixPrompt = string.match(cfTaskKeyValue, "(.*)(:?%(.*%))")
            promptFileName = prefixPrompt .. v_TO           
          else
            promptFileName = cfTaskKeyValue
          end
        end
        
        -- vc.infoLog(string.format("The audio filename is: %s", _audioFilename))
        -- vc.streamFile(_audioFilename)
        gencap.playFile(promptFileName, playOptionsInteruptTrue)
        
      end			
      if cfTaskLetter == 'q' then 
        -- qDPQ1-1
        cfPrompt, cfNoOfDigits = gencap.singleSplit(cfTaskKeyValue, "[^-]+")
        --local cfConfigTable = vc.split(cfTaskKeyValue,"[^-]+")
				-- local cfPrompt = cfConfigTable[1]
				-- local cfNoOfDigits = cfConfigTable[2]
				cfNoOfDigits = tonumber(cfNoOfDigits)
                
        local dpqValue = ""
        local noOfAttempts = 1
        local DTMFtimeout =3000
        local errorPrompt = ""
        local terminationString = ""
        local digitREGEX = "\\d+"
				if cfNoOfDigits == 1 then
          dpqValue = vc.dtmfMenu("1234567890", 1, 3000, audioFilename,"","","","") 
        end
        else 
          dpqValue = vc.playAndGetDigits(cfNoOfDigits,cfNoOfDigits, noOfAttempts, DTMFtimeout, terminationString, cfPrompt, errorPrompt, digitREGEX)
          
          
        
        -- vc.infoLog(string.format("The DTMF value is : %s", dpqValue))
      --qDPQ1-1
      end
      
      if cfTaskLetter == 'v' then
				-- vname-10				
				local cfPrompt, cfRecordFor
        cfPrompt, cfRecordFor = singleSplit(cfTaskKeyValue, "[^-]+")
        vc.infoLog(string.format("The record prompt is: %s and record for %s seconds", cfPrompt, cfRecordFor))
        -- local cfConfigTable = vc.split(cfTaskKeyValue,"[^-]+")
				-- local cfPrompt = cfConfigTable[1]
				-- local cfRecordFor = cfConfigTable[2]
				cfPrompt = cfPrompt .. playRecordOptions.audioExtension
				

				recFile = "%v_RECORDINGSPATH%/%v_SERVICEID%/" .. os.date("%Y%m%d%H%M%S",os.time()) .. "-" .. sessionUUID .. ".wav"
				vc.streamFile(cfPrompt,"%v_SYSTEMAUDIOPATH%/beep.wav")
				vc.recordFile(recFile,cfRecordFor,50,3,"*#")
				--vc.recordFile("rec.wav",10,50,3,"*#")
				
				--[[
				local recFile
				-- recFile = "%v_RECORDINGSPATH%/%v_SERVICEID%/" .. os.date("%Y%m%d%H%M%S",os.time()) .. "-" .. sessionUUID .. ".wav"
				recFile = "%v_RECORDINGSPATH%/%v_SERVICEID%/" .. os.date("%Y%m%d%H%M%S",os.time()) .. "-" .. sessionUUID .. ".wav"
				-- recFile = v_RECORDINGSPATH .. PATH_SEPARATOR .. v_SERVICEID  .. PATH_SEPARATOR .. os.date("%Y%m%d%H%M%S",os.time()) .. "-" .. sessionUUID .. ".wav"
				vc.infoLog(string.format("The recordingfile is: %s", recFile))
				vc.streamFile(_audioFilename,"%v_SYSTEMAUDIOPATH%/beep.wav")
				vc.recordFile(recFile,cfRecordFor,silenceThreadhold,silenceSecs)
				]]
			end

		end	
	end
	
	if (vc.ready()) then
		-- End of service so hangup
		vc.streamFile("%v_SYSTEMAUDIOPATH%/hangup.wav") -- Play hangup tone
		vc.infoLog("END OF SERVICE (HANGUP)")
		vc.hangup()  -- Should automatically jump to CleanUp() via hangup handler if caller still online at this stage
	end
end

function CleanUp()
	vc.infoLog("CLEANUP SECTION")
	-- Add your cleanup code from here (caller would have been disconnected)
	
	-- End of your cleanup code
	vc.infoLog("CLEANUP SECTION COMPLETE")
	vc.infoLog("COMPLETE")
end	

-- Please do not change the code inside the VISYTEL SECTION
-- VISYTEL SECTION START
function myHangupHook(s, status, arg)
	vc.infoLog(string.format("%s DETECTED",arg))
	vc.hangup()
    -- Run CleanUp function now since the caller has disconnected	
	CleanUp()
end
-- Setup Hangup event handler here
v_hangup = "HANGUP"
vc.setHangupHook("myHangupHook", "v_hangup")
-- Call service functions in order
PreAnswer()
AnswerCaller()
MainService()
-- VISYTEL SECTION END