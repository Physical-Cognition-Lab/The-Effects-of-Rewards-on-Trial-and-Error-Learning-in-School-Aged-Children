% access the csv files with the results from the 2 links
% (fr-France, english)

clear all;
clc;
cd('/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance');
 
% add the group column on each csv file (g1- Positive Reward group, g2-
% Negative Reward group, g3 - Control group). 
 
 for ii = 1:6
     switch ii
                 case 1
             t = readtable('gametools_score_fr_game_g1.csv');
             numOfColumn = size(t, 2);
t(:,end+1) = {1}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupFrench1.csv');
         case 2
               t = readtable('gametools_score_fr_game_g2.csv');
               numOfColumn = size(t, 2);
t(:,end+1) = {2}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupFrench2.csv')

         case 3
              t = readtable('gametools_score_fr_game_g3.csv');
              numOfColumn = size(t, 2);
t(:,end+1) = {3}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupFrench3.csv')
         

case 4
         t = readtable('gametools_score_game_g1.csv');
         numOfColumn = size(t, 2);
t(:,end+1) = {1}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupEnglish1.csv')

case 5
         t = readtable('gametools_score_game_g2.csv');
         numOfColumn = size(t, 2);
t(:,end+1) = {2}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupEnglish2.csv')

         case 6
         t = readtable('gametools_score_game_g3.csv');
         numOfColumn = size(t, 2);
t(:,end+1) = {3}; %  new column with group
t.Properties.VariableNames{numOfColumn+1} = 'Group';
writetable(t, '/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping/groupEnglish3.csv')
     end
 end
 
% merge all csv group files into one file
cd('/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_performance/with grouping');
database_games = table();
  fileNames = dir('*.csv');
 for ii = 1:6
     d0 = readtable(fileNames(ii).name);
     database_games = [database_games; d0];
 end
 
 % access the csv files with the participants' socio demographic data from the 2 links and merge FR and EN participants into one csv file
 cd('/Users/nicolas/Documents/helene/londres/Birkbeck/journal drafts/Rewards/csv data/Data_Demographics');
 
 database_participants = table();
 fileNames = dir('*.csv');
 for ii = 1:numel(fileNames)
     d0 = readtable(fileNames(ii).name);
     database_participants = [database_participants; d0];
 end
 %
 % display a shorter version of participants details (without SES) and change date format
mask = contains(database_participants{:,6}, ["dob","Age","What is your child gender?","In which country do your child live","Dans quel pays votre enfant habite-t-il?","Quel est le sexe de votre enfant ?","Quel ‚Äö√Ñ√∂‚àö√ë‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ‚Ä†‚Äö√†√∂‚Äö√†√á‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢¬¨¬®¬¨¬Æ¬¨¬®¬¨√Ü¬¨¬®¬¨¬Æ¬¨¬®¬¨¬¢ge as-tu ?","From 1", "Sur une"]);
participants_short=database_participants(mask,:);
 participants_short.DATE = strrep(participants_short.DATE,{'/'},{'-'});
participants_short.DATE2 =  datetime(participants_short.DATE,'InputFormat','dd-MM-yyyy');

 
% data cleaning 
 
% remove test participants 
testPP=(participants_short.ANSWER ~="test")&(participants_short.PID ~=669) &(participants_short.PID ~=1444)&(participants_short.PID ~=1445)&(participants_short.PID ~=1447)& (participants_short.PID ~=1450)&(participants_short.PID ~=1558)& (participants_short.DATE2 > '09-Mar-2022')
 participants_short.Remove(testPP)=1;
 teststats=grpstats(participants_short,{ 'PID','DATE2'},{'min'},'DataVars',{'Remove'});
real_participants=teststats(teststats.min_Remove>0,:); 
  
% keeping only the latest date for participants who played in several times
x=[]
index=0
for i=1:size(real_participants, 1) 
  index=index+1
  x(end+1) = index
