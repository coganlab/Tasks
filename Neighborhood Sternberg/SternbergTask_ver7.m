function SternbergTask_ver7(subject,practice,startblock)
% Modified Sternberg task
% will be based on CVC combinations
% Created 120718 by Anna
% Updated 310718
% Commands: Subject ID: 'D#'; practice = 0, startblock = 1 (if not
% interrupted)

% %% Manipulations
% % number of blocks
[playbackdevId,capturedevId] = getDevices;

%playbackdev = 7; % 3;
%capturedev = 6; %1;
nBlocks = 5;  

% number of trials in a block
trialEnd= 32; % change to 20 after testing
iBStart=startblock;
% Create subject ID and create directory
c = clock;
baseName = fullfile('data', sprintf('%s_%02d%02d%02d%02d%02d', subject, c(1), c(2), c(3), c(4), c(5))) ;
% Change TASKNAME based on the task
subjectDir = baseName; % change where this file will be saved

trialInfo=[];
if exist(subjectDir, 'dir')
    mkdir(subjectDir)
elseif ~exist(subjectDir, 'dir')
    mkdir(subjectDir)
end

% Initialize audio CVC stim from directory
soundDirHW = '/home/coganlab/Psychtoolbox_Scripts/Neighborhood_Sternberg/CVC_Stimuli/Jan2019/RW/Stim/HW/rms_norm'; % High Words
soundDirHNW = '/home/coganlab/Psychtoolbox_Scripts/Neighborhood_Sternberg/CVC_Stimuli/Jan2019/NRW/Stim/HNW/rms_norm';% High Non-Words
soundDirLW = '/home/coganlab/Psychtoolbox_Scripts/Neighborhood_Sternberg/CVC_Stimuli/Jan2019/RW/Stim/LW/rms_norm'; % Low Words
soundDirLNW = '/home/coganlab/Psychtoolbox_Scripts/Neighborhood_Sternberg/CVC_Stimuli/Jan2019/NRW/Stim/LNW/rms_norm';% Low Non-Words

% Sound setup
nrchannels = 1 ;
freqS = 44100;
freqR = 44100; % 20000;
fileSuff = '';

% Initialize Sounddriver
InitializePsychSound(1);

% gathers audio stimuli (high words) from directory
dirValsHRW = dir(fullfile(soundDirHW, '*.wav'));
idx = 1;
for iS = 1:length(dirValsHRW)
    soundNameHRW = dirValsHRW(iS).name;
    soundValsHRW{iS}.sound = audioread([soundDirHW '/' soundNameHRW]);
    soundValsHRW{iS}.name = soundNameHRW;
    soundValsHRW{iS}.all_idx = idx;
    idx = idx + 1;
end

% gathers audio stimuli (high non-words) from directory
dirValsHNW = dir(fullfile(soundDirHNW, '*.wav'));
for iS=1:length(dirValsHNW)
    soundNameHNW = dirValsHNW(iS).name;
    soundValsHNW{iS}.sound = audioread ([soundDirHNW '/' soundNameHNW]);
    soundValsHNW{iS}.name = soundNameHNW;
    soundValsHNW{iS}.all_idx = idx;
    idx = idx + 1;
end

% gathers audio stimuli (low words) from directory
dirValsLRW = dir(fullfile(soundDirLW, '*.wav'));
for iS = 1:length(dirValsLRW)
    soundNameLRW = dirValsLRW(iS).name;
    soundValsLRW{iS}.sound = audioread([soundDirLW '/' soundNameLRW]);
    soundValsLRW{iS}.name = soundNameLRW;
    soundValsLRW{iS}.all_idx = idx;
    idx = idx + 1;
end

% gathers audio stimuli (low non-words) from directory
dirValsLNW = dir(fullfile(soundDirLNW, '*.wav'));
for iS=1:length(dirValsLNW)
    soundNameLNW = dirValsLNW(iS).name;
    soundValsLNW{iS}.sound = audioread ([soundDirLNW '/' soundNameLNW]);
    soundValsLNW{iS}.name = soundNameLNW;
    soundValsLNW{iS}.all_idx = idx;
    idx = idx + 1;
end

% All CVC stimuli
soundAll = cat(2,soundValsHRW, soundValsHNW, soundValsLRW, soundValsLNW);

