function memieeg(subject,list, block, txtsize)
arguments
    
    subject(1,:)char = 'test'
    list(1,:)char = 'S01'
    block(1,1){mustBeInteger} = 0
    txtsize(1,1){mustBeNumeric} = 40
    
end

% A function that runs an associative memory task in pyschtoolbox.
% The task is to name the associate an object with the face of a celebrity, and then remember the association
% The task is divided into blocks.
% Each block is divided into trials.
% The inputs are:
% subject: Needs to be a string like this 'D#'
% list: the order of the stimuli that the subject will see. Needs to be:
% 'S01', 'S02', etc.
% block: Need to be an integer between 0 and 6, 0 represents the practice block
% txtsize: is the text of the stimuli (base size 40)

%%
%Specify directories
% here is a change
subject = [upper(subject(1)) subject(2:end)];
list = [upper(list(1)) list(2:end)];

cf = pwd;
save_data = fullfile(cf,'data','behav_data');
block_data = fullfile(cf,'data','sub_lists');
face_folder = fullfile(cf,'stimuli','faces');
object_folder = fullfile(cf,'stimuli','objects');
instruction_folder = fullfile(cf,'instructions');

%% Specify time intervals in seconds241324321432
encoding_time = 3;
elaborate_time = 3;
rest_time = 10;
fc_time = 4;
retrieval_time = 3;

% fixation cross limits
low_lim = 0.55;
upp_lim = 0.75;
%% Specify Image Dimensions

% Image Size
[s1, s2, s3, s4] = deal(300);

% Scale the images if needed to fit within the screen
scaleFactor = 1; % no scaling
s1 = s1 * scaleFactor;
s2 = s2 * scaleFactor;
s3 = s3 * scaleFactor;
s4 = s4 * scaleFactor;

% Gap between the images
gap = 200;

% Define rectangles for the images
rect1 = [0 0 s2 s1];
rect2 = [0 0 s4 s3];

%% Request Subject information

% Start Experiment
% Set up the experiment
c = clock; %Current date and time as date vector. [year month day hour minute seconds]
time = strcat(num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))); %makes unique filename

% Make Folder to store subjects data
sub_folder = fullfile(save_data,[subject '_' time]);
if ~exist(sub_folder)
    mkdir(sub_folder)
end

%% Structure to save the data
% Add fields to the csv to store the data

data_csv(1).object =  [];
data_csv(1).target =  [];
data_csv(1).lure1 =  [];
data_csv(1).lure2 =  [];
data_csv(1).baseline =  [];
data_csv(1).stim_onset =  [];
data_csv(1).stim_end =  [];
data_csv(1).response =  [];
data_csv(1).correct_response =  [];
data_csv(1).response_onset =  [];
data_csv(1).RT =  [];
data_csv(1).subject_ID =  [];
data_csv(1).block =  [];
data_csv(1).trial_total =  [];
data_csv(1).trial_task =  [];
data_csv(1).trial_type =  [];
data_csv(1).retrival_type =  [];
data_csv(1).baseline_onset =  [];
data_csv(1).baseline_end =  [];
data_csv(1).fix_onset =  [];
data_csv(1).fix_end =  [];
%% Start PTB
% Set Screen Parameters
%make sure computer has correct psychtoolbox for task
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1); % <-remove me?
%select external screen if possible
screens = Screen('Screens');

if ispc
    dispScreen = 1; %% For Debugging
else
    dispScreen = max(screens);
end

% Define black and white
black = BlackIndex(dispScreen);
white = WhiteIndex(dispScreen);