end
real_participants.index=x'
real_participants.PIDindex=strcat(string(real_participants.PID),'-',string(real_participants.index));
allparticipants=grpstats(real_participants,{'PID'}',{'max'},'DataVars',{'index'});
allparticipants.PIDindex=strcat(string(allparticipants.PID),'-',string(allparticipants.max_index));
allparticipantswithdate=innerjoin(allparticipants,real_participants,'Keys','PIDindex');
allparticipantswithdate.Properties.VariableNames{'PID_allparticipants'} = 'PID';
 
% remove demo trials (trials 1 and 2)
indicestrialok=(database_games.TRIAL>2); 
Nodemotrials = database_games(indicestrialok, :);

% remove trials with time empty data
 
 Nodemotrials = fillmissing(Nodemotrials,'constant',0,'DataVariables',{'TIME'});
  Nodemotrials.withtimeissue=(Nodemotrials.TIME==0);
removetrialswithouttimedata=grpstats(Nodemotrials,{ 'PID','TRIAL'},{'max'},'DataVars',{'withtimeissue'});
 removetrialswithouttimedata.Remove=(removetrialswithouttimedata.max_withtimeissue>0);
Nodemotrials=innerjoin(Nodemotrials,removetrialswithouttimedata,'Keys',{ 'PID','TRIAL'});
trialswithtimedata=(Nodemotrials.Remove<1);
TrialOK=Nodemotrials(trialswithtimedata,:);
TrialOK=TrialOK(:,[1:12]);

% removing attempts which are duplicated

Nbofsimilarattempt=groupcounts(TrialOK,{'PID','TRIAL','ATTEMPT'});
removeseveralattemptinatrial=grpstats(Nbofsimilarattempt,{ 'PID','TRIAL','ATTEMPT'},{'min'},'DataVars',{'GroupCount'});
removeseveralattemptinatrial.Remove=removeseveralattemptinatrial.min_GroupCount>1;
withoutrepeatedattemptpertrial=grpstats(removeseveralattemptinatrial,{ 'PID','TRIAL'},{'max'},'DataVars',{'Remove'});
withoutrepeatedattemptpertrial=withoutrepeatedattemptpertrial(withoutrepeatedattemptpertrial.max_Remove<1,:);
Trialsfinalshort2=innerjoin(TrialOK,withoutrepeatedattemptpertrial,'Keys',{ 'PID','TRIAL'});

%removing trials with several success rates

Nbofsuccessrateforanattempt=grpstats(Trialsfinalshort2,{ 'PID','TRIAL'},{'sum'},'DataVars',{'SUCCESS'});
Nbofsuccessrateforanattempt.Remove=Nbofsuccessrateforanattempt.sum_SUCCESS>1;
withoutmorethan1Successpertrial=Nbofsuccessrateforanattempt(Nbofsuccessrateforanattempt.Remove==0,:)
Trialsfinal=innerjoin(Trialsfinalshort2,withoutmorethan1Successpertrial,'Keys',{ 'PID','TRIAL'});
Trialsfinalshort=Trialsfinal(:,[1,2]);
Countofdistincttrials=unique(Trialsfinalshort);
Countoftrials=groupcounts(Countofdistincttrials,'PID');

% create a database with correct trials and PID

correcttrialsPIDlevel = grpstats(Trialsfinal,{'Group', 'PID'},{'min','max','sum',},'DataVars',{'TRIAL','ATTEMPT','TIME','SUCCESS'});
 correcttrialsforcorrectPID=innerjoin(allparticipantswithdate,correcttrialsPIDlevel,'Keys','PID'); 
correcttrialsforcorrectPID=correcttrialsforcorrectPID(:,[1:4,6,10:23]); 

% remove participants with insufficient nb of trials(according to pre registration criteria, participants need to do at least 10 trials - exclusive of demo trials) 
participantswithnomorethan13trialsmissing=(correcttrialsforcorrectPID.max_TRIAL>11);
participantOK=correcttrialsforcorrectPID(participantswithnomorethan13trialsmissing,:);


% formatting participant database and calculating performance measures
participantOKShortfinal=participantOK(:,[1,6,7,16,19,5]);
participantOKShortfinal.Properties.VariableNames{'GroupCount'} = 'NbAttempt'; 
aggregatedparticipantdatabase=innerjoin(participantOKShortfinal,Countoftrials,'Keys','PID');
aggregatedparticipantdatabase.Properties.VariableNames{'GroupCount'} = 'NbTrial';
 
aggregatedparticipantdatabase.SR=aggregatedparticipantdatabase{:,5}./aggregatedparticipantdatabase{:,7};
aggregatedparticipantdatabase.TimeperAttempt=aggregatedparticipantdatabase{:,4}./aggregatedparticipantdatabase{:,3};
aggregatedparticipantdatabase.NbAttemptperTrial=aggregatedparticipantdatabase{:,3}./aggregatedparticipantdatabase{:,7};;
 
% calculate measures (SR, Nb Attempt, Time) at group level
statsGroup=grpstats(aggregatedparticipantdatabase,'Group',{'mean','std'},'DataVars',{'NbAttemptperTrial','TimeperAttempt','SR'});
 
% adding participants demographic data in the database

% calculating participants' age (calculated in matlab by extracting the date of birth from socio demographic
% csv file)

