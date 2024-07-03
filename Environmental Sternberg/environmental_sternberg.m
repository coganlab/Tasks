 function environmental_sternberg(subject,practice)
% Modified Sternberg task
% will be based on CVC combinations
% Created 120718 by Anna
% Updated 310718
% Commands: Subject ID: 'D#'; practice = 0, startblock = 1 (if not
% interrupted)

% %% Manipulations
% % number of blocks
[playbackdevId,capturedevId] = getDevices;

%playbackdev = 6; %7 %3;
%capturedev = 8; %6 %1;
nBlocks = 7;
volume_scalar = 1.00;

iBStart = 1;
% Create subject ID and create directory
c = clock;
subjectDir = fullfile('data', [subject '_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))]);

trialInfo={};
if exist(subjectDir, 'dir')
    mkdir(subjectDir)
elseif ~exist(subjectDir, 'dir')
    mkdir(subjectDir)
end

% Initialize audio CVC stim from directory
% do this once, and save all structures in .mat files. If you are updating the stimuli, you need to make sure the indices of old stims are preserved.
idx = 1;
envwavs_fn = dir('stim/env/*.wav');
envwavs = arrayfun(@(a) audioread(fullfile(a.folder, a.name)), envwavs_fn, 'un', 0);
for i = 1:numel(envwavs_fn);envwavs_fn(i).idx = idx; idx = idx + 1;end
wordwavs_fn = dir('stim/words/*.wav');
wordwavs = arrayfun(@(a) audioread(fullfile(a.folder, a.name)), wordwavs_fn, 'un', 0);
for i = 1:numel(wordwavs_fn);wordwavs_fn(i).idx = idx; idx = idx + 1;end
nonwordwavs_fn = dir('stim/nonwords/*.wav');
nonwordwavs = arrayfun(@(a) audioread(fullfile(a.folder, a.name)), nonwordwavs_fn, 'un', 0);
for i = 1:numel(nonwordwavs_fn);nonwordwavs_fn(i).idx = idx; idx = idx + 1;end


% Sound setup
nrchannels = 1;
freqS = 44100;
freqR = 44100; %20000;
fileSuff = '';

% Initialize Sounddriver
InitializePsychSound(1);


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

% column 1 is stim type (environmental, word, nonword)
% column 2 is sequence length (3, 5, 7, 9)
% column 3 is probe in sequence, probe not in sequence (1,2)
% each block stands on its own

if practice==1
    load practice_trialOrderAll_unshuffled.mat;
%     load sbfx.mat;
    nBlocks = 1;
    fileSuff = '_Practice';
else
    load trialOrderAll_unshuffled.mat;
end

trialEnd = size(trialOrderAll_unshuffled, 1);

DrawFormattedText(window, 'You will hear a sequence of sounds in a list.\nThe size of the list may vary in size.\nAfter some time, a single sound will be presented. \nPress left arrow key if the sound was part of the sequence, \n and the right arrow key if the sound was not part of the sequence.\nRespond as quickly as possible.\nPress the space bar to continue.','center', 'center', white);
Screen('Flip',window); %Flip to the screen

KbWait;

Screen('Flip', window);

pahandle = PsychPortAudio('Open', playbackdevId, 1, 2, freqS, nrchannels);
pahandle_record = PsychPortAudio('Open', capturedevId, 2, 2, freqR, nrchannels);
PsychPortAudio('GetAudioData', pahandle_record, 9000); % 20 minute recording buffer
PsychPortAudio('Start', pahandle_record);
PsychPortAudio('Stop', pahandle_record);

beep_silent = MakeBeep(100, 1, 44100) * 0;
PsychPortAudio('FillBuffer', pahandle, beep_silent);
PsychPortAudio('Start', pahandle);
PsychPortAudio('Stop', pahandle);



% PsychPortAudio('Volume', pahandle, 0.5); % volume
ifi_window = Screen('GetFlipInterval', window);
waitframes = ceil((2 * 0.015) / ifi_window) + 1;

probetype_names = {'out_of_sequence', 'in_sequence'};

beep = MakeBeep(500, 1, 44100)*.05;

Priority(2);
% Block Loop
for iB=iBStart:nBlocks

    PsychPortAudio('Start', pahandle_record);
    
    PsychPortAudio('FillBuffer', pahandle, beep);
    PsychPortAudio('Start', pahandle);
    WaitSecs(1);
    PsychPortAudio('Stop', pahandle);
    if practice == 1
        trialOrderAll = trialOrderAll_unshuffled;
    else
        trialOrderAll = Shuffle(trialOrderAll_unshuffled, 2);
    end
    for iTrials=1:trialEnd
        if pause_script(window)
            PsychPortAudio('close');
            sca;
            return;
        end
        DrawFormattedText(window, 'Listen','center', 'center', white);
        % Flip to the screen
        [~, ListenCueOnset] = Screen('Flip', window); 
        
        
        WaitSecs(0.5);
        Screen('Flip', window);
        WaitSecs(0.5);
        
        stim_type = trialOrderAll(iTrials,1); % environmental vs words vs nonwords
        num_sound = trialOrderAll(iTrials,2); % number of sounds to play in trial
        probe_in_seq = trialOrderAll(iTrials,3); % should probe be in sequence or not

        if (stim_type == 1)
            stim_category = 'environment';
            [sequence_wavs, sequence_indices] = Shuffle(envwavs);
            sequence_wavs_fn = envwavs_fn(sequence_indices);

        elseif (stim_type == 2)
            stim_category = 'words';
            [sequence_wavs, sequence_indices] = Shuffle(wordwavs);
            sequence_wavs_fn = wordwavs_fn(sequence_indices);

        elseif (stim_type == 3)
            stim_category = 'nonwords';
            [sequence_wavs, sequence_indices] = Shuffle(nonwordwavs);
            sequence_wavs_fn = nonwordwavs_fn(sequence_indices);

        end
        
        if probe_in_seq == 1
            idx = randi(num_sound, 1);
        else
            idx = randi([num_sound+1, length(envwavs)], 1);
        end
        probe_wav = sequence_wavs{idx} * volume_scalar;
        probe_wav_fn = sequence_wavs_fn(idx).name;
        probe_wav_idx = sequence_indices(idx);
            

        stim_sound_names = cell(num_sound, 1);
        stimulus_audio_onsets = zeros(num_sound, 1);
        stimulus_trigger_onsets = zeros(num_sound, 1);
        stimulus_sounds_idx = zeros(num_sound, 1);
        
        for s = 1:num_sound
            loopStart = GetSecs;
            sound = sequence_wavs{s} * volume_scalar;
            stim_sound_names{s,1} = sequence_wavs_fn(s).name;
            stimulus_sounds_idx(s,1) = sequence_wavs_fn(s).idx;
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
        
        
        % Maintenance period
        MaintenancePeriodOnset = GetSecs();
        WaitSecs(2.5+0.25*rand(1,1));
        
        % Play Probe Stimulus CVC

        DrawFormattedText(window, 'Probe:', 'center', 'center', [1 1 1]);
        % Flip to the screen
        [~,ProbeCueOnset] = Screen('Flip', window);
        
        WaitSecs(0.5);
        Screen('Flip', window);
        WaitSecs(0.5);
        
        % play probe
        PsychPortAudio('FillBuffer', pahandle, probe_wav');
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
        
        respToBeMade = true;
        while respToBeMade
            [~, secs, pressedKey, kb_deltasecs] = KbCheck;
            if (probe_in_seq == 1) && pressedKey(YesKey) % Incorrect key response
                resp = 'Yes';
                keypress = YesKey;
                respcorrect = 1;
                DrawFormattedText(window, 'Correct','center', 'center', [0 1 0]);
                respToBeMade = false;
                
            elseif (probe_in_seq == 1) && pressedKey(NoKey) % Correct key response
                resp = 'No';
                respcorrect = 0;
                keypress = NoKey;
                DrawFormattedText(window, 'Incorrect','center', 'center', [1 0 0]);
                respToBeMade = false;
                
            elseif (probe_in_seq == 0) && pressedKey(YesKey) % Correct key response
                resp = 'Yes';
                respcorrect = 0;
                keypress = YesKey;
                DrawFormattedText(window, 'Incorrect','center', 'center', [1 0 0]);
                respToBeMade = false;
                
            elseif (probe_in_seq == 0) && pressedKey(NoKey) % Incorrect key response
                resp = 'No';
                respcorrect = 1;
                keypress = NoKey;
                DrawFormattedText(window, 'Correct','center', 'center', [0 1 0]);
                respToBeMade = false;
            end
            if (secs - probe_trigger_onset) > 2.5
                resp = 'None';
                respcorrect = 0;
                keypress = NaN;
                DrawFormattedText(window, 'Timeout','center', 'center', [1 1 0]);
                respToBeMade = false;
            end
        end

        Screen('Flip', window);   
        WaitSecs(1);
        Screen('Flip', window);  
        WaitSecs(.5);
        RT=secs-probe_audio_onset; % Get reaction time
        
        % Write trial structure
        trialInfo{trialCount}.block = iB;
        trialInfo{trialCount}.StimulusCategory = stim_category;
        trialInfo{trialCount}.ReactionTime = RT;
        trialInfo{trialCount}.kb_deltasecs = kb_deltasecs;
        trialInfo{trialCount}.KeyCode = keypress;
        trialInfo{trialCount}.Resp = resp;
        trialInfo{trialCount}.RespCorrect = respcorrect;
        trialInfo{trialCount}.stimulusAudioStart = stimulus_audio_onsets;
        trialInfo{trialCount}.stimulusAlignedTrigger = stimulus_trigger_onsets ;
        trialInfo{trialCount}.probeAudioStart = probe_audio_onset;
        trialInfo{trialCount}.probeAlignedTrigger = probe_trigger_onset;
        trialInfo{trialCount}.stimulusSounds_idx = stimulus_sounds_idx;
        trialInfo{trialCount}.stimulusSounds_name = stim_sound_names;
        trialInfo{trialCount}.ProbeCategory = probe_in_seq;
        trialInfo{trialCount}.probeSound_idx = probe_wav_idx;
        trialInfo{trialCount}.probeSound_name = probe_wav_fn;
        trialInfo{trialCount}.trialOrder_All = trialOrderAll(iTrials,:);
        trialInfo{trialCount}.ListenCueOnset = ListenCueOnset;
        trialInfo{trialCount}.MaintenancePeriodOnset = MaintenancePeriodOnset;
        trialInfo{trialCount}.ProbeCueOnset = ProbeCueOnset;

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
    
    DrawFormattedText(window, 'Take a short break and press the space bar to continue.', 'center', 'center', [1 1 1]);
    
    % Flip to the screen
    Screen('Flip', window);
    KbWait;

end
PsychPortAudio('Stop',pahandle);
PsychPortAudio('Close',pahandle);
PsychPortAudio('Close', pahandle_record);

sca;
end