% Words only CVCs
soundWords = cat(2,soundValsHRW, soundValsLRW);

% Non-words only CVC
soundNonWords = cat(2, soundValsHNW, soundValsLNW);


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

% Timing information
% Presentation time for the stimuli in seconds and frames

% Fixation cross
% Screen Y fraction for fixation cross
CrossFrac = 0.0167;
% Set the size of the arms of fixation cross
fixCrossDimPix = windowRect(4) * CrossFrac;

% Set the coordinates (these are all relative to zero; let the drawing
% routine center the cross in the center of our monitor)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set line width for fixation cross
lineWidthPix = 4;

%Experimental loop
trialCount = 1;
% Length of each trial contains 50d 3, 4, 5, or 6 load
trialSeqLength = repmat([3;5;7;9], 8,1);

% conditions to determine which type is played
allcondition = cat(1,ones(trialEnd/4,1),2*ones(trialEnd/4,1),3*ones(trialEnd/4,1),4*ones(trialEnd/4,1));

trialOrderAll_unshuffled = cat(2, trialSeqLength, allcondition);
% Practice session
if practice==1
    trialEnd = 4; %8
    nBlocks = 1;
    fileSuff = '_Practice';
end

if startblock ==1
    % combine and Shuffle trial length sequence and conditions
    save(['trialorder_data' filesep() subject '_trialOrderAll.mat'],'trialOrderAll_unshuffled');
    % Will create and save .mat file to Sternberg folder if starting from
    % beginning
elseif startblock>1
    load(['trialorder_data' filesep() subject '_trialOrderAll.mat'],'trialOrderAll_unshuffled');
    % Will load and save from existing trialOrderAll file if recording is
    % interrupted and need to start at a certain block
end

% Ready Loop
while ~KbCheck % Wait for a key press
    DrawFormattedText(window, 'You will hear a sequence of words or non-words in a list.\nThe size of the list may vary in size.\nAfter some time, a single word will be presented. \nPress left arrow key if the word was part of the sequence, \n and the right arrow key if the word was not part of the sequence.\nRespond as quickly as possible.\nPress the space bar to continue.','center', 'center', white);
    Screen('Flip',window); %Flip to the screen
    WaitSecs(0.001);
end

Screen('Flip', window);

pahandle = PsychPortAudio('Open', playbackdevId, 1, 2, freqS, nrchannels, 0, 0.015);
pahandle_record = PsychPortAudio('Open', capturedevId, 2, 2, freqR, nrchannels, 0, 0.015);
PsychPortAudio('GetAudioData', pahandle_record, 9000); % 20 minute recording buffer

% PsychPortAudio('Volume', pahandle, 0.5); % volume
ifi_window = Screen('GetFlipInterval', window);
waitframes = ceil((2 * 0.015) / ifi_window) + 1;

