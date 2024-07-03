%% Phoneme sequencing task

function phoneme_sequencing_revised2018(subject, practice)
% 1 = 6 practice trials run
% 0 = full trial (4 blocks; 52 trials per block)

% This is a function that initiates the phoneme sequencing task, presenting
% the subject with a non-word CVC or VCV pair. Variables include subject
% name (i.e. 'Shervin') and practice indicates whether or not this is a
% practice trial or the real thing (1 = 12 trial practice run, 0 is the
% full trial ***)

% Start with a clean slate!
sca;
close all;
[playbackdevID,capturedevID] = getDevices;

%playbackdevID = 7; %3; 
%capturedevID = 6; %1; % 1

%% Establish baseline task parameters and directory to write data file, ensure file names dont overlap by using time in file name

subjectDir = ['/home/coganlab/Psychtoolbox_Scripts/phoneme_sequencing/data/' subject];
soundDirCVC = '/home/coganlab/Psychtoolbox_Scripts/phoneme_sequencing/humanstimclean/phonemeCVC/';
soundDirVCV = '/home/coganlab/Psychtoolbox_Scripts/phoneme_sequencing/humanstimclean/phonemeVCV/';

nBlocks = 4;
trialCount = 0;
blockCount = 0;
trialEnd = 52;

nrchannels = 1;  
freqS = 44100;
freqR = 44100; %20000;
fileSuff = '';
baseCircleDiam = 75;

repetitions = 1;
StartCue = 0;
WaitForDeviceStart = 1;

trialInfo = [];
if exist(subjectDir,'dir')
    dateTime = strcat('_',datestr(now,30));
    subjectDir = strcat(subjectDir,dateTime);
    mkdir(subjectDir)
elseif ~exist(subjectDir,'dir')
    mkdir(subjectDir)
end

if practice == 1
    trialEnd = 6;
    nBlocks = 1;
    fileSuff = '_Pract';
end

%% Sound setup, load .wav files for CVCs and VCVs

% Initialize Sounddriver
InitializePsychSound(1);

soundValsCVC = [];
dirValsCVC = dir(soundDirCVC);
for iS = 3:length(dirValsCVC)
    soundNameCVC = dirValsCVC(iS).name;
    soundValsCVC{iS-2}.sound = audioread([soundDirCVC soundNameCVC]);
    soundValsCVC{iS-2}.name = soundNameCVC;
end

soundValsVCV = [];
dirValsVCV = dir(soundDirVCV);
for iS = 3:length(dirValsVCV)
    soundNameVCV = dirValsVCV(iS).name;
    soundValsVCV{iS-2}.sound = audioread([soundDirVCV soundNameVCV]);
    soundValsVCV{iS-2}.name = soundNameVCV;
end

%% Set defaults for PTB task

% Screen Setup
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native screen
screenNumber = max(screens);

% Define black and white
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);

% Open an on screen window and color it black
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Set the blend funnction for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Set the text size
Screen('TextSize', window, 50);

% Circle stuff for photodiode
baseCircle = [0 0 baseCircleDiam baseCircleDiam];
centeredCircle = CenterRectOnPointd(baseCircle, screenXpixels-0.5*baseCircleDiam, 1+0.5*baseCircleDiam); %

circleColor1 = [1 1 1]; % white
circleColor2 = [0 0 0]; % black

%% Ready Loop

while ~KbCheck
    DrawFormattedText(window, 'Please repeat each speech sound after the speak cue. Press any key to start. ', 'center', 'center', [1 1 1],58);
    Screen('Flip', window);
    WaitSecs(0.001);
end

%% Block Loop

