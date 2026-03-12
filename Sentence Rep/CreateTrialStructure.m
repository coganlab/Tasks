function [trialStruct,trialShuffle,shuffleIdx,shuffBase]=CreateTrialStructure(rotNumb,nTrials,practice)    
%Create structure to shuffle
    trialStruct.cue={'Listen',':=:'};
    trialStruct.sound={'heat','hot','hut','hoot','dog','mice','fame'};
    trialStruct.go={'Speak','Mime',''};
    % Create Trial Structure and shuffle:
    trialShuffle=zeros(3,nTrials);
    % rotNumb=numel(trialStruct.cue)*numel(trialStruct.sound)*numel(trialStruct.go);
    % shuffBase=zeros(3,rotNumb);
    % iM=0;
    % for i=1:numel(trialStruct.cue)
    %     for ii=1:numel(trialStruct.cue)
    %         for iii=1:2 %numel(trialStruct.go) %note: overridden to account for lack of speaking cue
    %             shuffBase(1,iM+1)=i;
    %             shuffBase(2,iM+1)=ii;
    %             shuffBase(3,iM+1)=iii;
    %             iM=iM+1;
    %         end
    %     end
    % end
    
    
    shuffBase = zeros(3,rotNumb);
    % turns out I don't want all possible options for a trial, only a subset
    %shuffBase=[1,1,1;1,1,2;1,2,1;1,2,2;2,1,1;2,1,2;2,1,2;2,2,2;3,1,3;3,2,3]';
    for i=1:7;
        shuffBase(1,i)=1;
        shuffBase(2,i)=i;
        shuffBase(3,i)=1;
        shuffBase(1,i+7)=2;
        shuffBase(2,i+7)=i;
        shuffBase(3,i+7)=3;
        shuffBase(1,i+14)=1;
        shuffBase(2,i+14)=i;
        shuffBase(3,i+14)=2;
    end
    
    shuffBase(:,19:21)=[];
    shuffBase(4,:)=1:rotNumb;
    if practice==1
        shuffBase(4,:)=shuffBase(4,:)+100;
    end
   % shuffIdx=shuffle(repmat(shuffBase(4,:),1,nTrials/rotNumb));
    trialShuffle=repmat(shuffBase,1,nTrials/rotNumb);
    shuffleIdx=Shuffle(1:nTrials);
    trialShuffle=trialShuffle(:,shuffleIdx);
