 function Lexical_Repeat_WithinBlock_2x(subject,practice,startblock)
% Lexical_Repeat_WithinBlock(subject,practice,startblock)
% subject = subject number
% practice =  practice or full task. 1 = 12 trial practice run, 2 = 2 x 42 trials
% startblock = block to start from.  1 if new, >1 if needing to finish from
%  
% previously run task

sca;
[playbackdevID,capturedevID] = getDevices;

%playbackdevID = 7; %3; % 4 for usb amp, 3 without
%capturedevID = 6; %1; % 2 for usb amp, 1 without
%subject = 'Test2';
c = clock;
subjectDir = fullfile('data', [subject '_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))]);
load('/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/TokenCategory.mat');

% Initialize stim from directory
soundDirW = '/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/words/';
soundDirNW= '/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/nonwords/';
nBlocks = 4; % 10
trialCount=0;
blockCount=0;
trialEnd=84; %54
nrchannels = 1;
iBStart=startblock;
freqS = 44100;
freqR = 44100; %20000;
fileSuff = '';
baseCircleDiam=75; % diameter of

repetitions = 1;
StartCue = 0;
WaitForDeviceStart = 1;

trialInfo=[];
if exist(subjectDir,'dir')
    dateTime=strcat('_',datestr(now,30));
    subjectDir=strcat(subjectDir,dateTime);
    mkdir(subjectDir)
elseif ~exist(subjectDir,'dir')
    mkdir(subjectDir)
end


if practice==1
    trialEnd = 12; %12
    nBlocks = 1;
    fileSuff = '_Pract';
end
%---------------
% Sound Setup
%---------------

% Initialize Sounddriver
InitializePsychSound(1);


% load sound files
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
soundValsWords = cat(2, soundValsW, soundValsW);

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
soundValsNonWords = cat(2, soundValsNW, soundValsNW);

% trialorder
trialOrderWordsOrig=1:trialEnd; % 84
trialOrderNonWordsOrig=1:trialEnd; % 84

trialOrderComboOrig=cat(2,trialOrderWordsOrig,trialOrderNonWordsOrig);

trialOrderTaskLex=cat(2,ones(1,trialEnd),2*ones(1,trialEnd));
trialOrderTaskRep=cat(2,3*ones(1,trialEnd),4*ones(1,trialEnd));

trialOrderAllOrig=cat(2,trialOrderComboOrig,trialOrderComboOrig);
trialOrderTaskOrig=cat(2,trialOrderTaskLex,trialOrderTaskRep);

trialOrderAll=cat(1,trialOrderAllOrig,trialOrderTaskOrig);

shuffleIdx=Shuffle(1:length(trialOrderAll));
if startblock==1
    trialOrderAll_Shuffle=trialOrderAll(:,shuffleIdx);
    save(fullfile('trialorder_data', [subject '_trialOrderAll_Shuffle.mat']), 'trialOrderAll_Shuffle');
elseif startblock>1
    load(fullfile('trialorder_data', [subject '_trialOrderAll_Shuffle.mat']));
end



% Screen Setup
PsychDefaultSetup(2);
% Get the screen numbers
screens = Screen('Screens');
% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);
% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;
% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber,black,[0 0 500 500]);

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
%centeredCircle = CenterRectOnPointd(baseCircle, screenXpixels-0.5*baseCircleDiam, screenYpixels-0.5*baseCircleDiam); %
centeredCircle = CenterRectOnPointd(baseCircle, screenXpixels-0.5*baseCircleDiam, 1+0.5*baseCircleDiam); %

circleColor1 = [1 1 1]; % white
circleColor2 = [0 0 0]; % black
% Query the frame duration


% Ready Loop

while ~KbCheck
    % Flip to the screen
    DrawFormattedText(window, 'If you see the cue Yes/No, please say Yes for a word and No for a nonword. \nIf you see the cue Repeat, please repeat the word/nonword. \nPress any key to start. ', 'center', 'center', [1 1 1],58);
    
    Screen('Flip', window);
    WaitSecs(0.001);
end
% Set the text size