for iB = 1:nBlocks %nBlocks;
    % trialorder
    trialOrderCVCOrig = 1:26;
    trialOrderVCVOrig = 1:26;
    trialOrderCVCBlock = Shuffle(trialOrderCVCOrig);
    trialOrderVCVBlock = Shuffle(trialOrderVCVOrig);
    %   trialOrderCVCBlock = trialOrderCVC((iB-1)*26+1:(iB-1)*26+26);
    %   trialOrderVCVBlock = trialOrderVCV((iB-1)*26+1:(iB-1)*26+26);
    coinToss = Shuffle(repmat([1,0],1,26));
    nTrials = 52;
    
    cueTimeBaseSeconds = 0.5; % 0.5 Base Duration of Cue s
    delTimeBaseSecondsA = 1; % 0.75 Base Duration of Del s
    %delTimeBaseSecondsB = 2.5;
    goTimeBaseSeconds = 0.5; % 0.5 Base Duration Go Cue Duration s
    respTimeSecondsA = 1.5; % 1.5 Response Duration s
    %respTimeSecondsB = 3; % for sentences
    isiTimeBaseSeconds = 0.75; % 0.5 Base Duration of ISI s
    
    cueTimeJitterSeconds = 0.25; % 0.25; % Cue Jitter s
    delTimeJitterSeconds = 0.25;% 0.5; % Del Jitter s
    goTimeJitterSeconds = 0.25;% 0.25; % Go Jitter s
    isiTimeJitterSeconds = 0.25; % 0.5; % ISI Jitter s
    
    soundBlockPlay = [];
    counterCVC = 0;
    counterVCV = 0;
    
    for i = 1:trialEnd
        if coinToss(i) == 1
            trigVal = trialOrderCVCBlock(counterCVC+1);
            soundBlockPlay{i}.sound = soundValsCVC{trialOrderCVCBlock(counterCVC+1)}.sound;
            soundBlockPlay{i}.name = soundValsCVC{trialOrderCVCBlock(counterCVC+1)}.name;
            soundBlockPlay{i}.Trigger = trigVal;
            counterCVC = counterCVC+1;
            
        elseif coinToss(i) == 0
            trigVal = 100+trialOrderVCVBlock(counterVCV+1);
            soundBlockPlay{i}.sound = soundValsVCV{trialOrderVCVBlock(counterVCV+1)}.sound;
            soundBlockPlay{i}.name = soundValsVCV{trialOrderVCVBlock(counterVCV+1)}.name;
            soundBlockPlay{i}.Trigger = trigVal;
            counterVCV = counterVCV+1;
        end
    end
    
    % Setup recording!
    pahandle2 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0,0.015);
    
    % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
    PsychPortAudio('GetAudioData', pahandle2, 9000); %nTrials
    
    %PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Start', pahandle2, 0, 0, 1);
    
    % play tone!
    tone500 = audioread('/home/coganlab/Psychtoolbox_Scripts/tone500_3.wav');
    pahandle = PsychPortAudio('Open', playbackdevID, 1, 2, freqS, nrchannels,0, 0.015);
    PsychPortAudio('FillBuffer', pahandle, 0.005*tone500');
    PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Volume', pahandle, 0.5);
    toneTimeSecs = ((freqS)+length(tone500))./(freqS);
    toneTimeFrames = ceil(toneTimeSecs / ifi);
    for i = 1:toneTimeFrames
        DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
    end
    
    ifi_window = Screen('GetFlipInterval', window);
    suggestedLatencySecs = 0.015;
    waitframes = ceil((2 * suggestedLatencySecs) / ifi_window) + 1;
    prelat = PsychPortAudio('LatencyBias', pahandle, 0) %#ok<NOPRT,NASGU>
    postlat = PsychPortAudio('LatencyBias', pahandle);
    Priority(2);
    
    for iTrials = 1:trialEnd
        if pause_script(window)
            sca;
            PsychPortAudio('close');
            return;
        end
        cue='Listen'; %trialStruct.cue{trialShuffle(1,iTrials)};
        sound=soundBlockPlay{iTrials}.sound;%eval(trialStruct.sound{trialShuffle(2,iTrials)});
        sound=sound(:,1);
        go='Speak'; %trialStruct.go{trialShuffle(3,iTrials)};
        delTimeBaseSeconds=delTimeBaseSecondsA;
        respTimeSeconds=respTimeSecondsA;
        soundTimeSecs = length(sound)./freqS; %max(cat(1,length(kig),length(pob)))./freqS;
        soundTimeFrames = ceil(soundTimeSecs / ifi);
        cueTimeBaseFrames = round((cueTimeBaseSeconds+(cueTimeJitterSeconds*rand(1,1))) / ifi);
        
        delTimeSeconds = delTimeBaseSeconds + delTimeJitterSeconds*rand(1,1);
        delTimeFrames = round(delTimeSeconds / ifi );
        goTimeSeconds = goTimeBaseSeconds +goTimeJitterSeconds*rand(1,1);
        goTimeFrames = round(goTimeSeconds / ifi);
        respTimeFrames = round(respTimeSeconds / ifi);
        
        % write trial structure
        flipTimes = zeros(1,cueTimeBaseFrames);
        trialInfo{trialCount+1}.cue = cue;
        trialInfo{trialCount+1}.sound = soundBlockPlay{iTrials}.name;
        trialInfo{trialCount+1}.go = go;
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
            % Draw text
            DrawFormattedText(window, cue, 'center', 'center', [1 1 1]);
            % Flip to the screen
            flipTimes(1,i) = Screen('Flip', window);
        end
        trialInfo{trialCount+1}.cueEnd=GetSecs;
        
        %Play Sound
        Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam);
        PsychPortAudio('FillBuffer', pahandle, sound');
        
        tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
        tPredictedVisualOnset = PredictVisualOnsetForTime(window, tWhen);
        PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);
        
        [~,trigFlipOn] = Screen('Flip', window, tWhen);
        offset = 0;
        while offset == 0
            status = PsychPortAudio('GetStatus', pahandle);
            offset = status.PositionSecs;
            WaitSecs('YieldSecs', 0.001);
        end
        
        trialInfo{trialCount+1}.audioStart = status.StartTime;
        trialInfo{trialCount+1}.audioAlignedTrigger = trigFlipOn;
        % Draw blank for duration of sound
        for i = 1:soundTimeFrames
            DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
            % Flip to the screen
            Screen('Flip', window);
        end
        
        % Delay
        trialInfo{trialCount+1}.delStart = GetSecs;
        for i=1:delTimeFrames
            Screen('Flip', window);
        end
        
        trialInfo{trialCount+1}.delEnd = GetSecs;
        
