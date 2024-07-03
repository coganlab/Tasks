   function Lex_DecisionRepeat_NoDelay_Mouse_2x(subject,practice,startblock)
% Modified Lexical Decision NoDelay Mouse
% will be based on Word and Non-word stimuli
% Created 080818 by Anna
% Updated 220818
% Commands: Subject ID: 'D#'; practice = 0, startblock = 1 (if not
% interrupted)

% %% Manipulations
sca;
[playbackdevID,capturedevID] = getDevices;

%playbackdevID = 7; % 3 if no usb microphone 3, otherwise, 4 
%capturedevID = 6; %1
% number of blocks
nBlocks = 4; 
% block start
iBStart=startblock;
blockCount = 0;
% number of trials in a block
trialEnd= 126; 
% Create subject ID and create directory
c = clock;
baseName = fullfile('data', [subject '_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))]);
% Change TASKNAME based on the task
subjectDir = baseName; % change where this file will be saved

trialInfo=[];
if exist(subjectDir, 'dir')
    mkdir(subjectDir)
elseif ~exist(subjectDir, 'dir')
    mkdir(subjectDir)
end

load('/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/TokenCategory.mat');

% Initialize stim from directory
soundDirW = '/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/words/';
soundDirNW= '/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/nonwords/';
% Sound setup
nrchannels = 1;
freqS = 44100;
freqR = 44100; %20000
fileSuff = ''; 
repetitions = 1;

% Initialize Sounddriver
InitializePsychSound(1);
StartCue = 0;
WaitForDeviceStart = 1;
% gathers audio stimuli Words from directory

load stim.mat;

soundValsW=[];
dirValsW=dir(fullfile(soundDirW, '*.wav'));
mask1 = ismember({dirValsW.name}, {highW.name});
mask2 = ismember({dirValsW.name}, {lowW.name});
dirValsW = dirValsW(mask1 | mask2);
for iS=1:length(dirValsW)
    soundNameW=dirValsW(iS).name;
    soundValsW{iS}.sound=audioread([soundDirW soundNameW]);
    soundValsW{iS}.name=soundNameW; 
end
% soundValsW = cat(2, soundValsW, soundValsW, soundValsW);

soundValsNW=[];
dirValsNW=dir(fullfile(soundDirNW, '*.wav'));
mask1 = ismember({dirValsNW.name}, {highNW.name});
mask2 = ismember({dirValsNW.name}, {lowNW.name});
dirValsNW = dirValsNW(mask1 | mask2);
for iS=1:length(dirValsNW)
    soundNameNW=dirValsNW(iS).name;
    soundValsNW{iS}.sound=audioread([soundDirNW soundNameNW]);
    soundValsNW{iS}.name=soundNameNW;
end
% soundValsNW = cat(2, soundValsNW, soundValsNW, soundValsNW);

trialOrderAll1 = repmat(1:42, 1, 12);
ot = ones(1,84);
trialOrderAll2 = [1*ot 2*ot 3*ot 4*ot 5*ot 6*ot];
trialOrderAll = [trialOrderAll1;trialOrderAll2];
shuffleIdx = Shuffle(1:length(trialOrderAll));

if startblock==1
    trialOrderAll_Shuffle=trialOrderAll(:,shuffleIdx);
    save(fullfile('trialorder_data', [subject '_trialOrderAll_Shuffle.mat']),'trialOrderAll_Shuffle');
elseif startblock>1
    load(fullfile('trialorder_data', [subject '_trialOrderAll_Shuffle.mat']));
end

% Default setting for setting up PTB
PsychDefaultSetup(2);

% Get the screen number
screens = Screen('Screens');

% Draw to the external screen if available
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
grey = white/2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Set the blend funnction for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the text size
Screen('TextSize', window, 38);

% Circle
baseCircleDiam=75; % diameter of circle
baseCircle = [0 0 baseCircleDiam baseCircleDiam];
centeredCircle = CenterRectOnPointd(baseCircle, screenXpixels-0.5*baseCircleDiam, 1+0.5*baseCircleDiam); %

circleColor1 = [1 1 1]; % white

% Keyboard information
% Define the keyboard keys
KbName('UnifyKeyNames');
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
NoKey = KbName('RightArrow');
YesKey = KbName('LeftArrow');
eKey = KbName('E');
acceptedKeys = [YesKey, NoKey, spaceKey, escapeKey,eKey]; % accepted keys for response
RestrictKeysForKbCheck(acceptedKeys);
% Suppress echo to the command line for keypresses
ListenChar(2);

%Experimental loop
trialCount = 0;

% Practice session
if practice==1
    trialEnd = 12; 
    nBlocks = 1;
    fileSuff = '_Practice';
end

% Ready Loop
while ~KbCheck % Wait for a key press
    DrawFormattedText(window, 'If you see the cue Yes/No, please press the left arrow key for a word\n and the right arrow key for a non-word. \nIf you see the cue Repeat, please repeat the word\nonword.\nRespond as quickly as possible. \n :=: means just listen and do not respond. \nPress any key to start. ','center', 'center', white);
    Screen('Flip',window); %Flip to the screen
    WaitSecs(0.001);
end

WaitSecs(1);
Screen('Flip', window);
% Block Loop
for iB=iBStart:nBlocks
pahandle = PsychPortAudio('Open', playbackdevID, 1, 2, freqS, nrchannels, 0, 0.015);
ifi_window = Screen('GetFlipInterval', window);
waitframes = ceil((2 * 0.015) / ifi_window) + 1;

Priority(2);
 [sound fs]=audioread('/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/blank.wav');
PsychPortAudio('FillBuffer', pahandle, sound');
%Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
tPredictedVisualOnset = PredictVisualOnsetForTime(window, tWhen);
PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);


    trialOrderBlockItem=trialOrderAll_Shuffle(1,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    trialOrderBlockTask=trialOrderAll_Shuffle(2,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    cueTimeBaseSeconds= 2.0 ; %1.5 up to 5/26/2019% 0.5 Base Duration of Cue s
    delTimeBaseSecondsA = 1; % 0.75 Base Duration of Del s
    delTimeBaseSecondsB = 2.5;
    goTimeBaseSeconds = 0.5; % 0.5 Base Duration Go Cue Duration s
    respTimeSecondsA = 1.5; % 1.5 Response Duration s
    respTimeSecondsB = 3; % for sentences
    isiTimeBaseSeconds = 0.75; % 0.5 Base Duration of ISI s
    
    cueTimeJitterSeconds = 0.25; % 0.25; % Cue Jitter s
    delTimeJitterSeconds = 0.25;% 0.5; % Del Jitter s
    goTimeJitterSeconds = 0.25;% 0.25; % Go Jitter s
    isiTimeJitterSeconds = 0.25; % 0.5; % ISI Jitter s
    soundBlockPlay = [];
    counterW=0;
    counterNW=0;
    for iTrials=1:trialEnd
                       
       if trialOrderBlockTask(iTrials)==1
           trigVal=trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.Trigger=trigVal; 
           soundBlockPlay{iTrials}.visualcue = 'Yes/No';
           soundBlockPlay{iTrials}.wordtype = 'word';
           counterW=counterW+1;
       
       elseif trialOrderBlockTask(iTrials)==2
           trigVal=100+trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsNW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsNW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.Trigger=trigVal;
           soundBlockPlay{iTrials}.wordtype = 'nonword';
           soundBlockPlay{iTrials}.visualcue = 'Yes/No';
           
           
       elseif trialOrderBlockTask(iTrials)==3
           trigVal=200+trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.Trigger=trigVal;
           soundBlockPlay{iTrials}.visualcue = 'Repeat';
           soundBlockPlay{iTrials}.wordtype = 'word';
           counterW=counterW+1;
       
       elseif trialOrderBlockTask(iTrials)==4
           trigVal=300+trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsNW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsNW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.Trigger=trigVal;
           soundBlockPlay{iTrials}.visualcue = 'Repeat';
           soundBlockPlay{iTrials}.wordtype = 'nonword';
           %counterNW=counterNW+1;
           
       elseif trialOrderBlockTask(iTrials)==5
           trigVal = 400 + trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.visualcue = ':=:';
           soundBlockPlay{iTrials}.wordtype = 'word';
           soundBlockPlay{iTrials}.Trigger=trigVal;
           
       elseif trialOrderBlockTask(iTrials)==6
           trigVal = 500 + trialOrderBlockItem(iTrials);
           soundBlockPlay{iTrials}.sound=soundValsNW{trialOrderBlockItem(iTrials)}.sound;
           soundBlockPlay{iTrials}.name=soundValsNW{trialOrderBlockItem(iTrials)}.name;
           soundBlockPlay{iTrials}.Trigger=trigVal;
           soundBlockPlay{iTrials}.wordtype = 'nonword';
           soundBlockPlay{iTrials}.visualcue = ':=:';
       end 
    end
    % Setup recording!
    pahandle2 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0, 0.015);
    
    % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:    
   PsychPortAudio('GetAudioData', pahandle2, 9000); %nTrials



    %PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Start', pahandle2, 0, 0, 1);
    
    % play tone!
    tone500=audioread('/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/tone500_3.wav');
   PsychPortAudio('Volume', pahandle, 1); % volume
    PsychPortAudio('FillBuffer', pahandle, 0.005*tone500');
    PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Volume', pahandle, 0.5);

   toneTimeSecs = (freqS+length(tone500))./freqS; %max(cat(1,length(kig),length(pob)))./freqS;
    toneTimeFrames = ceil(toneTimeSecs / ifi);
    for i=1:toneTimeFrames
        
        DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
    end
    
    for iTrials=1:trialEnd
        Screen('TextSize', window, 100);

        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        cue = soundBlockPlay{iTrials}.visualcue;
        sound=soundBlockPlay{iTrials}.sound;%eval(trialStruct.sound{trialShuffle(2,iTrials)});
        sound=sound(:,1);
        soundTimeSecs = length(sound)./freqS; %max(cat(1,length(kig),length(pob)))./freqS;
        soundTimeFrames = ceil(soundTimeSecs / ifi);
        cueTimeBaseFrames = round((cueTimeBaseSeconds+(cueTimeJitterSeconds*rand(1,1))) / ifi);
        % write trial structure
        flipTimes = zeros(1,cueTimeBaseFrames);
        trialInfo{trialCount+1}.cue = cue;
        trialInfo{trialCount+1}.sound = soundBlockPlay{iTrials}.name;%trialStruct.sound{trialShuffle(2,iTrials)};
        trialInfo{trialCount+1}.cueTime=GetSecs;
        trialInfo{trialCount+1}.block = iB;
        trialInfo{trialCount+1}.cueStart = GetSecs;
        trialInfo{trialCount+1}.Trigger=soundBlockPlay{iTrials}.Trigger;
        % Draw inital Cue text
        for i = 1:cueTimeBaseFrames
            % Draw oval for 10 frames (duration of binary code with start/stop bit)
            if i<=3
                Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
            end
            if i<=0.625*cueTimeBaseFrames
                % Draw text
                DrawFormattedText(window, cue, 'center', 'center', [1 1 1]);
            end
            % Flip to the screen
            flipTimes(1,i) = Screen('Flip', window);
        end
        loopStart = GetSecs;
        PsychPortAudio('FillBuffer', pahandle, sound');
        Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
        tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
        tPredictedVisualOnset = PredictVisualOnsetForTime(window, tWhen);
        PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);
        [~,stimulus_trigger_onset] = Screen('Flip', window, tWhen);
        Screen('Flip', window, tWhen);
        offset = 0;
        while offset == 0
            status = PsychPortAudio('GetStatus', pahandle);
            offset = status.PositionSecs;
            WaitSecs('YieldSecs', 0.001);
        end
        WaitSecs('UntilTime', loopStart + .25);
        Screen('Flip', window);
        stimulus_audio_onset = status.StartTime;
        
        
        % set value for maximum time to wait for response (in seconds)
        t2wait = 3.5;
        tStart = GetSecs;
        
        respToBeMade = true;
        wordtype = soundBlockPlay{iTrials}.wordtype;
        
        while respToBeMade
            
            [x,y,buttons]=GetMouse;
            [keyIsUp, secs, pressedKey] = KbCheck;
            % NB: Setup for Left Handers
            if strcmp(wordtype, 'word') && (buttons(1)==1 || pressedKey(YesKey)) % Correct key response
                resp = 'Yes';
                keypress = YesKey;
                respcorrect = 1;
                respToBeMade = false;
                RT_timedout = 'Responded';
                WaitSecs(.75);
            elseif strcmp(wordtype, 'word') && (buttons(3) || pressedKey(NoKey)) % Incorrect key response
                resp = 'No';
                respcorrect = 0;
                keypress = NoKey;
                respToBeMade = false;
                RT_timedout = 'Responded';
                WaitSecs(.75);
            elseif strcmp(wordtype, 'nonword') && (buttons(3) || pressedKey(NoKey))% Correct key response
                resp = 'No';
                respcorrect = 1;
                keypress = NoKey;
                respToBeMade = false;
                RT_timedout = 'Responded';
                WaitSecs(.75);
            elseif strcmp(wordtype, 'nonword') && (buttons(1)|| pressedKey(YesKey)) % Incorrect key response
                resp = 'Yes';
                respcorrect = 0;
                keypress = YesKey;
                respToBeMade = false;
                RT_timedout = 'Responded';
                WaitSecs(.75);
            end
%             if(keyIsUp), break; end
            if((secs - tStart) > t2wait)
                resp = 'No Response';
                respcorrect = 0;
                keypress = acceptedKeys;
                respToBeMade = false;
                RT_timedout = 'No Response';
            end % Response time exceeded wait; should be noted as No Response (NR)
        end
        Screen('Flip', window);
        WaitSecs(.25);
        RT=secs-stimulus_audio_onset; % Get reaction time
        
        % Write trial structure
        trialInfo{trialCount+1}.block = iB;
        trialInfo{trialCount+1}.ReactionTime = RT;
        trialInfo{trialCount+1}.KeyCode = keypress;
        trialInfo{trialCount+1}.Resp = resp;
        trialInfo{trialCount+1}.RespCorrect = respcorrect;
        trialInfo{trialCount+1}.Omission = RT_timedout;
        trialInfo{trialCount+1}.stimulusAudioStart = stimulus_audio_onset;
        trialInfo{trialCount+1}.stimulusAlignedTrigger = stimulus_trigger_onset ;
        trialInfo{trialCount+1}.TriggerValue = trigVal(1);
        trialInfo{trialCount+1}.TokenCategory=tokenCategory(trialOrderAll(iTrials));
        
        save([subjectDir '/' subject '_Block_' num2str(iB) fileSuff '_TrialData.mat'],'trialInfo')
 
        
        % Reset the keyboard input checking for all keys
        RestrictKeysForKbCheck;
        ListenChar(1);
        trialCount = trialCount + 1;

    end
    Priority(0);
    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2);
    filename = ([subject '_Block_' num2str(iB) fileSuff '_AllTrials.wav']);
    audiowrite([subjectDir '/' filename],audiodata,freqR);
    PsychPortAudio('Stop', pahandle2);
    PsychPortAudio('Close', pahandle2);
    % Stop playback
    PsychPortAudio('Stop',pahandle);
    % Close the audio device
    PsychPortAudio('Close',pahandle);
    
    blockCount=blockCount+1;
% % Break Screen    
    Screen('TextSize', window, 38);

    while ~KbCheck
        DrawFormattedText(window, 'Take a short break and press the space bar to continue.', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.001);
    end    

end

sca;
close all;