% Block Loop
for iB=iBStart:nBlocks %nBlocks;
    trialOrderBlockItem=trialOrderAll_Shuffle(1,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    trialOrderBlockTask=trialOrderAll_Shuffle(2,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    Screen('TextSize', window, 100);
    
    nTrials=84; %168/4; %rotNumb*3;
    
    cueTimeBaseSeconds= 2.0  ; % 1.5 up to 5/26/2019 % 0.5 Base Duration of Cue s
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
    
    soundBlockPlay=[];
    counterW=0;
    counterNW=0;
    for i=1:trialEnd %trialEnd; %42
        
        if trialOrderBlockTask(i)==1
            trigVal=trialOrderBlockItem(i);
            soundBlockPlay{i}.sound=soundValsWords{trialOrderBlockItem(i)}.sound;
            soundBlockPlay{i}.name=soundValsWords{trialOrderBlockItem(i)}.name;
            soundBlockPlay{i}.Trigger=trigVal;
            counterW=counterW+1;
            
        elseif trialOrderBlockTask(i)==2
            trigVal=100+trialOrderBlockItem(i);
            soundBlockPlay{i}.sound=soundValsNonWords{trialOrderBlockItem(i)}.sound;
            soundBlockPlay{i}.name=soundValsNonWords{trialOrderBlockItem(i)}.name;
            soundBlockPlay{i}.Trigger=trigVal;
            
        elseif trialOrderBlockTask(i)==3
            trigVal=200+trialOrderBlockItem(i);
            soundBlockPlay{i}.sound=soundValsWords{trialOrderBlockItem(i)}.sound;
            soundBlockPlay{i}.name=soundValsWords{trialOrderBlockItem(i)}.name;
            soundBlockPlay{i}.Trigger=trigVal;
            counterW=counterW+1;
            
        elseif trialOrderBlockTask(i)==4
            trigVal=300+trialOrderBlockItem(i);
            soundBlockPlay{i}.sound=soundValsNonWords{trialOrderBlockItem(i)}.sound;
            soundBlockPlay{i}.name=soundValsNonWords{trialOrderBlockItem(i)}.name;
            soundBlockPlay{i}.Trigger=trigVal;
            % counterNW=counterNW+1;
        end
       
    end
    
    
    %binCodeVals=repmat(binCodeVals,3,1);
    
    % Setup recording!
    %pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels,64);
    pahandle2 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0, 0.015);
    
    % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
    PsychPortAudio('GetAudioData', pahandle2, 9000); %nTrials
    
    %PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Start', pahandle2, 0, 0, 1);
    
    % play tone!
    tone500=audioread('/home/coganlab/Psychtoolbox_Scripts/Lexical_Repeat/stim/tone500_3.wav');
    % tone500=.5*tone500;
    pahandle = PsychPortAudio('Open', playbackdevID, 1, 2, freqS, nrchannels,0, 0.015);
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
    %
    %while ~kbCheck
    ifi_window = Screen('GetFlipInterval', window);
    suggestedLatencySecs = 0.015;
    waitframes = ceil((2 * suggestedLatencySecs) / ifi_window) + 1;
    prelat = PsychPortAudio('LatencyBias', pahandle, 0) %#ok<NOPRT,NASGU>
    postlat = PsychPortAudio('LatencyBias', pahandle);
    Priority(2);
    for iTrials=1:trialEnd %trialEnd ;%nTrials %nTrials;
        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        
        if soundBlockPlay{iTrials}.Trigger<200 % used to be 300 wrong
            cue='Yes/No';
        elseif soundBlockPlay{iTrials}.Trigger>=200 %used to be 300 wrong
            cue='Repeat';
        end
        
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
        trialInfo{trialCount+1}.sound = soundBlockPlay{iTrials}.name;%trialStruct.sound{trialShuffle(2,iTrials)};
        trialInfo{trialCount+1}.go = go;
        trialInfo{trialCount+1}.cueTime=GetSecs;
        trialInfo{trialCount+1}.block = iB;
        %trialInfo{trialCount+1}.cond = trialShuffle(4,iTrials);
        trialInfo{trialCount+1}.cueStart = GetSecs;
        trialInfo{trialCount+1}.Trigger=soundBlockPlay{iTrials}.Trigger;
        
        %   binCode=binCodeVals(iTrials,:);
        
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
        fprintf('Expected audio-visual delay    is %6.6f msecs.\n', (status.StartTime - trigFlipOn)*1000.0)
        % Draw blank for duration of sound
        for i=1:soundTimeFrames
            
            DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
            % Flip to the screen
            Screen('Flip', window);
        end
        
        
        
        % % Delay
        
        trialInfo{trialCount+1}.delStart=GetSecs;
        for i=1:delTimeFrames
            Screen('Flip', window);
        end
        
        trialInfo{trialCount+1}.delEnd=GetSecs;
        % % Close Sound
        
        trialInfo{trialCount+1}.goStart=GetSecs;
        for i=1:goTimeFrames
            DrawFormattedText(window, go, 'center', 'center', [1 1 1]);
            Screen('Flip', window);
        end
        
        trialInfo{trialCount+1}.goEnd=GetSecs;
        
        trialInfo{trialCount+1}.respStart=GetSecs;
        for i=1:respTimeFrames
            %  DrawFormattedText(window,'','center','center',[1 1 1]);
            % Flip to the screen
            Screen('Flip', window);end
        
        trialInfo{trialCount+1}.respEnd=GetSecs;
        
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
        save([subjectDir '/' subject '_Block_' num2str(iBStart) fileSuff '_TrialData.mat'],'trialInfo')
        
        trialCount=trialCount+1;
        
        %       end
        %tmp1=0;
    end
    Priority(0);
    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2);
    filename = ([subject '_Block_' num2str(iB) fileSuff '_AllTrials.wav']);
    audiowrite([subjectDir '/' filename],audiodata,freqR);
    PsychPortAudio('Stop', pahandle2);
    PsychPortAudio('Close', pahandle2);
    
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    
    blockCount=blockCount+1;
    Screen('TextSize', window, 50);
    % % Break Screen
    while ~KbCheck      
        % Set the text size
 
        DrawFormattedText(window, 'Take a short break and press any key to continue', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.001);
    end
    
end
sca
close all
%clear all