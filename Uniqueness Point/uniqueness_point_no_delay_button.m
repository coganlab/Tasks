function uniqueness_point_no_delay_button(subject,practice,startblock)
% Modified Lexical Decision NoDelay Mouse
% will be based on Word and Non-word stimuli
% Created 080818 by Anna
% Updated 220818
% Commands: Subject ID: 'D#'; practice = 0, startblock = 1 (if not
% interrupted)

% %% Manipulations
sca;
[playbackdevID,capturedevID] = getDevices;
%playbackdevID = 7; %6           %3% 3 if no usb speaker 3, otherwise, 4
%capturedevID = 6;  %8           %1
vol = 2;
% number of blocks
nBlocks = 4; 
% block start
iBStart=startblock;
blockCount = 0;
% number of trials in a block
trialEnd= 120; 
% Create subject ID and create directory
c = clock;
%baseName = ['home/coganlab/Psychtoolbox_Scripts/uniqueness_point/data/' subject '_uniqueness_point_no_delay_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];
baseName = ['data/' subject '_uniqueness_point_no_delay_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];

% Change TASKNAME based on the task
subjectDir = baseName; % change where this file will be saved

trialInfo=[];
if exist(subjectDir, 'dir')
    mkdir(subjectDir)
elseif ~exist(subjectDir, 'dir')
    mkdir(subjectDir)
end

% Initialize stim from directory
soundDirW4 = '/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/stim/w4/';
soundDirW7 = '/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/stim/w7/';
soundDirNW4= '/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/stim/nw4/';
soundDirNW7= '/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/stim/nw7/';
% Sound setup
nrchannels = 1;
freqS = 44100;
%exit
%freqR = 20000;
freqR = 44100;
fileSuff = ''; 
repetitions = 1;

% Initialize Sounddriver
%InitializePsychSound(1);
InitializePsychSound();
StartCue = 0;
WaitForDeviceStart = 1;
% gathers audio stimuli Words from directory

soundValsW4=[];
dirValsW=dir(fullfile(soundDirW4, '*.wav'));
for iS=1:length(dirValsW)
    soundNameW=dirValsW(iS).name;
    soundValsW4{iS}.sound=audioread([soundDirW4 soundNameW]);
    soundValsW4{iS}.name=soundNameW; 
end

soundValsW7=[];
dirValsW=dir(fullfile(soundDirW7, '*.wav'));
for iS=1:length(dirValsW)
    soundNameW=dirValsW(iS).name;
    soundValsW7{iS}.sound=audioread([soundDirW7 soundNameW]);
    soundValsW7{iS}.name=soundNameW; 
end

soundValsW = cat(2, soundValsW4, soundValsW7);

soundValsNW4=[];
dirValsNW=dir(fullfile(soundDirNW4, '*.wav'));
for iS=1:length(dirValsNW)
    soundNameNW=dirValsNW(iS).name;
    soundValsNW4{iS}.sound=audioread([soundDirNW4 soundNameNW]);
    soundValsNW4{iS}.name=soundNameNW;
end

soundValsNW7=[];
dirValsNW=dir(fullfile(soundDirNW7, '*.wav'));
for iS=1:length(dirValsNW)
    soundNameNW=dirValsNW(iS).name;
    soundValsNW7{iS}.sound=audioread([soundDirNW7 soundNameNW]);
    soundValsNW7{iS}.name=soundNameNW;
end

soundValsNW = cat(2, soundValsNW4, soundValsNW7);


trialOrderAll1 = repmat(1:40, 1, 12);
ot = ones(1,80);
trialOrderAll2 = [1*ot 2*ot 3*ot 4*ot 5*ot 6*ot];
trialOrderAll = [trialOrderAll1;trialOrderAll2];
shuffleIdx = Shuffle(1:length(trialOrderAll));

if startblock==1
    trialOrderAll_Shuffle=trialOrderAll(:,shuffleIdx);
    save(['/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/' subject '_trialOrderAll_Shuffle.mat'],'trialOrderAll_Shuffle');
elseif startblock>1
    load(['/home/coganlab/Psychtoolbox_Scripts/uniqueness_point/' subject '_trialOrderAll_Shuffle.mat']);
end

% Write event codes to parallel port
% create an instance of the io64 object
% ioObj = io64;
% initialize the interface to the inpout64 system driver
% if status = 0, you are now ready to write and read to a hardware port
% address = hex2dec('378'); % standard LPT1 output port address
% srate = 2500; % sampling rate set in Brain Recorder

% Setup screen
% Default setting for setting up PTB
PsychDefaultSetup(2);

% Get the screen number
%Screen('Preference', 'ConserveVRAM', 64);
screens = Screen('Screens');


% Draw to the external screen if available
screenNumber = max(screens);
screenNumber
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
acceptedKeys = [YesKey, NoKey, spaceKey, escapeKey, eKey]; % accepted keys for response
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
    DrawFormattedText(window, 'If you see the cue Yes/No, please press the left arrow key for a word\n and the right arrow key for a non-word. \nIf you see the cue Repeat, please repeat the word/nonword.\nRespond as quickly as possible. \n :=: means just listen and do not respond. \nPress any key to start. ','center', 'center', white);
    Screen('Flip',window); %Flip to the screen
    WaitSecs(0.001);
end

WaitSecs(1);
Screen('Flip', window);
% Block Loop
for iB=iBStart:nBlocks
    
pahandle = PsychPortAudio('Open', playbackdevID, 1, 2, freqS, nrchannels, 0, 0.015);
% PsychPortAudio('Volume', pahandle, 0.5); % volume
ifi_window = Screen('GetFlipInterval', window);
waitframes = ceil((2 * 0.015) / ifi_window) + 1;

% Priority(2);
 [sound fs]=audioread('/home/coganlab/Psychtoolbox_Scripts/blank.wav');
PsychPortAudio('FillBuffer', pahandle, sound');
%Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
tPredictedVisualOnset = PredictVisualOnsetForTime(window, tWhen);
PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);

    trialOrderBlockItem=trialOrderAll_Shuffle(1,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    trialOrderBlockTask=trialOrderAll_Shuffle(2,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    cueTimeBaseSeconds= 1.5 ; % 0.5 Base Duration of Cue s
    delTimeBaseSecondsA = 1; % 0.75 Base Duration of Del s
    delTimeBaseSecondsB = 2.5;
    goTimeBaseSeconds = 0.5; % 0.5 Base Duration Go Cue Duration s
    respTimeSecondsA = 1.5; % 1.5 Response Duration s
    respTimeSecondsB = 3; % for sentences
    isiTimeBaseSeconds = 0.75; % 0.5 Base Duration of ISI s; 0.75 originally
    
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
    tone500=audioread('/home/coganlab/Psychtoolbox_Scripts/tone500_3.wav');
   % tone500=.5*tone500;
  %  pahandle = PsychPortAudio('Open', playbackdevID, 1, 2, freqS, nrchannels,0, 0.015);
   % PsychPortAudio('Volume', pahandle, 1); % volume
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
    
    Priority(2);

    for iTrials=1:trialEnd
        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        Screen('TextSize', window, 100);

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
            if i<=0.5*cueTimeBaseFrames
                % Draw text
                DrawFormattedText(window, cue, 'center', 'center', [1 1 1]);
            end
            % Flip to the screen
            flipTimes(1,i) = Screen('Flip', window);
        end
        loopStart = GetSecs;
        PsychPortAudio('FillBuffer', pahandle, vol.*sound');
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
        t2wait = 2.25;
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
        trialInfo{trialCount+1}.wordtype = wordtype;
        
        save([subjectDir '/' subject '_Block_' num2str(iB) fileSuff '_TrialData.mat'],'trialInfo')
        trialCount = trialCount + 1;
        % Setup recording for each individual trial!
        % % pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels,64);
       % pahandle3 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0, 0.015);
        %
        % % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
       % PsychPortAudio('GetAudioData', pahandle3, 5);
        %
        % %PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
       % PsychPortAudio('Start', pahandle3, 0, 0, 1);
        
        
        % Reset the keyboard input checking for all keys
        RestrictKeysForKbCheck;
        ListenChar(1);
       % [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle3);
       % filename = ([subject '_Block_' num2str(iB) '_Trial_' num2str(trialCount+1) fileSuff '.wav']);
       % audiowrite([subjectDir '/' filename],audiodata,freqR);
       % PsychPortAudio('Stop', pahandle3);
       % PsychPortAudio('Close', pahandle3);
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
    while ~KbCheck
        DrawFormattedText(window, 'Take a short break \n press the space bar to continue.', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.001);
    end    

end

sca;
close all;end