%open screen and get size parameters
[windowPtr, rect] = Screen('OpenWindow',dispScreen,[255 255 255]); % [%[0,0,1024,768]
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Get the size of the on screen window in pixels
[maxWidth, maxHeight] = Screen('WindowSize', windowPtr);

%get flip interval
ifi = Screen('GetFlipInterval', windowPtr);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(rect);

%Set Defaults
fontDefault = txtsize;
Screen('TextSize',windowPtr,fontDefault);
Screen('TextFont',windowPtr,'Arial');

%cursor and keypress stuff
%HideCursor;
ListenChar(1);

% see http://psychtoolbox.org/docs/MaxPriority. This was coded on mac osx
Priority(MaxPriority(windowPtr));

%Prepare key press listeners
KbName('UnifyKeyNames');
num_1 = KbName('1');
num_2 = KbName('2');
num_3 = KbName('3');
num_4 = KbName('4');
escape = KbName('ESCAPE'); %escape key (to exit experiment)
spaceKey = KbName('space');
RestrictKeysForKbCheck([]); %ensure all keypresses are tracked


%% Specify circle for photodiode
baseCircleDiam = 75;
baseCircle = [0 0 baseCircleDiam baseCircleDiam];
centeredCircle = CenterRectOnPointd(baseCircle, maxWidth-0.5*baseCircleDiam, 1+0.5*baseCircleDiam); %
circleColor1 = [white white white]; % white
circleColor2 = [black black black]; % black

%% Task Timing
% Set up the experiment
c = clock; %Current date and time as date vector. [year month day hour minute seconds]
time = strcat(num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))); %makes unique filename
taskStartTime = GetSecs; % time experiment starts

counter = 0;
trial_total = 1;
if block == 0
    n_blocks = 0;
else
    n_blocks =6;
end

