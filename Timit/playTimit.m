 function playTimit(subject,practice,startBlock)
% subject: 'd4'
% practice: 1 - yes, 0 - no
% startBlock: 1 - start from block 1 and continue till end
sca;
%load('trialTimitRat.mat');
load('trialTimitv6.mat'); 
rootdir = '/home/coganlab/Psychtoolbox_Scripts/timit/';
timitPath = fullfile(rootdir,'timit/TIMIT/')
subjectDir = fullfile(rootdir, 'data/', subject);
nBlocks = 4; % change number of Blocks based on the surgery duration; minimum 1 maximum 4
vol=10;
playBackDevID = 7; %3;%3
capturedevID = 6; %1
[playBackDevID,capturedevID] = getDevices;
%subjectDir = fullfile(rootdir, subject);
WaitForDeviceStart = 1;

iBStart = startBlock;
trialCount=0;
blockCount=0;
trialEnd=81; %81 for humans 200 for rat
trialEndAll = 324; %324 for humans 800 for rats
freqS = 44100;
freqR = 44100; %20000;
nrchannels = 1;
baseCircleDiam=75;
StartCue = 0 ;
repetitions = 1;
fileSuff = '';
trialInfo=[];
if startBlock == 1
    if exist(subjectDir,'dir')
        dateTime=strcat('_',datestr(now,30));
        subjectDir=strcat(subjectDir,dateTime);
        mkdir(subjectDir)
    elseif ~exist(subjectDir,'dir')
        mkdir(subjectDir)
    end
end
if practice==1
    trialEnd = 12; %12
    nBlocks = 1;
    fileSuff = '_Pract';
end


% Initialize Sounddriver
InitializePsychSound(1);

for iS=1:length(audiopath)
    [soundTemp,fsTimit] = audioread([timitPath audiopath{iS}]);
    soundVals{iS}.sound = resample(soundTemp,freqS,fsTimit);
    soundVals{iS}.name = sentence(iS);
end

trialOrderAll = 1:trialEndAll;
%shuffleIdx = Shuffle(trialOrderAll);
if startBlock==1
    trialOrderAll_Shuffle = trialOrderAll;
    save([subjectDir subject '_trialOrderAll_Shuffle.mat'],'trialOrderAll_Shuffle');
elseif startBlock>1
    load([subjectDir subject '_trialOrderAll_Shuffle.mat']);
end

% Screen Setup
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow',screenNumber,black);

% Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize',window);
ifi = Screen('GetFlipInterval', window);
% Get the center coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
% Set the text size
Screen('TextSize', window, 25);

% Circle stuff for photodiode
baseCircle = [0 0 baseCircleDiam baseCircleDiam];
centeredCircle = CenterRectOnPointd(baseCircle, screenXpixels-0.5*baseCircleDiam, 1+0.5*baseCircleDiam);

circleColor1 = [1 1 1];
circleColor2 = [0 0 0];

% Ready Loop
KeyIsDown=0;
while(KbCheck~=1)
    DrawFormattedText(window, 'Listen to the sentences. Occasionally, you will see an Yes/No question about the previous sentence. \n Press Left arrow key for Yes and Right arrow key for No', 'center', 'center', [1 1 1],58);
    Screen('Flip',window);
end
DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
Screen('Flip',window);

pahandle = PsychPortAudio('Open',playBackDevID,1, 2, freqS, nrchannels);
%         pahandle = PsychPortAudio('Open',playBackDevID,1, 2, freqS, nrchannels,0,0.015);
pahandle2 = PsychPortAudio('Open', capturedevID, 2, 0, freqR, nrchannels,0, 0.015);