participants_short.Ageindex=strcat(string(participants_short.Q_KEY),'-',string(participants_short.QUESTIONID));
Tableageparticipant=participants_short(participants_short.Ageindex == "QFP-1", :);
Tableageparticipantok=innerjoin(Tableageparticipant,aggregatedparticipantdatabase,'Keys','PID');

G2 = findgroups(Tableageparticipantok{:, 1});
% Split table based on  column
 T_split_Age = splitapply( @(varargin) varargin, Tableageparticipantok , G2);
 
% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables = cell(size(T_split_Age, 1));
 
% Create sub tables
for i = 1:size(T_split_Age, 1)
subTablesAge{i} = table(T_split_Age{i,:}, 'VariableNames', ...
Tableageparticipantok.Properties.VariableNames);
end
%
Age = [];
for i=1:size(T_split_Age, 1) 

dob=strcat(string(subTablesAge{1,i}{1,7}),'-',string(subTablesAge{1,i}{2,7}),'-',string(subTablesAge{1,i}{3,7}));
 
tableage  = table(subTablesAge{1,i}.PID(end,:),dob,subTablesAge{1,i}.DATE2_aggregatedparticipantdatabase(end,:));
         
Age = [Age;  tableage(end,:)];
          end
 
Age
Age.Properties.VariableNames{'Var1'} = 'PID';
Age.dob=datetime(Age.dob,'InputFormat','dd-MM-yyyy');

aggregatedparticipantdatabase=innerjoin(aggregatedparticipantdatabase,Age,'Keys','PID');
aggregatedparticipantdatabase.Properties.VariableNames{'Var3'} = 'DateParticipation';
aggregatedparticipantdatabase.AgeCalculated=datenum((aggregatedparticipantdatabase.DateParticipation- aggregatedparticipantdatabase.dob)/365);
aggregatedparticipantdatabase.agerange=aggregatedparticipantdatabase.AgeCalculated>10;


% pariticpants' gender

idxgender = (participants_short.ANSWER =="Fille"|participants_short.ANSWER =="Girl" );
participants_short.Gender(idxgender) = 1;
idxgender2 = (participants_short.ANSWER =="GarÃ§on"|participants_short.ANSWER =="Boy" );
participants_short.Gender(idxgender2)=2;

TableParticipantsGender = participants_short(participants_short.Gender == 1|participants_short.Gender == 2 , :);
TableParticipantsGender2=TableParticipantsGender(:,[1,12]);
aggregatedparticipantdatabase=innerjoin(aggregatedparticipantdatabase,TableParticipantsGender2,'Keys','PID');

% calculating demographic statistics on participants included in the analysis

meanageparticipantsinanalysis= mean(aggregatedparticipantdatabase.AgeCalculated);
stdageparticipantsinanalysis=std(aggregatedparticipantdatabase.AgeCalculated);
statsgender=grpstats(aggregatedparticipantdatabase,["Gender"],{'mean','std'},'DataVars',{'NbAttemptperTrial','TimeperAttempt','SR','AgeCalculated'});
Gender=table2array(statsgender);

RatioBoysincludedanalysis=Gender(Gender(:,1)==2,2)./(Gender(Gender(:,1)==1,2)+ Gender(Gender(:,1)==2,2))
RatioGirlsincludedanalysis=Gender(Gender(:,1)==1,2)./(Gender(Gender(:,1)==1,2)+ Gender(Gender(:,1)==2,2))


% Calculating M, SD, range for all participants before applying exclusion
% criteria (above)

allparticipantsstartgame_beforeexclusion=innerjoin(correcttrialsforcorrectPID,TableParticipantsGender2,'Keys','PID');
allparticipantsstartgameAGE_beforeexclusion=innerjoin(Tableageparticipant,allparticipantsstartgame_beforeexclusion,'Keys','PID');
G7 = findgroups(allparticipantsstartgameAGE_beforeexclusion{:, 1});

% Split table based on  column
 
T_split_Age_beforeexclusion = splitapply( @(varargin) varargin, allparticipantsstartgameAGE_beforeexclusion , G7);
 
% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables_beforeexclusion = cell(size(T_split_Age_beforeexclusion, 1));
 
% Create sub tables
for i = 1:size(T_split_Age_beforeexclusion, 1)
subTablesAge_beforeexclusion{i} = table(T_split_Age_beforeexclusion{i,:}, 'VariableNames', ...
allparticipantsstartgameAGE_beforeexclusion.Properties.VariableNames);
end
%
Age_beforeexclusion = [];
for i=1:size(T_split_Age_beforeexclusion, 1) 

dob=strcat(string(subTablesAge_beforeexclusion{1,i}{1,7}),'-',string(subTablesAge_beforeexclusion{1,i}{2,7}),'-',string(subTablesAge_beforeexclusion{1,i}{3,7}));
 
tableage_beforeexclusion  = table(subTablesAge_beforeexclusion{1,i}.PID(end,:),subTablesAge_beforeexclusion{1,i}.Group(end,:),dob,subTablesAge_beforeexclusion{1,i}.DATE2_Tableageparticipant(end,:));
         
 Age_beforeexclusion = [Age_beforeexclusion;  tableage_beforeexclusion(end,:)];
          end
 
Age_beforeexclusion
%
Age_beforeexclusion.Properties.VariableNames{'Var1'} = 'PID';
Age_beforeexclusion.dob=datetime(Age_beforeexclusion.dob,'InputFormat','dd-MM-yyyy');


allparticipantsstartgame_beforeexclusion=innerjoin(allparticipantsstartgame_beforeexclusion,Age_beforeexclusion,'Keys','PID');
allparticipantsstartgame_beforeexclusion.Properties.VariableNames{'Var4'} = 'DateParticipation';
allparticipantsstartgame_beforeexclusion.AgeCalculated=datenum((allparticipantsstartgame_beforeexclusion.DateParticipation- allparticipantsstartgame_beforeexclusion.dob)/365);
allparticipantsstartgame_beforeexclusion=allparticipantsstartgame_beforeexclusion(:,[1,6,20,24]);



% calculating 1 way ANOVA on performance measures (1 factor reward group with 3 levels)

data=aggregatedparticipantdatabase(:,[2,8:10]);

 %ANOVA SR Rewards
 sr=data{ :,2 };
 group_SR= data{ :, 1 };
 [p_SR,tbl_SR,stats_SR]=anova1(sr,group_SR);
  df1_SR=tbl_SR{2,3};
df2_SR=tbl_SR{3,3};
Fstat_SR=tbl_SR{2,5};
pvalue_SR=tbl_SR{2,6};
 
 %ANOVA Attempt Rewards
 
 attempt=data{ :, 4 };
 group_Attempt= data{ :, 1 };
 [p_Attempt,tbl_Attempt,stats_Attempt]=anova1(attempt,group_Attempt);
  df1_Attempt=tbl_Attempt{2,3};
df2_Attempt=tbl_Attempt{3,3};
Fstat_Attempt=tbl_Attempt{2,5};
pvalue_Attempt=tbl_Attempt{2,6};
 
 % ANOVA time
 
time=data{ :, 3 };
 group_Time= data{ :,1 };
 [p_Time,tbl_Time,stats_Time]=anova1(time,group_Time);
 df1_Time=tbl_Time{2,3};
df2_Time=tbl_Time{3,3};
Fstat_Time=tbl_Time{2,5};
pvalue_Time=tbl_Time{2,6};

% calculating performance statistics per game
gamesbyPIDReward=innerjoin(Trialsfinal,aggregatedparticipantdatabase,'Keys','PID');
statsPIDpergame=grpstats( gamesbyPIDReward,["TRIAL","NAME","PID","Group_aggregatedparticipantdatabase","AgeCalculated"],{'sum'},'DataVars',{'SUCCESS','TIME'});
statsPIDpergamewithoutname=statsPIDpergame(:,[ 1,3:8]);
statspergame=grpstats( statsPIDpergame,["TRIAL","NAME","Group_aggregatedparticipantdatabase"],{'sum'},'DataVars',{'sum_SUCCESS','sum_TIME','GroupCount'});
statspergame.NbAttemptperTrial=statspergame.sum_GroupCount./statspergame.GroupCount;
statspergame.AvgTimeperAttempt=statspergame.sum_sum_TIME./statspergame.sum_GroupCount;
statspergame.SR=statspergame.sum_sum_SUCCESS./statspergame.GroupCount;