%         % Close Sound
%         
%         % Setup recording!
%         pahandle3 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0, 0.015);
%         
%         % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
%         PsychPortAudio('GetAudioData', pahandle3, 5); % used to be 5
%         
%         % PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
%         PsychPortAudio('Start', pahandle3, 0, 0, 1);
        
        trialInfo{trialCount+1}.goStart = GetSecs;
        for i = 1:goTimeFrames
            DrawFormattedText(window, go, 'center', 'center', [1 1 1]);
            Screen('Flip', window);
        end
        
        trialInfo{trialCount+1}.goEnd = GetSecs;
        
        trialInfo{trialCount+1}.respStart = GetSecs;
        for i = 1:respTimeFrames
            
            % Flip to the screen
            Screen('Flip', window);end
        
        trialInfo{trialCount+1}.respEnd = GetSecs;
%         [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle3);
%         filename = ([subject '_Block_' num2str(iB) '_Trial_' num2str(trialCount+1) fileSuff '.wav']);
%         audiowrite([subjectDir '\' filename],audiodata,freqR);
%         PsychPortAudio('Stop', pahandle3);
%         PsychPortAudio('Close', pahandle3);
        
        % ISI
        isiTimeSeconds = isiTimeBaseSeconds + isiTimeJitterSeconds*rand(1,1);
        isiTimeFrames=round(isiTimeSeconds / ifi );
        
        trialInfo{trialCount+1}.isiStart=GetSecs;
        for i=1:isiTimeFrames
            DrawFormattedText(window,'' , 'center', 'center', [1 1 1]);
            % Flip to the screen
            Screen('Flip', window);
        end
        
        trialInfo{trialCount+1}.isiEnd=GetSecs;
        trialInfo{trialCount+1}.flipTimes = flipTimes;
   %     trialInfo{trialCount+1}.tCaptureStart = tCaptureStart;
        save([subjectDir '/' subject '_Block_' num2str(blockCount+1) fileSuff '_TrialData.mat'],'trialInfo')
        
        trialCount=trialCount+1;
    end
    Priority(0);
    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2);
    filename = ([subject '_Block_' num2str(blockCount+1) fileSuff '_AllTrials.wav']);
    audiowrite([subjectDir '/' filename],audiodata,freqR);
    PsychPortAudio('Stop', pahandle2);
    PsychPortAudio('Close', pahandle2);
    
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    % Stop playback
    % PsychPortAudio('Stop', pahandle);
    
    % Close the audio device
    
    % PsychPortAudio('Close', pahandle);
    blockCount=blockCount+1;
    
    % Break Screen
    while ~KbCheck
        DrawFormattedText(window, 'Take a short break and press any key to continue', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.001);
    end
    
end

sca
close all