% Block Loop
for iB = iBStart:nBlocks
    trialOrderBlockItem = trialOrderAll_Shuffle(1,(iB-1)*trialEnd+1:(iB-1)*trialEnd+trialEnd);
    nTrials = trialEnd;
    soundBlockPlay = [];
    counter = 0;
    
    for i=1:trialEnd
        trigVal = trialOrderBlockItem(i);
        soundBlockPlay{i}.sound = soundVals{trialOrderBlockItem(i)}.sound;
        soundBlockPlay{i}.name = soundVals{trialOrderBlockItem(i)}.name;
        soundBlockPlay{i}.Trigger = trigVal;
        counter = counter +1;
    end
    
    % Setup recording!
    %pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels,64);
    
    % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
    PsychPortAudio('GetAudioData', pahandle2, 9000); %nTrials
    
    %PsychPortAudio('Start', pahandle, repetitions, StartCue, WaitForDeviceStart);
    PsychPortAudio('Start', pahandle2, 0, 0, 1);
    
    % play tone!
    %          [tone500,fstone] = audioread('C:\Psychtoolbox_Scripts\timit\tone_envelope_500hz_500ms.wav');
    %          tone500 = resample(tone500,freqS,fstone);
    tone500 = MakeBeep(500, .5, freqS);
    tone500_zero = tone500 * 0;
    
    PsychPortAudio('FillBuffer',pahandle,tone500_zero);
    PsychPortAudio('Start', pahandle);
    WaitSecs(.5);
    
    PsychPortAudio('FillBuffer',pahandle,0.125.*tone500);
    PsychPortAudio('Start',pahandle, repetitions, StartCue, WaitForDeviceStart);
    %         PsychPortAudio('Volume',pahandle, 0.5);
    toneTimeSecs = (freqS+length(tone500))./freqS;
    toneTimeFrames = ceil(toneTimeSecs / ifi);
    %pahandle2 = PsychPortAudio('Open',playBackDevID,1, 2, freqS, nrchannels,0,0.015);
    for i=1:toneTimeFrames
        DrawFormattedText(window, '', 'center', 'center', [1 1 1]);
        Screen('Flip',window);
    end
    ifi_window = Screen('GetFlipInterval',window);
    suggestedLatencySecs = 0.015;
    waitframes = ceil((2 * suggestedLatencySecs)/ifi_window)+1;
    %         prelat = PsychPortAudio('LatencyBias',pahandle, 0);
    %         postlat = PsychPortAudio('LatencyBias',pahandle);
    Priority(2);
    for iTrials = 1:trialEnd
        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        sound = soundBlockPlay{iTrials}.sound;
        soundTimeSecs = length(sound)./freqS;
        soundTimeFrames = ceil(soundTimeSecs / ifi);
        
        % write trial structure
        trialInfo{trialCount+1}.sound = soundBlockPlay{iTrials}.name;
        trialInfo{trialCount+1}.block = iB;
        trialInfo{trialCount+1}.audioFile = audiopath{iTrials};
        
        % Play Sound
        Screen('FillOval',window,circleColor1,centeredCircle,baseCircleDiam);
        PsychPortAudio('FillBuffer',pahandle,vol.*sound');%
        tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
        tPredictedVisualOnset = PredictVisualOnsetForTime(window,tWhen);
        PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);
        
        [~,trigFlipOn] = Screen('Flip', window, tWhen);
        offset = 0;
        while offset == 0
            status = PsychPortAudio('GetStatus',pahandle);
            offset = status.PositionSecs;
            WaitSecs('YieldSecs', 0.001);
        end
        trialInfo{trialCount+1}.audioStart = status.StartTime;
        trialInfo{trialCount+1}.audioAlignedTrigger = trigFlipOn;
%         fprintf('Expected audio-visual delay is %6.6f msecs.\n', (status.StartTime - trigFlipOn)*1000.0)
        for i = 1:soundTimeFrames
            DrawFormattedText(window,'', 'center', 'center', [1 1 1]);
            Screen('Flip',window);
        end
        save([subjectDir '/' subject '_Block_' num2str(iB) fileSuff '_TrialData.mat'],'trialInfo')
        WaitSecs(1);
        trialCount = trialCount+1;
    end
    PsychPortAudio('Stop',pahandle2);
    PsychPortAudio('Stop',pahandle);
    Priority(0);
    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2);
    filename = ([subject '_Block_' num2str(iB) fileSuff '_AllTrials.wav']);
    audiowrite([subjectDir '/' filename],audiodata,freqR);

    
    blockCount = blockCount + 1;
    DrawFormattedText(window, 'Take a short break and press any key to continue','center','center',[1 1 1]);
    Screen('Flip',window);
    
    KbWait();
end

PsychPortAudio('Close',pahandle2);
PsychPortAudio('Close',pahandle);

sca;