probetype_names = {'out_of_sequence', 'in_sequence'};
Priority(2);
% Block Loop
for iB=iBStart:nBlocks
    PsychPortAudio('Start', pahandle_record);
    trialOrderAll = Shuffle(trialOrderAll_unshuffled, 2);
    for iTrials=1:trialEnd
        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        DrawFormattedText(window, 'Listen','center', 'center', white);
        % Flip to the screen
        [~,ListenCueTime] = Screen('Flip', window); 
        WaitSecs(0.75);
        num_sound = trialOrderAll(iTrials,1); % number of sounds to play in trial
        condition = trialOrderAll(iTrials,2); % which condition should be played
        % Play CVC stimuli combo
        soundfile_idx_shuffled = Shuffle(1:10); % random shuffle sound list
        if (condition == 1) % High Words
            stim_category = 'High Words';
            trigVal(1) = condition;
            sound_structure = soundValsHRW;
            %trigVal(2) = trialToken(i);
        elseif (condition == 2) % High Non-words
            stim_category = 'High Non-Words';
            trigVal(1) = condition;
            sound_structure = soundValsHNW;
            %trigVal(2) = trialToken(i);
        elseif (condition == 3) % Low Words
            stim_category = 'Low Words';
            trigVal(1) = condition;
            sound_structure = soundValsLRW;
            %trigVal(2) = trialToken(i);
        elseif (condition == 4) % Low Non-words
            stim_category = 'Low Non-words';
            trigVal(1) = condition;
            sound_structure = soundValsLNW;
            %trigVal(2) = trialToken(i);
        end
        all_idx = [];
        all_sounds = cell(num_sound, 1);
        stimulus_audio_onsets = zeros(num_sound, 1);
        stimulus_trigger_onsets = zeros(num_sound, 1);
        for s = 1:num_sound
            loopStart = GetSecs;
            sound_idx = soundfile_idx_shuffled(s);
            sound = sound_structure{sound_idx}.sound;
            all_idx = cat(2, all_idx, sound_structure{sound_idx}.all_idx);
            all_sounds{s,1} = sound_structure{sound_idx}.name;
            PsychPortAudio('FillBuffer', pahandle, sound');
            Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
            tWhen = GetSecs + (waitframes - 0.5)*ifi_window;
            tPredictedVisualOnset = PredictVisualOnsetForTime(window, tWhen);
            PsychPortAudio('Start', pahandle, 1, tPredictedVisualOnset, 0);
            [~,stimulus_trigger_onsets(s)] = Screen('Flip', window, tWhen);
            offset = 0;
            while offset == 0
                status = PsychPortAudio('GetStatus', pahandle);
                offset = status.PositionSecs;
                WaitSecs('YieldSecs', 0.001);  
            end
            WaitSecs('UntilTime', loopStart + .25);
            Screen('Flip', window);
            WaitSecs('UntilTime', loopStart + 1);  % 1 second in between each token
            stimulus_audio_onsets(s) = status.StartTime;
        end
        
        MaintenancePeriodTime = GetSecs();
        % Maintenance period
        WaitSecs(2.25+0.25*rand(1,1));
        
        % Play Probe Stimulus CVC
        Probe = Shuffle(cat(1,ones(trialEnd/2,1),2*ones(trialEnd/2,1)));
        DrawFormattedText(window, 'Probe:', 'center', 'center', [1 1 1]);
        % Flip to the screen
        [~,ProbeCueTime] = Screen('Flip', window);
        WaitSecs(0.75);
        % Play any CVC NOT part of the sequence BUT in category
        if (Probe(iTrials) == 1) && ((condition == 1) || (condition == 3)) % Probe is a real word not part of sequence
            non_seq_idx = setdiff([1:10 21:30], all_idx);
            non_seq_idx_shuffle = Shuffle(non_seq_idx);
            probe_sound_idx = non_seq_idx_shuffle(1);
            sound = soundAll{probe_sound_idx}.sound;
            if ismember(probe_sound_idx, 1:10)
                probe_category = 'High Words';
            else
                probe_category = 'Low Words';
            end
        elseif (Probe(iTrials) == 1) && ((condition == 2) || (condition == 4)) % Probe is a non-word not part of the sequence
            non_seq_idx = setdiff([11:20 31:40], all_idx);
            non_seq_idx_shuffle = Shuffle(non_seq_idx);
            probe_sound_idx = non_seq_idx_shuffle(1);
            sound = soundAll{probe_sound_idx}.sound;
            if ismember(probe_sound_idx, 11:20)
                probe_category = 'High Non-Words';
            else
                probe_category = 'Low Non-Words';
            end
            % Play a CVC part of the sequence with an even distribution within the sequence
        elseif (Probe(iTrials) == 2)
            seq_idx_shuffle = Shuffle(all_idx);
            probe_sound_idx = seq_idx_shuffle(1);
            sound = soundAll{probe_sound_idx}.sound;
            probe_category = stim_category;
        end
        PsychPortAudio('FillBuffer', pahandle, sound');
        Screen('FillOval', window, circleColor1, centeredCircle, baseCircleDiam); % leave on!
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
        probe_audio_onset = status.StartTime;
        probe_trigger_onset = trigFlipOn;
%         WaitSecs('UntilTime', trigFlipOn + 0.25);
        Screen('Flip', window);   
        t2wait = 2.5;
        respToBeMade = true;
        while respToBeMade
            tCurrent = GetSecs();
            if((tCurrent - probe_audio_onset) > t2wait)
                resp = 'No Response';
                respcorrect = 0;
                keypress = acceptedKeys;
                respToBeMade = false;
                RT_timedout = 'No Response';
                DrawFormattedText(window, 'Timeout','center', 'center', [255 128 0]);
            end % Response time exceeded wait; should be noted as No Response (NR)    
            [keyIsUp, secs, pressedKey] = KbCheck;
            % Played a CVC NOT part of the sequence
            if (Probe(iTrials) == 1) && pressedKey(YesKey) % Incorrect key response
                resp = 'Yes';
                keypress = YesKey;
                respcorrect = 0;
                DrawFormattedText(window, 'Incorrect','center', 'center', [1 0 0]);
                respToBeMade = false;
                RT_timedout = 'Responded';
            elseif (Probe(iTrials) == 1) && pressedKey(NoKey) % Correct key response
                resp = 'No';
                respcorrect = 1;
                keypress = NoKey;
                DrawFormattedText(window, 'Correct','center', 'center', [0 1 0]);
                respToBeMade = false;
                RT_timedout = 'Responded';
                % Played a CVC part of the sequence
            elseif (Probe(iTrials) == 2) && pressedKey(YesKey) % Correct key response
                resp = 'Yes';
                respcorrect = 1;
                keypress = YesKey;
                DrawFormattedText(window, 'Correct','center', 'center', [0 1 0]);
                respToBeMade = false;
                RT_timedout = 'Responded';
            elseif (Probe(iTrials) == 2) && pressedKey(NoKey) % Incorrect key response
                resp = 'No';
                respcorrect = 0;
                keypress = NoKey;
                DrawFormattedText(window, 'Incorrect','center', 'center', [1 0 0]);
                respToBeMade = false;
                RT_timedout = 'Responded';
            end
            if(keyIsUp), break; end
        end
        Screen('Flip', window);   
        WaitSecs(1);
        Screen('Flip', window);  
        WaitSecs(.5);
        RT=secs-probe_trigger_onset; % Get reaction time
        
        % Write trial structure
        trialInfo{trialCount}.block = iB;
        trialInfo{trialCount}.ProbeType = Probe(iTrials);
        trialInfo{trialCount}.ProbeTypeName = probetype_names{Probe(iTrials)};
        trialInfo{trialCount}.StimlusCategory = stim_category;
        trialInfo{trialCount}.ReactionTime = RT;
        trialInfo{trialCount}.KeyCode = keypress;
        trialInfo{trialCount}.Resp = resp;
        trialInfo{trialCount}.RespCorrect = respcorrect;
        trialInfo{trialCount}.Omission = RT_timedout;
        trialInfo{trialCount}.stimulusAudioStart = stimulus_audio_onsets;
        trialInfo{trialCount}.stimulusAlignedTrigger = stimulus_trigger_onsets ;
        trialInfo{trialCount}.probeAudioStart = probe_audio_onset;
        trialInfo{trialCount}.probeAlignedTrigger = probe_trigger_onset;
        trialInfo{trialCount}.TriggerValue = trigVal(1);
        trialInfo{trialCount}.stimulusSounds_idx = all_idx;
        trialInfo{trialCount}.stimulusSounds_name = all_sounds;
        trialInfo{trialCount}.ProbeCategory = probe_category;
        trialInfo{trialCount}.probeSound_idx = probe_sound_idx;
        trialInfo{trialCount}.probeSound_name = soundAll{probe_sound_idx}.name;
        trialInfo{trialCount}.ListenCueTime = ListenCueTime;
        trialInfo{trialCount}.MaintenancePeriodTime = MaintenancePeriodTime;
        trialInfo{trialCount}.ProbeCueTime = ProbeCueTime;


        save([subjectDir '/' subject '_Block_' num2str(iBStart) fileSuff '_TrialData.mat'],'trialInfo')
        trialCount = trialCount + 1;
    end
    % Reset the keyboard input checking for all keys
    RestrictKeysForKbCheck;
    ListenChar(1);
    
    PsychPortAudio('Stop', pahandle_record);
    audiodata = PsychPortAudio('GetAudioData', pahandle_record);
    audiowrite(fullfile(subjectDir, sprintf('%s_Block_%d_Audio.wav', subject, iB)), audiodata', freqR);
    % % Break Screen
    while ~KbCheck
        DrawFormattedText(window, 'Take a short break and press the space bar to continue.', 'center', 'center', [1 1 1]);
        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(0.001);
    end

end
PsychPortAudio('Stop',pahandle);
PsychPortAudio('Close',pahandle);
PsychPortAudio('Close', pahandle_record);

sca;