% calculating strategy measures (distance between attempts, number of
% tools, tool switching)
 
% distance calculation

% adding an index per participant
statsPIDaggreg=grpstats( statsPIDpergame,["PID","Group_aggregatedparticipantdatabase","AgeCalculated"],{'sum'},'DataVars',{'sum_SUCCESS','sum_TIME','GroupCount'});
statsPIDaggreg=sortrows(statsPIDaggreg,'AgeCalculated','ascend');

y=[]
index=0
for i=1:size(statsPIDaggreg, 1) 
  index=index+1
  y(end+1) = index
end
statsPIDaggreg.index=y'
 DatabasegamebyRewardPID=innerjoin(gamesbyPIDReward,statsPIDaggreg,'Keys','PID');

  DatabasegamebyRewardPIDshort=DatabasegamebyRewardPID(:,[38,1,2,3,4,6,7,12,29]);
 tblstats = grpstats(DatabasegamebyRewardPIDshort,{'index','PID','TRIAL','NAME'},["numel"]);
 
% excluding trials solved in one attempt (as we only calculate distance if there are two attempts or more)
uniquetrials=(tblstats.numel_POSX>1);
repeatedtrials = tblstats(uniquetrials, :);
databaserepeatedtrials=innerjoin(repeatedtrials, DatabasegamebyRewardPIDshort,'Keys',{'index', 'PID','TRIAL','NAME'});
databaserepeatedtrials.Var1 = strcat(string(databaserepeatedtrials.index), '_', string(databaserepeatedtrials.TRIAL))

% excluding missing values
databaserepeatedtrials=databaserepeatedtrials(~any(ismissing(databaserepeatedtrials),2),:);
G1 = findgroups(databaserepeatedtrials{:, 16});

% Split table based on  column
T_split_PIDTRIAL = splitapply( @(varargin) varargin, databaserepeatedtrials , G1);

% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables = cell(size(T_split_PIDTRIAL, 1));

% Create sub tables and calculate euclidian distance
for i = 1:size(T_split_PIDTRIAL, 1)
subTablesPIDTRIAL{i} = table(T_split_PIDTRIAL{i,:}, 'VariableNames', ...
databaserepeatedtrials.Properties.VariableNames);
end
%
Distance = [];
for i=1:size(T_split_PIDTRIAL, 1)
    
     PIDTrialtest_i=subTablesPIDTRIAL{1,i} ;
   
     Dist = zeros(1,size(PIDTrialtest_i,1)-1);   
     
          for ii=1:size(subTablesPIDTRIAL{1,i},1)-1
      
     data1 = subTablesPIDTRIAL{1,i}(ii,:);
     data2 = subTablesPIDTRIAL{1,i}(ii+1,:)
     
     data1array=table2array(data1);
     data1arrayV2=str2double(data1array);
  
     data2array=table2array(data2);
     data2arrayV2=str2double(data2array);
  
     distance = sqrt(((data1arrayV2(12)-data2arrayV2(12))^2)+(data1arrayV2(13)-data2arrayV2(13))^2);
     
     
     Dist(ii) = distance;
          end
          Dist
     averagedistance=mean(Dist);
     %
    tableaveragedistance  = table(subTablesPIDTRIAL{1,i}.index(end,:),subTablesPIDTRIAL{1,i}.PID(end,:),subTablesPIDTRIAL{1,i}.Group_Trialsfinal(end,:),subTablesPIDTRIAL{1,i}.NAME(end,:),subTablesPIDTRIAL{1,i}.TRIAL(end,:),subTablesPIDTRIAL{1,i}.AgeCalculated_gamesbyPIDReward(end,:),averagedistance)
         
  Distance = [Distance;  tableaveragedistance(end,:)];
          end

Distance
 Distance = sortrows(Distance,'Var1','ascend');

 % presenting distance data in the database
 DATA.Participantdistance=Distance(:,[1,2,3,5,7,6]);
 H4=table2array(DATA.Participantdistance);
DistanceaggregbyReward= grpstats(Distance,{'Var3','Var5'},{'mean'},'DataVars',{'averagedistance'});
DATA.Rewarddistanceaggreg=DistanceaggregbyReward(:,[1,2,4]);
H4b=table2array(DATA.Rewarddistanceaggreg);

% calculating ANOVA on Distance (1 way ANOVA- factor reward group, 3
% levels)