for block_idx = block:n_blocks
    
    name2save = [subject '_MemTask_List_' list '_Block_' num2str(block_idx) '_' time '.csv'];
    name2save = fullfile(sub_folder,name2save);
    
    %% Load block order from csv file
    
    block_file = fullfile(block_data,list, [list '_0' int2str(block_idx) '.csv']);
    csv = readtable(block_file);
    csv = table2struct(csv);
    trial_type = {csv(:).trial_type};
    % Trial numbers
    n_encoding = sum(~cellfun('isempty', strfind(trial_type, 'Encoding')));
    n_retrieval = sum(~cellfun('isempty', strfind(trial_type, 'Retrieval')));
    n_trials = n_encoding + n_retrieval;
    
    %% Extract stimuli order from csv file
    % Encoding
    enc_face_order = {csv(:).target};
    enc_face_order = enc_face_order(1:n_encoding)';
    
    enc_object_order = {csv(:).object};
    enc_object_order = enc_object_order(1:n_encoding)';
    
    enc_baseline_order = {csv(:).baseline};
    enc_baseline_order = cell2mat(enc_baseline_order(1:n_encoding)');
    
    % Retrieval order
    ret_face_order = {csv(:).target};
    ret_face_order = ret_face_order((n_encoding + 1):end)';
    
    ret_object_order = {csv(:).object};
    ret_object_order = ret_object_order((n_encoding + 1):end)';
    
    ret_lure1_order = {csv(:).lure1};
    ret_lure1_order = ret_lure1_order((n_encoding + 1):end)';
    
    ret_lure2_order = {csv(:).lure2};
    ret_lure2_order = ret_lure2_order((n_encoding + 1):end)';
    
    ret_type_order = {csv(:).retrieval_type};
    ret_type_order = ret_type_order((n_encoding + 1):end)';
    
    ret_baseline_order = {csv(:).baseline};
    ret_baseline_order = cell2mat(ret_baseline_order((n_encoding + 1):end)');
    
    
    %% Instructions
    dstRect = [0 0 maxWidth maxHeight];
    n_slides = 3;
    
    if block_idx == 0
        for slide_idx = 1:n_slides
            inst = imread(fullfile(instruction_folder,['instructions' num2str(slide_idx) '.JPG']));
            inst = Screen('MakeTexture', windowPtr, inst);
            Screen('DrawTexture', windowPtr, inst, [], dstRect);
            Screen('Flip', windowPtr);
            spaceKey = KbName('space');
            
            while true
                % Check the state of the keyboard.
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(spaceKey)
                        keyIsDown = 0;
                        keyCode = 0;
                        break;
                    end
                end
            end
            keyIsDown = 0;
            keyCode = 0;
            WaitSecs(1);
        end
        
    end
    
    %% Wait for Subject input
    DrawFormattedText(windowPtr, 'To start the experiment press the spacebar', 'center', 'center', black);
    Screen('Flip', windowPtr);
    spaceKey = KbName('space');
    
    while true
        % Check the state of the keyboard.
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(spaceKey)
                break;
            end
        end
    end
    
    stimFlipFrames = round(10/ifi);
    second = round(1/ifi);
    frameCount = 1;
    
    while frameCount <= stimFlipFrames
        curr_frames = stimFlipFrames - frameCount;
        curr_time = round(curr_frames/second);
        DrawFormattedText(windowPtr, ['The experiment will start in: ' num2str(curr_time) ' seconds'], 'center', 'center', black);
        Screen('Flip', windowPtr);
        frameCount = frameCount + 1;
    end
    
    %% Encoding Loop
    
    for trial_idx = 1:n_encoding
        
        if ~ispc %for debugging
            to_exit = pause_script(windowPtr);
            if to_exit
                sca;
                return
            end
        end
        
        %Read Stimuli
        trial_face = imread(fullfile(face_folder, [enc_face_order{trial_idx,1} '.png']));
        face_name = enc_face_order{trial_idx,1};
        trial_face = Screen('MakeTexture', windowPtr, trial_face);
        trial_object = imread(fullfile(object_folder, [enc_object_order{trial_idx,1} '_exemplar1.jpg']));
        trial_object = Screen('MakeTexture', windowPtr, trial_object);
        
        % Calculate positions for the images
        xPos1 = (maxWidth - s2 - s4 - gap) / 2;
        xPos2 = xPos1 + s2 + gap;
        yPos = (maxHeight - s1) / 2;
        yPositionLabel = (yPos + s3 / 2 ) + 178; % Position below the right image
        
        % Center the rectangles on the calculated positions
        dstRect1 = CenterRectOnPointd(rect1, xPos1 + s2 / 2, yPos + s1 / 2);
        dstRect2 = CenterRectOnPointd(rect2, xPos2 + s4 / 2, yPos + s3 / 2);
        
        % Baseline White Screen
        baseline_time = enc_baseline_order(trial_idx,1);
        stimFlipFrames = round(baseline_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);

        frameCount = 1;
        
        while frameCount <= stimFlipFrames
            flipTimes(1,frameCount) = Screen('Flip', windowPtr);
            frameCount = frameCount + 1;
        end
        
        baseline_Onset = flipTimes(1,1) - taskStartTime;
        baseline_End = flipTimes(1,end) - taskStartTime;
        
        % Encoding Period
        stimFlipFrames = round(encoding_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        
        while frameCount <= stimFlipFrames
            Screen('DrawTexture', windowPtr, trial_object, [], dstRect1);
            Screen('DrawTexture', windowPtr, trial_face, [], dstRect2);
            DrawFormattedText(windowPtr, face_name, 'center', yPositionLabel, black, [], [], [], [], [], dstRect2);
            if frameCount <= 3
                Screen('FillOval', windowPtr, circleColor2, centeredCircle, baseCircleDiam);
            end
            flipTimes(1,frameCount) = Screen('Flip',windowPtr);
            frameCount = frameCount + 1;
            
        end
        
        encoding_Onset = flipTimes(1,1) - taskStartTime;
        encoding_End = flipTimes(1,end) - taskStartTime;
        
        % Fixation Cross
        fix_duration = round( low_lim + (upp_lim - low_lim) * rand,2);
        stimFlipFrames = round(fix_duration/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        
        while frameCount <= stimFlipFrames
            DrawFormattedText(windowPtr, '+', 'center', 'center', black);
            flipTimes(1,frameCount) = Screen('Flip', windowPtr);
            frameCount = frameCount + 1;
        end
        
        fix_Onset = flipTimes(1,1) - taskStartTime;
        fix_End = flipTimes(1,end) - taskStartTime;
        
        % Elaborate Phase
        stimFlipFrames = round(elaborate_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        keyPressed = 0;
        responses = zeros(stimFlipFrames,3);
        
        while frameCount <= stimFlipFrames
            DrawFormattedText(windowPtr, 'Mental Image: Elaborate', 'center', maxHeight * 0.2, black);
            DrawFormattedText(windowPtr, '+', 'center', 'center', black);
            
            if frameCount <= 3
                Screen('FillOval', windowPtr, circleColor2, centeredCircle, baseCircleDiam);
            end
            
            numbers = {'1', '2', '3', '4'};
            label = {{{'No'} {'Image'}} {{'Low'} {'Vivid'}}  {{'Mid'} {'Vivid'}}  {{'High'} {'Vivid'}}};
            spacing = maxWidth / 5;
            yPositionNumbers = maxHeight * 2 / 2.5;
            yPositionLabels = yPositionNumbers + 50;
            
            for i = 1:length(numbers)
                xPosition = i * spacing;
                DrawFormattedText(windowPtr, numbers{i}, xPosition, yPositionNumbers, black);
                DrawFormattedText(windowPtr, [label{i}{1}{1} newline  label{i}{2}{1}], xPosition, yPositionLabels, black);
            end
            
            
            [keyPressed,respOnset,keyCode] = KbCheck;
            
            if keyPressed
                temp_resp = [keyPressed,respOnset,find(keyCode)];
                responses(frameCount,:) = temp_resp(1:3);
            end
            
            flipTimes(1,frameCount) = Screen('Flip',windowPtr);
            frameCount = frameCount + 1;
            
            
        end
        
        
        elaborate_Onset = flipTimes(1) - taskStartTime;
        elaborate_End = flipTimes(end) - taskStartTime;
        
        %Save response and RT
        [row,col] = find(responses,1,'last');
        choice = KbName(responses(row,3));
        response_time = responses(row,2) - taskStartTime;
        
        % save data
        data_csv(trial_total).object =  enc_object_order{trial_idx,1};
        data_csv(trial_total).target =  enc_face_order{trial_idx,1};
        data_csv(trial_total).lure1 =  NaN;
        data_csv(trial_total).lure2 =  NaN;
        data_csv(trial_total).baseline =  baseline_time;
        data_csv(trial_total).stim_onset =  encoding_Onset;
        data_csv(trial_total).stim_end =  encoding_End;
        data_csv(trial_total).response =  NaN;
        data_csv(trial_total).correct_response =  NaN;
        data_csv(trial_total).response_onset =  NaN;
        data_csv(trial_total).RT =  NaN;
        data_csv(trial_total).trial_total =  trial_total;
        data_csv(trial_total).trial_task =  trial_idx;
        data_csv(trial_total).trial_type =  'Encoding';
        data_csv(trial_total).retrival_type =  NaN;
        data_csv(trial_total).subject_ID =  subject;
        data_csv(trial_total).list =  list;
        data_csv(trial_total).block =  block_idx;
        data_csv(trial_total).baseline_onset =  baseline_Onset;
        data_csv(trial_total).baseline_end = baseline_End;
        data_csv(trial_total).fix_onset =  NaN;
        data_csv(trial_total).fix_end =  NaN;
        
        trial_total = trial_total + 1;
        
        data_csv(trial_total).object =  enc_object_order{trial_idx,1};
        data_csv(trial_total).target =  enc_face_order{trial_idx,1};
        data_csv(trial_total).lure1 =  NaN;
        data_csv(trial_total).lure2 =  NaN;
        data_csv(trial_total).baseline =  baseline_time;
        data_csv(trial_total).stim_onset =  elaborate_Onset;
        data_csv(trial_total).stim_end =  elaborate_End;
        data_csv(trial_total).response =  choice;
        data_csv(trial_total).correct_response =  NaN;
        data_csv(trial_total).response_onset =  response_time;
        data_csv(trial_total).RT =  response_time  - elaborate_Onset;
        data_csv(trial_total).trial_total =  trial_total;
        data_csv(trial_total).trial_task =  trial_idx;
        data_csv(trial_total).trial_type =  'Encoding_Elaborate';
        data_csv(trial_total).retrival_type =  NaN;
        data_csv(trial_total).subject_ID =  subject;
        data_csv(trial_total).list =  list;
        data_csv(trial_total).block =  block_idx;
        data_csv(trial_total).baseline_onset =  NaN;
        data_csv(trial_total).baseline_end = NaN;
        data_csv(trial_total).fix_onset =  fix_Onset;
        data_csv(trial_total).fix_end =  fix_End;
        
        trial_total = trial_total + 1;

        
    end
    
    
    
    %% Instructions
    dstRect = [0 0 maxWidth maxHeight];
    
    if block_idx == 0
        for slide_idx = (4:6)
            inst = imread(fullfile(instruction_folder,['instructions' num2str(slide_idx) '.JPG']));
            inst = Screen('MakeTexture', windowPtr, inst);
            Screen('DrawTexture', windowPtr, inst, [], dstRect);
            Screen('Flip', windowPtr);
            spaceKey = KbName('space');
            while true
                % Check the state of the keyboard.
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(spaceKey)
                        break;
                    end
                end
            end
            keyIsDown = 0;
            keyCode = 0;
            WaitSecs(1);
        end
    end
    
    
    %% Rest Between Phases
    
    stimFlipFrames = round(rest_time/ifi);
    second = round(1/ifi);
    frameCount = 1;
    
    while frameCount <= stimFlipFrames
        curr_frames = stimFlipFrames - frameCount;
        curr_time = round(curr_frames/second);
        DrawFormattedText(windowPtr, ['You can take a short rest.' newline newline 'The memory task will start in: ' num2str(curr_time) ' seconds'], 'center', 'center', black);
        Screen('Flip', windowPtr);
        frameCount = frameCount + 1;
    end
    
    %% Retrieval Trial
    for trial_idx = 1:n_retrieval
        
        if ~ispc %for debugging
            to_exit = pause_script(windowPtr);
            if to_exit
                sca;
                return
            end
        end
        
        %Read Stimuli
        row_iterator = trial_idx + n_encoding;
        retrieval_type = ret_type_order{trial_idx,1};
        trial_object = imread(fullfile(object_folder, [ret_object_order{trial_idx,1} '_exemplar1.jpg']));
        trial_object = Screen('MakeTexture', windowPtr, trial_object);
        
        trial_target = ret_face_order{trial_idx,1};
        trial_lure1 = ret_lure1_order{trial_idx,1};
        trial_lure2 = ret_lure2_order{trial_idx,1};
        options = {trial_target trial_lure1 trial_lure2};
        options = options(randperm(length(options)));
        
        if strcmp(retrieval_type,'Retrieval')
            corr_resp = find(contains(options,trial_target));
        elseif strcmp(retrieval_type,'Lure')
            corr_resp = 4;
        end
        
        for i = 1:length(options)
            word = options{i} ;
            spaceIndex = strfind(word, ' ');
            beforeSpace = word(1:spaceIndex-1);
            afterSpace = word(spaceIndex+1:end);
            options{i} = {beforeSpace afterSpace};
        end
        
        options{1,4} = {'New', ''};
        
        % Calculate positions for the images
        xPos1 = (maxWidth - s2 - s4 - gap) / 2;
        xPos2 = xPos1 + s2 + gap;
        yPos = (maxHeight - s1) / 2;
        % Center the rectangles on the calculated positions
        dstRect1 = CenterRectOnPointd(rect1, xPos1 + s2 / 2, yPos + s1 / 2);
        
        % Baseline White Screen
        baseline_time = ret_baseline_order(trial_idx,1);
        stimFlipFrames = round(baseline_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);

        frameCount = 1;
        
        while frameCount <= stimFlipFrames
            flipTimes(1,frameCount) = Screen('Flip', windowPtr);
            frameCount = frameCount + 1;
        end
        
        baseline_Onset = flipTimes(1,1) - taskStartTime;
        baseline_End = flipTimes(1,end) - taskStartTime;
        
        % Force Choice
        
        % Present the numbers 1, 2, 3, and 4 below the images with 'number' below each number
        space_breaks = 4;
        numbers = {'  1', '  2', '  3', '  4'};
        spacing = (maxWidth / space_breaks);
        yPositionNumbers = yPos + s1 / 2 + 220;
        yPositionLabels = yPositionNumbers + 75;
        
        stimFlipFrames = round(fc_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        keyPressed = 0;
        responses = zeros(stimFlipFrames,3);
        
        
        while frameCount <= stimFlipFrames
            
            if frameCount <= 3
                Screen('FillOval', windowPtr, circleColor2, centeredCircle, baseCircleDiam);
            end
            
            for i = 1:length(numbers)
                xPosition = (i * spacing) - spacing/1.5;
                DrawFormattedText(windowPtr, numbers{i}, xPosition, yPositionNumbers, black);
                DrawFormattedText(windowPtr, [options{i}{1} newline  options{i}{2}], xPosition, yPositionLabels, black);
            end
            
            
            % Draw the textures on the screen
            Screen('DrawTexture', windowPtr, trial_object, [], dstRect1);
            
            [keyPressed,respOnset,keyCode] = KbCheck;
            
            if keyPressed
                temp_resp = [keyPressed,respOnset,find(keyCode)];
                responses(frameCount,:) = temp_resp(1:3);
            end
            
            flipTimes(1,frameCount) = Screen('Flip',windowPtr);
            frameCount = frameCount + 1;
            
        end
        
        fc_Onset = flipTimes(1) - taskStartTime;
        fc_End = flipTimes(end) - taskStartTime;
        
        % save force choice response
        [row,col] = find(responses,1,'last');
        fc_choice = KbName(responses(row,3));
        fc_response_time = responses(row,2) - taskStartTime;
        
        % Fixation Cross
        fix_duration = round( low_lim + (upp_lim - low_lim) * rand,2);
        stimFlipFrames = round(fix_duration/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        
        while frameCount <= stimFlipFrames
            DrawFormattedText(windowPtr, '+', 'center', 'center', black);
            flipTimes(1,frameCount) = Screen('Flip', windowPtr);
            frameCount = frameCount + 1;
        end
        
        fix_Onset = flipTimes(1,1) - taskStartTime;
        fix_End = flipTimes(1,end) - taskStartTime;
        
        % Remember Phase
        stimFlipFrames = round(retrieval_time/ifi);
        flipTimes = zeros(1,stimFlipFrames);
        frameCount = 1;
        keyPressed = 0;
        responses = zeros(stimFlipFrames,3);
        keyPressed = 0;
        
        numbers = {'1', '2', '3', '4'};
        label = {{{'No'} {'Image'}} {{'Low'} {'Vivid'}}  {{'Mid'} {'Vivid'}}  {{'High'} {'Vivid'}}};
        spacing = maxWidth / 5;
        yPositionNumbers = maxHeight * 2 / 2.5;
        yPositionLabels = yPositionNumbers + 50;
        
        while frameCount <= stimFlipFrames
            
            if frameCount <= 3
                Screen('FillOval', windowPtr, circleColor2, centeredCircle, baseCircleDiam);
            end
            
            % Second part
            DrawFormattedText(windowPtr, 'Mental Image: Recall', 'center', maxHeight * 0.2, black);
            DrawFormattedText(windowPtr, '+', 'center', 'center', black);
            
            for i = 1:length(numbers)
                xPosition = i * spacing;
                DrawFormattedText(windowPtr, numbers{i}, xPosition, yPositionNumbers, black);
                DrawFormattedText(windowPtr, [label{i}{1}{1} newline  label{i}{2}{1}], xPosition, yPositionLabels, black);
            end
            
            [keyPressed,respOnset,keyCode] = KbCheck;
            
            if keyPressed
                temp_resp = [keyPressed,respOnset,find(keyCode)];
                responses(frameCount,:) = temp_resp(1:3);
            end
            
            flipTimes(1,frameCount) = Screen('Flip',windowPtr);
            frameCount = frameCount + 1;
            
            
            
        end
        
        recall_Onset = flipTimes(1) - taskStartTime;
        recall_End = flipTimes(end) - taskStartTime;
        
        % Save recall responses
        [row,col] = find(responses,1,'last');
        recall_choice = KbName(responses(row,3));
        recall_response_time = responses(row,2) - taskStartTime;
        
        % save data
        
        data_csv(trial_total).object =  ret_object_order{trial_idx,1};
        data_csv(trial_total).target = trial_target;
        data_csv(trial_total).lure1 =  trial_lure1;
        data_csv(trial_total).lure2 =  trial_lure2;
        data_csv(trial_total).baseline =  baseline_time;
        data_csv(trial_total).stim_onset =  fc_Onset;
        data_csv(trial_total).stim_end =  fc_End;
        data_csv(trial_total).response =  fc_choice;
        data_csv(trial_total).correct_response =  corr_resp;
        data_csv(trial_total).response_onset =  fc_response_time;
        data_csv(trial_total).RT =  fc_response_time  - fc_Onset;
        data_csv(trial_total).trial_total =  trial_total;
        data_csv(trial_total).trial_task =  trial_idx;
        data_csv(trial_total).trial_type =  'Retrieval_FC';
        data_csv(trial_total).retrival_type =  retrieval_type;
        data_csv(trial_total).subject_ID =  subject;
        data_csv(trial_total).list =  list;
        data_csv(trial_total).block =  block_idx;
        data_csv(trial_total).baseline_onset =  baseline_Onset;
        data_csv(trial_total).baseline_end = baseline_End;
        data_csv(trial_total).fix_onset =  NaN;
        data_csv(trial_total).fix_end =  NaN;
        
        trial_total = trial_total + 1;
        
        data_csv(trial_total).object =  ret_object_order{trial_idx,1};
        data_csv(trial_total).target = trial_target;
        data_csv(trial_total).lure1 =  trial_lure1;
        data_csv(trial_total).lure2 =  trial_lure2;
        data_csv(trial_total).baseline =  baseline_time;
        data_csv(trial_total).stim_onset =  recall_Onset;
        data_csv(trial_total).stim_end =  recall_End;
        data_csv(trial_total).response =  recall_choice;
        data_csv(trial_total).RT =  recall_choice  - recall_Onset;
        data_csv(trial_total).correct_response =  NaN;
        data_csv(trial_total).response_onset =  recall_response_time;
        data_csv(trial_total).trial_total =  trial_total;
        data_csv(trial_total).trial_task =  trial_idx;
        data_csv(trial_total).trial_type =  'Retrieval_Recall';
        data_csv(trial_total).retrival_type =  retrieval_type;
        data_csv(trial_total).subject_ID =  subject;
        data_csv(trial_total).list =  list;
        data_csv(trial_total).block =  block_idx;
        data_csv(trial_total).baseline_onset =  NaN;
        data_csv(trial_total).baseline_end = NaN;
        data_csv(trial_total).fix_onset =  fix_Onset;
        data_csv(trial_total).fix_end =  fix_End;
        trial_total = trial_total + 1;
        
    end
    
    %% Instructions
    dstRect = [0 0 maxWidth maxHeight];
    
    if block_idx == 0
        for slide_idx = 8
            inst = imread(fullfile(instruction_folder,['instructions' num2str(slide_idx) '.JPG']));
            inst = Screen('MakeTexture', windowPtr, inst);
            Screen('DrawTexture', windowPtr, inst, [], dstRect);
            Screen('Flip', windowPtr);
            spaceKey = KbName('space');
            while true
                % Check the state of the keyboard.
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(spaceKey)
                        break;
                    end
                end
            end
            
        end
    end
    
    if block_idx ~= 0
        
        if block_idx < 6
            DrawFormattedText(windowPtr, ['You just finished Block: ' num2str(block_idx) newline 'To continue with the experiment press the spacebar'], 'center', 'center', black);
        elseif block_idx == 6
            DrawFormattedText(windowPtr, ['You just finished the last block.' newline 'To finish with the experiment press the spacebar'], 'center', 'center', black);           
        end
        
        Screen('Flip', windowPtr);
        spaceKey = KbName('space');
        
        while true
            % Check the state of the keyboard.
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(spaceKey)
                    break;
                end
            end
        end
    end
        
    %% Loop End (here the loop ends, before saving the data
    

    writetable(struct2table(data_csv),name2save);

    counter = counter+1;
end

Screen('CloseAll');
 
end