DistanceaggregbyRewardbyPID=grpstats(Distance,{'Var3','Var2'}',{'mean'},'DataVars',{'averagedistance'}); 
distanceanova=DistanceaggregbyRewardbyPID{ :,4 };
 group_distance= DistanceaggregbyRewardbyPID{ :, 1 };
 [p_distance,tbl_distance,stats_distance]=anova1(distanceanova,group_distance);
 df1_Distance=tbl_distance{2,3};
df2_Distance=tbl_distance{3,3};
Fstat_Distance=tbl_distance{2,5};
pvalue_Distance=tbl_distance{2,6};

DistanceaggregbyReward3=grpstats(DistanceaggregbyRewardbyPID,{'Var3'},{'mean'},'DataVars',{'mean_averagedistance'});

% Analysis distance by age
DistanceaggregbyRewardage= grpstats(Distance,{'Var3','Var6'},{'mean'},'DataVars',{'averagedistance'});
DATA.Rewarddistanceaggregage=DistanceaggregbyRewardage(:,[1,2,4]);
H4bage=table2array(DATA.Rewarddistanceaggregage);

% Analysis on Number of Tools used

DatabasegamebyRewardtool=DatabasegamebyRewardPID(:,[38,1,2,3,4,5,12,29]);

% count the nb of tools used in a game by pid and stim 
 testcounttools = groupsummary(DatabasegamebyRewardtool,["index","PID","AgeCalculated_gamesbyPIDReward","Group_Trialsfinal","TRIAL","NAME","TOOL"]);

% excluding missing values
testcounttools=testcounttools(~any(ismissing(testcounttools),2),:);

% database with number of tools used

Countoftools=groupcounts(testcounttools,{ 'index','PID','AgeCalculated_gamesbyPIDReward','Group_Trialsfinal','TRIAL','NAME'});
Countoftools.Properties.VariableNames{'GroupCount'} = 'NbTools';
statstoolsbyReward=grpstats(Countoftools,["Group_Trialsfinal","TRIAL","NAME"],{'mean'},'DataVars',{'NbTools'});
statstoolsbyRewardaggreg=grpstats(Countoftools,["Group_Trialsfinal"],{'mean'},'DataVars',{'NbTools'});
DATA.tools=statstoolsbyRewardaggreg(:,[1,3]);
H6=table2array(DATA.tools);
DATA.toolsdetail=statstoolsbyReward(:,[1,2,4,5]);
H6b=table2array(DATA.toolsdetail);

% ANOVA Tools used (1 way, factor= reward group, 3 levels)

ToolsbyRewardbyPID=grpstats(Countoftools,{'Group_Trialsfinal','PID'}',{'mean'},'DataVars',{'NbTools'});
Toolsanova=ToolsbyRewardbyPID{ :,4 };
 group_Tools= ToolsbyRewardbyPID{ :, 1 };
 [p_Tools,tbl_Tools,stats_Tools]=anova1(Toolsanova,group_Tools);
df1_Tools=tbl_Tools{2,3};
df2_Tools=tbl_Tools{3,3};
Fstat_Tools=tbl_Tools{2,5};
pvalue_Tools=tbl_Tools{2,6};

% Analysis tool by reward by age

statstoolsbyRewardage=grpstats(Countoftools,["Group_Trialsfinal","AgeCalculated_gamesbyPIDReward"],{'mean'},'DataVars',{'NbTools'});
DATA.toolsRewardage=statstoolsbyRewardage(:,[1,2,4]);
H6bage=table2array(DATA.toolsRewardage);


% Tool switching analysis

%create an index for tool
idxtool1 = (DatabasegamebyRewardtool.TOOL =="obj1");
DatabasegamebyRewardtool.Tool(idxtool1) = 1;
idxtool2 = (DatabasegamebyRewardtool.TOOL =="obj2");
DatabasegamebyRewardtool.Tool(idxtool2) = 2;
idxtool3 = (DatabasegamebyRewardtool.TOOL =="obj3");
DatabasegamebyRewardtool.Tool(idxtool3) = 3;

DatabasegamebyRewardtool.group=strcat(string(DatabasegamebyRewardtool.index),'-',string(DatabasegamebyRewardtool.TRIAL));
databaserepeatedtrialsfortools=innerjoin(repeatedtrials,DatabasegamebyRewardtool,'Keys',{'index', 'PID','TRIAL','NAME'});

G6 = findgroups(databaserepeatedtrialsfortools{:, 16});

% Split table based on  column
T_split_PIDTRIAL_Tool = splitapply( @(varargin) varargin, databaserepeatedtrialsfortools , G6);

% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables = cell(size(T_split_PIDTRIAL_Tool, 1));

% Create sub tables
for i = 1:size(T_split_PIDTRIAL_Tool, 1)
subTablesPIDTRIAL_Tool{i} = table(T_split_PIDTRIAL_Tool{i,:}, 'VariableNames', ...
databaserepeatedtrialsfortools.Properties.VariableNames);
end
  
ToolSwitching = [];
for i=1:size(T_split_PIDTRIAL_Tool, 1)
    
     PIDTrialtest_Tool_i=subTablesPIDTRIAL_Tool{1,i} ;
   
     Switch = zeros(1,size(PIDTrialtest_Tool_i,1)-1);   
     
          for ii=1:size(subTablesPIDTRIAL_Tool{1,i},1)-1
      
     data1 = subTablesPIDTRIAL_Tool{1,i}(ii,:);
     data2 = subTablesPIDTRIAL_Tool{1,i}(ii+1,:);
     
     data1array=table2array(data1);
     data1arrayV2=str2double(data1array);
  
     data2array=table2array(data2);
     data2arrayV2=str2double(data2array);
  
     Switching = (data1arrayV2(15)-data2arrayV2(15));
     
     
     Switch(ii) = Switching;
          end
          Switch;
    
          testSwitch=(Switch ~=0);
 sumswitch=sum(testSwitch);
    tabletoolswitch  = table(subTablesPIDTRIAL_Tool{1,i}.index(end,:),subTablesPIDTRIAL_Tool{1,i}.PID(end,:),subTablesPIDTRIAL_Tool{1,i}.NAME(end,:),subTablesPIDTRIAL_Tool{1,i}.TRIAL(end,:),subTablesPIDTRIAL_Tool{1,i}.Group_Trialsfinal(end,:),subTablesPIDTRIAL_Tool{1,i}.numel_ATTEMPT(end,:),subTablesPIDTRIAL_Tool{1,i}.AgeCalculated_gamesbyPIDReward(end,:),sumswitch);
  ToolSwitching = [ToolSwitching;  tabletoolswitch(end,:)];
          end

ToolSwitching;
ToolSwitching = sortrows(ToolSwitching,'Var1','ascend');

% reducing by 1 to get the number of attempts with possible tool switch
ToolSwitching.Switchingrate=ToolSwitching.sumswitch./(ToolSwitching.Var6-1);
ToolSwitching.Properties.VariableNames{6} = 'Nb of attempt';
DATA.toolswitchingbygame=ToolSwitching(:,[1,2,4,5,9]);
H6c=table2array(DATA.toolswitchingbygame);
ToolSwitchingbyPID=grpstats(ToolSwitching,["Var1","Var2","Var5"],{'mean'},'DataVars',{'Switchingrate'});

DATA.toolswitching=ToolSwitchingbyPID(:,:);
H6d=table2array(DATA.toolswitching);
statstoolswitchingbyRewardaggreg=grpstats(ToolSwitchingbyPID,["Var5"],{'mean'},'DataVars',{'mean_Switchingrate'});
DATA.toolswitchinggroup=statstoolswitchingbyRewardaggreg(:,:);
H6e=table2array(DATA.toolswitchinggroup);

% ANOVA Tool Switching (1 way ANOVA, factor rewards group 3 levels)

Toolswitchinganova=ToolSwitchingbyPID{ :,5 };
 group_Toolswitching= ToolSwitchingbyPID{ :, 3 };
 [p_Toolswtiching,tbl_Toolswitching,stats_Toolswitching]=anova1(Toolswitchinganova,group_Toolswitching);
df1_Toolswitching=tbl_Toolswitching{2,3};
df2_Toolswitching=tbl_Toolswitching{3,3};
Fstat_Toolswitching=tbl_Toolswitching{2,5};
pvalue_Toolswitching=tbl_Toolswitching{2,6};

% Analysis tool switching by reward by age

ToolSwitchingbyRewardage=grpstats(ToolSwitching,["Var5","Var7"],{'mean'},'DataVars',{'Switchingrate'});
DATA.toolswitchingRewardage=ToolSwitchingbyRewardage(:,:);
H6eage=table2array(DATA.toolswitchingRewardage);

