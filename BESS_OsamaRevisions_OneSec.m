% NAME:     BESS_OsamaRevisionsOneSec.m
% REV DATE: 5/17/2016
% Author: Osama Mansour

% Salem Battery Energy Storage System (BESS)
% This was developed to replicate & expand the 2014 Capstone script
% This was developed to replicate & expand the 2015 Capstone script
% clc; clear all;close all;
tic;
%% HEADING
% This section defines the header of the file.
fprintf('\nSALEM BATTERY ENERGY STORAGE SYSTEM (BESS):\n');

%% PV PROFILE SELECTION
% This section allows the user to select PV profile (percentage) to
% examine. The user is allowed to choose between 10-50% in inrements of 5%.

%% Salem PV Data Scaled to PV Penetration 

PV.profile = [10:5:50];
PV.profile = 0.01 * PV.profile;     % Change % to decimal

DataRaw.TailSize=900; %15min

PV.efficiency = 1;                 % 18% is typical efficiency of PV panels;
                      %   however, PV scaled to feeder size in this program
                      %   This is different from 2014 Capstone,
                      %   which utilized the 18%

%% FEEDER SIZE
% This section defines the average daily maximum size based on previous
% teams caluclations. The size that is used is 2.9457.
% LEAVE IN Extra avgDailyMax values, in case want to explore other
% scenarios.

%avgDailyMax = 2.7059;     % ALL DAYS - From BESS_AvgDailyMax.m (12 months)
%avgDailyMax = 2.1064;     % WEEKENDS - From BESS_AvgDailyMax.m (12 months)
DataRaw.avgDailyMax = 2.9457;      % WEEKDAYS - From BESS_AvgDailyMax.m (12 months)
DataRaw.feederSize = DataRaw.avgDailyMax;  % [MW] Feeder Size = avgDailyMax (nameplate)


%% LOAD FILES
% This section loads a year's worth of Salem PV one minute data from 2014
% from January to December.
% The Oxford  load data is one minute data from Jan to Dec of 2012.
% The Oahu PV data is pne second data from 5pm-8pm from April 2010 to March
% 2011. 

DataRaw.Salem=csvread('SalemPVYear.csv');
DataRaw.Oahu=csvread('OahuPVYear.csv');
DataRaw.Oxford=csvread('OXFD.csv');
DataRaw.SalemEnvelope=csvread('SalemPVEnvelopeNREL8to5.csv');
DataRaw.Oxford900=DataRaw.Oxford(300:1200,1:365);  %Data Set to be observed


%% CREATE TIME VECTOR

time.vector = (1:length(DataRaw.Oxford900))';       % Transpose
% Adjust time to match data range (54000)

% Time was expanded to match the original data
time.New = (1:(length(DataRaw.Oxford900)-1)*60)';   % Expand time x60 & transpose

% Adjust time for 15-hr period (1500)
time.Adj = time.New / 36;                 % Compress time to 15-hr period
                                        % (1500=54000/36)
time.t500 = time.Adj + 500;                % 54000 pts - Set start time to 5:00am
time.Entire = 1:86400;
time.Entire =time.Entire';

%% OXFORD DATA PROCESSED
% This section creates a new matrix that expands the original feeder data 
% from per-minute data to per-second data by repeating one value 60 times.
% This enables comparison of feeder load data to PV solar data, which is
% per-second data
% This also assumes that the load data is constant for 60 seconds (each
% minute)
 
x = 1;      %Column    
y=0;
interval = 0;
DataProc.Oxford54000= zeros;

while y < 365

    i = 1;      %Row
    k = 1;
    
while i < (length(time.New)+1)
  
  DataProc.Oxford54000(i,x) = DataRaw.Oxford900(k,x);
  
  if DataProc.Oxford54000(i,x) == 0 
      try
      DataProc.Oxford54000(i,x)= DataProc.Oxford54000(i-1,x);
      catch
      end
  end
  
  
  i = i + 1;
  
  if interval==60                       % Interval=floor(54000/900)
    k = k + 1;                          %   (900 load data pts)
    interval = 0;                       % This effectively interpolates
  else                                  %   each minute value over 60 sec
    interval = interval + 1;
  end %if interval==60
  
  
end %while i < (length(timeNew)+1)


y=y+1;
x=x+1;

end

%% Maximum Load
% Calculate max load & normalize load data
DataProc.Oxford54000Max = max(DataProc.Oxford54000);

y=1;
%DataProc.Oxford54000Normalized=zeros;
while y <365 +1
 
    DataProc.Oxford54000Normalized(:,y) = DataProc.Oxford54000(:,y) / DataProc.Oxford54000Max(1,y);
    y=y+1;

end

CHECK.maxNormalLoad.Oxford = max(DataProc.Oxford54000Normalized);   % CHECK: = 1?

% Scaled load data
DataProc.Oxford54000Scaled = DataProc.Oxford54000Normalized * DataRaw.feederSize;
CHECK.maxScaledLoad.Oxford = max(DataProc.Oxford54000Scaled);   %  CHECK: = avgDailyMax=2.9457?


%% OXFORD ENTIRE LOAD


%   CONVERT LOAD FROM 15-HOUR TO ENTIRE 24-HR SCALE
%   This section creates a new matrix that expands the original feeder data 
%   from per-minute data to per-second data by repeating one value 60 times
%   This enables comparison of feeder load data to PV solar data, which is
%   per-second data
%   This also assumes that the load data is constant for 60 seconds (each
%   minute)

x = 1;      %Column    
y=0;
interval = 0;
DataProc.Oxford86400= zeros;

while y < 365

    i = 1;      %Row
    k = 1;
    
while i < (length(time.Entire)+1)
  
  DataProc.Oxford86400(i,x) = DataRaw.Oxford(k,x);
  
  i = i + 1;
  
  if interval==60                       % Interval=floor(54000/900)
    k = k + 1;                       %   (900 load data pts)
    interval = 0;                       % This effectively interpolates
  else                                  %   each minute value over 60 sec
    interval = interval + 1;
  end %if interval==60
  
  
end %while i < (length(timeNew)+1)


y=y+1;
x=x+1;

end

DataProc.Oxford86400_Max = max(DataProc.Oxford86400);


y=1;
   % DataProc.Oxford86400_Normalized=zeros;
while y<365 +1
   
    DataProc.Oxford86400_Normalized(:,y)= DataProc.Oxford86400(:,y) / DataProc.Oxford86400_Max(:,y) ;
    
    y=y+1;

end


CHECK.DataProc.Oxford86400_Normalizedmax=max(DataProc.Oxford86400_Normalized);  % Check=1; YAY!

DataProc.OxfordScaled = DataProc.Oxford86400_Normalized * DataRaw.feederSize;
CHECK.OxfordScaledMax=max(DataProc.OxfordScaled); %Check=2.9457; YAY!;

%%

figure;plot(time.Entire,DataProc.Oxford86400_Normalized(:,5))

%% OAHU DATA PROCESSED
% Data Range corresponds to points from 5am to 8pm
% Data Points are 1 SECOND apart
% OAHU Data @ 1-sec interval
% NOTE: This facility no longer exists (Apr 14, 2015)

% Scale & convert
% PV data scaled according to typical percentage for efficiency (18%)
% Negative factor because PV subtracts from load

DataProc.Oahu = DataRaw.Oahu(1:54000,1:365) * -PV.efficiency / 1000; % Change to MW

DataProc.Oahumax= max(DataProc.Oahu);
%DataProc.OahuEnvelope=zeros;
y=1;
while y < 365+1
    DataProc.OahuEnvelope(:,y)= PVenvelopeV2(time.New,DataProc.Oahu(:,y) );
    y=y+1;
end 
DataProc.OahuFluct = DataProc.Oahu - DataProc.OahuEnvelope;


DataProc.OahuFluctmaxi = max(DataProc.OahuFluct);

y=1;
%DataProc.OahuNormalized=zeros;
while y < 365+1
    
    DataProc.OahuNormalized(:,y) = DataProc.OahuFluct(:,y) / DataProc.OahuFluctmaxi(:,y);
y=y+1;
end

% Calculated fluctuation of Oahu data
DataProc.OahuFluct = DataProc.Oahu - DataProc.OahuEnvelope;

DataProc.OahuScaleFactor = DataProc.OahuFluctmaxi / (DataProc.Oahumax*PV.efficiency/1000);

DataProc.OahuAdjustedPV = DataProc.OahuFluct * DataProc.OahuScaleFactor;

%% SALEM DATA PROCESSED
% Data Range corresponds to points from 5am to 8pm
% Data Points are 1 MINUTES apart

DataRaw.Salem58=DataRaw.Salem(300:1080,:);    % Extract 5AM-8PM from original file 
x = 1;      %Column    
y=0;
interval = 0;
%DataProc.Salem= zeros;

while y < 365

    i = 1;      %Row
    k = 1;
    
while i < (length(time.New)+1)
  
  DataProc.Salem(i,x) = DataRaw.Salem58(k,x);
 
  i = i + 1;

  if interval==69                       % Interval=floor(54000/900)
    k = k + 1;                          %   (900 load data pts)
    interval = 0;                       % This effectively interpolates
  else                                  %   each minute value over 60 sec
    interval = interval + 1;
  end %if interval==60
  
end %while i < (length(timeNew)+1)

y=y+1;
x=x+1;

end

DataProc.SalemScaled= DataProc.Salem * -PV.efficiency / 1000;

%%
DataProc.SalemPVmax = min(DataProc.SalemScaled);
y=1;
i=1;
%DataProc.SalemNormalized=zeros;
while y <365+1
    
    
DataProc.SalemNormalized(:,y) = DataProc.SalemScaled(:,y) / abs(DataProc.SalemPVmax(1,y));

y=y+1;
end

%%
% CHECK.maxNEGNormalExpandedORPV = min(DataProc.SalemNormalized);    % CHECK: = -1?
% 
% figure;plot(time.New,DataProc.SalemNormalized(:,5))


%% SALEM ENVELOPE
 DataProc.SalemEnvelope=zeros(54000,365);
 
x=1;  
y=1;
interval = 0;
while y < 365 +1 

    i=1;
    k=1;

    while i < length(time.New) +1 
        DataProc.SalemEnvelope(i,x) = DataRaw.SalemEnvelope(k,x);
        i=i+1;
    
                if interval > 298                       % Interval=floor(54000/900)
                        k = k + 1;                          %   (900 load data pts)
                        interval = 0;                       % This effectively interpolates
                else                                  %   each minute value over 60 sec
                        interval = interval + 1;
                end %if interval==60
    
     
    end 
  
    x=x+1;
    y=y+1;
    
end


%% Salem Envelope Shifted
DataProc.SalemEnvShift=zeros(54000,365);
k=1;
for i= 3600:54000;
DataProc.SalemEnvShift(i,:)= DataProc.SalemEnvelope(k,:);
k=k+1;
end
DataProc.SalemEnvelope=-DataProc.SalemEnvShift;

%% SALEM ENVELOPE NORMALIZED
DataProc.SalemEnvMax = min ( DataProc.SalemEnvelope);
y=1;
i=1;

while y < 366
    
    DataProc.SalemEnvNorm(:,y) = (DataProc.SalemEnvelope(:,y) / abs (DataProc.SalemEnvMax(1,y)));
    y=y+1;
end

CHECK.maxSalemEnv= min(DataProc.SalemEnvNorm);



%% OVERLAY OAHU DATA AND SALEM V.1
% %  

y=1; %day looking at
while y < 365+1
    x=1:60;
    t=1;
             while t <901

               DataProc.OahuMean_60(x,y)=mean(DataProc.Oahu(x,y));
                x=x+60;
                t=t+1;
            end
y=y+1;
end
 


DataProc.OahuDiff_60= -(DataProc.Oahu - DataProc.OahuMean_60) ./ DataProc.OahuMean_60;

DataProc.OahuDiff_60(isinf(DataProc.OahuDiff_60))=0.00;
DataProc.OahuDiff_60(isnan(DataProc.OahuDiff_60))=0.00;


y=1;
while y < 365+1 

    x=1;
    while x < 54001
    
        if DataProc.OahuDiff_60(x,y) < -1
            DataProc.OahuDiff_60(x,y) =0;
        elseif DataProc.OahuDiff_60(x,y) > 1
            DataProc.OahuDiff_60(x,y)=0;
        end
    
    x=x+1;
    end

y=y+1;



end

%%

    DataProc.SalemOsama= (DataProc.SalemNormalized .* -DataProc.OahuDiff_60) + DataProc.SalemNormalized;

% DataProc.SalemOsama(isinf(DataProc.SalemOsama))=0;
% DataProc.SalemOsama(isnan(DataProc.SalemOsama))=0;


%%
y=1;

while y<366
    x=1;

    while x<54001
    
        if DataProc.SalemOsama(x,y) < DataProc.SalemEnvNorm(x,y) && DataProc.SalemNormalized(x,y) > DataProc.SalemEnvNorm(x,y)
                DataProc.SalemOsama(x,y) = DataProc.SalemEnvNorm(x,y);
    
        elseif DataProc.SalemNormalized(x,y) < DataProc.SalemEnvNorm(x,y) && 100 * ((DataProc.SalemNormalized(x,y) - DataProc.SalemEnvNorm(x,y)) / DataProc.SalemEnvNorm(x,y)) < 20
                DataProc.SalemOsama(x,y) = DataProc.SalemNormalized(x,y);
    
        elseif DataProc.SalemNormalized(x,y) > DataProc.SalemEnvNorm(x,y) && -100* ((DataProc.SalemNormalized(x,y) - DataProc.SalemEnvNorm(x,y)) / DataProc.SalemEnvNorm(x,y)) < 20
                DataProc.SalemOsama(x,y) = DataProc.SalemNormalized(x,y);
        
        elseif abs(DataProc.SalemOsama(x,y)) > 1
                DataProc.SalemOsama(x,y) = -1;
        end
    
    x=x+1;
    end
    
    y=y+1;

end




%% PV + Load: Part 1

DataProc.SalemScaledd(1:17999,1:365)=zeros;
DataProc.SalemScaledd(18000:(72000-1),1:365)=DataProc.SalemOsama;
DataProc.SalemScaledd(72000:86400,1:365)=zeros;


% % 
% % CHECK.DataProc.Oxford86400_Normalizedmax=max(DataProc.Oxford86400_Normalized);  % Check=1; YAY!
% % 
% % DataProc.OxfordScaled = DataProc.Oxford86400_Normalized * DataRaw.feederSize;
% % CHECK.OxfordScaledMax=max(DataProc.OxfordScaled); %Check=2.9457; YAY!;

%DataProc.SalemScaledd = DataProc.SalemScaledd .* DataRaw.feederSize;
% DataProc.SalemScaledd = DataProc.SalemScaledd .* PV.profile;

%%
DataProc.SalemNormalized=-DataProc.SalemScaledd;

%% Salem PV with different Penetrations

y=1;
while y <366 
    
DataProc.SalemPVpen.P1= DataProc.SalemNormalized .* PV.profile(1) .* DataProc.Oxford86400(1,y);

DataProc.SalemPVpen.P2= DataProc.SalemNormalized .* PV.profile(2).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P3= DataProc.SalemNormalized .* PV.profile(3).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P4= DataProc.SalemNormalized .* PV.profile(4).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P5= DataProc.SalemNormalized .* PV.profile(5).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P6= DataProc.SalemNormalized .* PV.profile(6).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P7= DataProc.SalemNormalized .* PV.profile(7).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P8= DataProc.SalemNormalized .* PV.profile(8).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P9= DataProc.SalemNormalized .* PV.profile(9).* DataProc.Oxford86400(1,y);
DataProc.SalemPVpen.P90= DataProc.SalemNormalized .* 0.9 .* DataProc.Oxford86400(1,y);

y=y+1;
end
clear y
% % % % % 



%%
% % % DataRaw.Day=21;close all;
% % %  plot(time.Entire/3600, DataProc.SalemPVpen.P9(:,DataRaw.Day));

% bar(DataProc.Oxford86400)
%% PV plus Load

DataProc.PVplusLoad.P1 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P1;
DataProc.PVplusLoad.P2 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P2;
DataProc.PVplusLoad.P3 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P3;
DataProc.PVplusLoad.P4 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P4;
DataProc.PVplusLoad.P5 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P5;
DataProc.PVplusLoad.P6 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P6;
DataProc.PVplusLoad.P7 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P7;
DataProc.PVplusLoad.P8 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P8;
DataProc.PVplusLoad.P9 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P9;
DataProc.PVplusLoad.P90 =  DataProc.Oxford86400_Normalized - DataProc.SalemPVpen.P90;
%%

% % % % % 
% % % % % 
%% Flat DFP
y=1;
while y <366
FlatDFP.P1(1:86400,y) = mean(DataProc.PVplusLoad.P1(:,y));
FlatDFP.P2(1:86400,y) = mean(DataProc.PVplusLoad.P2(:,y));
FlatDFP.P3(1:86400,y) = mean(DataProc.PVplusLoad.P3(:,y));
FlatDFP.P4(1:86400,y) = mean(DataProc.PVplusLoad.P4(:,y));
FlatDFP.P5(1:86400,y) = mean(DataProc.PVplusLoad.P5(:,y));
FlatDFP.P6(1:86400,y) = mean(DataProc.PVplusLoad.P6(:,y));
FlatDFP.P7(1:86400,y) = mean(DataProc.PVplusLoad.P7(:,y));
FlatDFP.P8(1:86400,y) = mean(DataProc.PVplusLoad.P8(:,y));
FlatDFP.P9(1:86400,y) = mean(DataProc.PVplusLoad.P9(:,y));
FlatDFP.P90(1:86400,y) = mean(DataProc.PVplusLoad.P90(:,y));
y=y+1;
end

%%
% % % % % %%
% % % % % % % 
% % % % % % figure;
% % % % % % 
% % % % % % DataRaw.Day=80;
% % % % % % plot(time.Entire/60, [DataProc.Oxford86400_Normalized(:,DataRaw.Day), DataProc.PVplusLoad.P1(:,DataRaw.Day), -DataProc.SalemPVpen.P1(:,DataRaw.Day),FlatDFP.P1(:,DataRaw.Day)])
% % % % % % hold on;
% % % % % % plot(time.Entire/60, [DataProc.PVplusLoad.P9(:,DataRaw.Day), -DataProc.SalemPVpen.P9(:,DataRaw.Day),FlatDFP.P9(:,DataRaw.Day)]   )
% % % % % % legend('Load', 'PV Plus Load 10%' , 'Salem PV 10% Pen','Flat 10%' , 'PV Plus Load 50%' , 'Salem PV 50% Pen', 'Flat 50%',  'Location','best')
% % % % % 
% % % % % 
%% Smooth15 Initite Variables

%%% Smoothed DFP
 Smooth15.Smoothed.P1=zeros(86400,365);     % Smoothed PV Plus Load 10%
 Smooth15.Smoothed.P2=zeros(86400,365);     % Smoothed PV Plus Load 15%
 Smooth15.Smoothed.P3=zeros(86400,365);     % Smoothed PV Plus Load 20%
 Smooth15.Smoothed.P4=zeros(86400,365);     % Smoothed PV Plus Load 25%
 Smooth15.Smoothed.P5=zeros(86400,365);     % Smoothed PV Plus Load 30%
 Smooth15.Smoothed.P6=zeros(86400,365);     % Smoothed PV Plus Load 35%
 Smooth15.Smoothed.P7=zeros(86400,365);     % Smoothed PV Plus Load 40%
 Smooth15.Smoothed.P8=zeros(86400,365);     % Smoothed PV Plus Load 45%
 Smooth15.Smoothed.P9=zeros(86400,365);     % Smoothed PV Plus Load 50%
 Smooth15.Smoothed.P90=zeros(86400,365);    % Smoothed PV Plus Load 90%
 
%%% MW Smoothed DFP
 Smooth15.MaxMWSmooth.P1=zeros(1,365);         % MW Smooth DFP 10%
 Smooth15.MaxMWSmooth.P2=zeros(1,365);         % MW Smooth DFP 15%
 Smooth15.MaxMWSmooth.P3=zeros(1,365);         % MW Smooth DFP 20%
 Smooth15.MaxMWSmooth.P4=zeros(1,365);         % MW Smooth DFP 25%
 Smooth15.MaxMWSmooth.P5=zeros(1,365);         % MW Smooth DFP 30%
 Smooth15.MaxMWSmooth.P6=zeros(1,365);         % MW Smooth DFP 35%
 Smooth15.MaxMWSmooth.P7=zeros(1,365);         % MW Smooth DFP 40%
 Smooth15.MaxMWSmooth.P8=zeros(1,365);         % MW Smooth DFP 45%
 Smooth15.MaxMWSmooth.P9=zeros(1,365);         % MW Smooth DFP 50%
 Smooth15.MaxMWSmooth.P90=zeros(1,365);        % MW Smooth DFP 90%
 
%%% MWhr Smoothed DFP
 Smooth15.MWhrSmooth.P1=zeros(1,365);          % MWhr Smooth DFP 10%
 Smooth15.MWhrSmooth.P2=zeros(1,365);          % MWhr Smooth DFP 15%
 Smooth15.MWhrSmooth.P3=zeros(1,365);          % MWhr Smooth DFP 20%
 Smooth15.MWhrSmooth.P4=zeros(1,365);          % MWhr Smooth DFP 25%
 Smooth15.MWhrSmooth.P5=zeros(1,365);          % MWhr Smooth DFP 30%
 Smooth15.MWhrSmooth.P6=zeros(1,365);          % MWhr Smooth DFP 35%
 Smooth15.MWhrSmooth.P7=zeros(1,365);          % MWhr Smooth DFP 40%
 Smooth15.MWhrSmooth.P8=zeros(1,365);          % MWhr Smooth DFP 45%
 Smooth15.MWhrSmooth.P9=zeros(1,365);          % MWhr Smooth DFP 50%
 Smooth15.MWhrSmooth.P90=zeros(1,365);         % MWhr Smooth DFP 90%
 
%%% MW Flat DFP  
 Smooth15.MaxMWFlat.P1=zeros(1,365);           % MW Flat DFP 10%
 Smooth15.MaxMWFlat.P2=zeros(1,365);           % MW Flat DFP 15%
 Smooth15.MaxMWFlat.P3=zeros(1,365);           % MW Flat DFP 20%
 Smooth15.MaxMWFlat.P4=zeros(1,365);           % MW Flat DFP 25%
 Smooth15.MaxMWFlat.P5=zeros(1,365);           % MW Flat DFP 30%
 Smooth15.MaxMWFlat.P6=zeros(1,365);           % MW Flat DFP 35%
 Smooth15.MaxMWFlat.P7=zeros(1,365);           % MW Flat DFP 40%
 Smooth15.MaxMWFlat.P8=zeros(1,365);           % MW Flat DFP 45%
 Smooth15.MaxMWFlat.P9=zeros(1,365);           % MW Flat DFP 50%
 Smooth15.MaxMWFlat.P90=zeros(1,365);          % MW Flat DFP 900%
 
%%% MW Flat DFP  
 Smooth15.MWhrFlat.P1=zeros(1,365);            % MWhr Flat DFP 10%
 Smooth15.MWhrFlat.P2=zeros(1,365);            % MWhr Flat DFP 15%
 Smooth15.MWhrFlat.P3=zeros(1,365);            % MWhr Flat DFP 20%
 Smooth15.MWhrFlat.P4=zeros(1,365);            % MWhr Flat DFP 25%
 Smooth15.MWhrFlat.P5=zeros(1,365);            % MWhr Flat DFP 30%
 Smooth15.MWhrFlat.P6=zeros(1,365);            % MWhr Flat DFP 35%
 Smooth15.MWhrFlat.P7=zeros(1,365);            % MWhr Flat DFP 40%
 Smooth15.MWhrFlat.P8=zeros(1,365);            % MWhr Flat DFP 45%
 Smooth15.MWhrFlat.P9=zeros(1,365);            % MWhr Flat DFP 50%
 Smooth15.MWhrFlat.P90=zeros(1,365);           % MWhr Flat DFP 90%
 
%%% Reference Line Smooth DFP
 Smooth15.BESSrefLine.P1 =zeros(86400,365);     % Reference Line Smooth 10%
 Smooth15.BESSrefLine.P2 =zeros(86400,365);     % Reference Line Smooth 15%
 Smooth15.BESSrefLine.P3 =zeros(86400,365);     % Reference Line Smooth 20%
 Smooth15.BESSrefLine.P4 =zeros(86400,365);     % Reference Line Smooth 25%
 Smooth15.BESSrefLine.P5 =zeros(86400,365);     % Reference Line Smooth 30%
 Smooth15.BESSrefLine.P6 =zeros(86400,365);     % Reference Line Smooth 35%
 Smooth15.BESSrefLine.P7 =zeros(86400,365);     % Reference Line Smooth 40%
 Smooth15.BESSrefLine.P8 =zeros(86400,365);     % Reference Line Smooth 45%
 Smooth15.BESSrefLine.P9 =zeros(86400,365);     % Reference Line Smooth 50%
 Smooth15.BESSrefLine.P90 =zeros(86400,365);     % Reference Line Smooth 90%

 %% Run Smoothing Function 
 % calculates MW MWhr - Smooth and Flat
 % 15 min
tail=15;  
 
tic;
 for y=1:365;
  tic;
[Smooth15.Smoothed.P1(:,y), Smooth15.MaxMWSmooth.P1(:,y), Smooth15.MWhrSmooth.P1(:,y),  Smooth15.MaxMWFlat.P1(:,y) ,  Smooth15.MWhrFlat.P1(:,y) ,  Smooth15.BESSrefLine.P1(:,y)] = PolySama3( DataProc.PVplusLoad.P1(:,y), FlatDFP.P1(1:86400,y) ,tail);
[Smooth15.Smoothed.P2(:,y), Smooth15.MaxMWSmooth.P2(:,y), Smooth15.MWhrSmooth.P2(:,y),  Smooth15.MaxMWFlat.P2(:,y) ,  Smooth15.MWhrFlat.P2(:,y) ,  Smooth15.BESSrefLine.P2(:,y)] = PolySama3( DataProc.PVplusLoad.P2(:,y), FlatDFP.P2(1:86400,y) ,tail);
[Smooth15.Smoothed.P3(:,y), Smooth15.MaxMWSmooth.P3(:,y), Smooth15.MWhrSmooth.P3(:,y),  Smooth15.MaxMWFlat.P3(:,y) ,  Smooth15.MWhrFlat.P3(:,y) ,  Smooth15.BESSrefLine.P3(:,y)] = PolySama3( DataProc.PVplusLoad.P3(:,y), FlatDFP.P3(1:86400,y) ,tail);
[Smooth15.Smoothed.P4(:,y), Smooth15.MaxMWSmooth.P4(:,y), Smooth15.MWhrSmooth.P4(:,y),  Smooth15.MaxMWFlat.P4(:,y) ,  Smooth15.MWhrFlat.P4(:,y) ,  Smooth15.BESSrefLine.P4(:,y)] = PolySama3( DataProc.PVplusLoad.P4(:,y), FlatDFP.P4(1:86400,y) ,tail);
[Smooth15.Smoothed.P5(:,y), Smooth15.MaxMWSmooth.P5(:,y), Smooth15.MWhrSmooth.P5(:,y),  Smooth15.MaxMWFlat.P5(:,y) ,  Smooth15.MWhrFlat.P5(:,y) ,  Smooth15.BESSrefLine.P5(:,y)] = PolySama3( DataProc.PVplusLoad.P5(:,y), FlatDFP.P5(1:86400,y) ,tail);
[Smooth15.Smoothed.P6(:,y), Smooth15.MaxMWSmooth.P6(:,y), Smooth15.MWhrSmooth.P6(:,y),  Smooth15.MaxMWFlat.P6(:,y) ,  Smooth15.MWhrFlat.P6(:,y) ,  Smooth15.BESSrefLine.P6(:,y)] = PolySama3( DataProc.PVplusLoad.P6(:,y), FlatDFP.P6(1:86400,y) ,tail);
[Smooth15.Smoothed.P7(:,y), Smooth15.MaxMWSmooth.P7(:,y), Smooth15.MWhrSmooth.P7(:,y),  Smooth15.MaxMWFlat.P7(:,y) ,  Smooth15.MWhrFlat.P7(:,y) ,  Smooth15.BESSrefLine.P7(:,y)] = PolySama3( DataProc.PVplusLoad.P7(:,y), FlatDFP.P7(1:86400,y) ,tail);
[Smooth15.Smoothed.P8(:,y), Smooth15.MaxMWSmooth.P8(:,y), Smooth15.MWhrSmooth.P8(:,y),  Smooth15.MaxMWFlat.P8(:,y) ,  Smooth15.MWhrFlat.P8(:,y) ,  Smooth15.BESSrefLine.P8(:,y)] = PolySama3( DataProc.PVplusLoad.P8(:,y), FlatDFP.P8(1:86400,y) ,tail);
[Smooth15.Smoothed.P9(:,y), Smooth15.MaxMWSmooth.P9(:,y), Smooth15.MWhrSmooth.P9(:,y),  Smooth15.MaxMWFlat.P9(:,y) ,  Smooth15.MWhrFlat.P9(:,y) ,  Smooth15.BESSrefLine.P9(:,y)] = PolySama3( DataProc.PVplusLoad.P9(:,y), FlatDFP.P9(1:86400,y) ,tail);
[Smooth15.Smoothed.P90(:,y), Smooth15.MaxMWSmooth.P90(:,y), Smooth15.MWhrSmooth.P90(:,y),  Smooth15.MaxMWFlat.P90(:,y) ,  Smooth15.MWhrFlat.P90(:,y) ,  Smooth15.BESSrefLine.P90(:,y)] = PolySama3( DataProc.PVplusLoad.P90(:,y), FlatDFP.P90(1:86400,y) ,tail);

toc;

 end
 toc;
%%
%% Scale Normalization 
%%%%%%%%%%%%%%%%%%%%%%%%% SMOOTH15 MIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scaled.Smooth15.MaxMWSmooth.P1 =  Smooth15.MaxMWSmooth.P1 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P1  =  Smooth15.MWhrSmooth.P1  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P1   =  Smooth15.MaxMWFlat.P1   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P1    =  Smooth15.MWhrFlat.P1    .* DataProc.Oxford86400_Max;


Scaled.Smooth15.MaxMWSmooth.P2 =  Smooth15.MaxMWSmooth.P2 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P2  =  Smooth15.MWhrSmooth.P2  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P2   =  Smooth15.MaxMWFlat.P2   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P2    =  Smooth15.MWhrFlat.P2    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P3 =  Smooth15.MaxMWSmooth.P3 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P3  =  Smooth15.MWhrSmooth.P3  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P3   =  Smooth15.MaxMWFlat.P3   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P3    =  Smooth15.MWhrFlat.P3    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P4 =  Smooth15.MaxMWSmooth.P4 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P4  =  Smooth15.MWhrSmooth.P4  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P4   =  Smooth15.MaxMWFlat.P4   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P4    =  Smooth15.MWhrFlat.P4    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P5 =  Smooth15.MaxMWSmooth.P5 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P5  =  Smooth15.MWhrSmooth.P5  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P5   =  Smooth15.MaxMWFlat.P5   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P5    =  Smooth15.MWhrFlat.P5    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P6 =  Smooth15.MaxMWSmooth.P6 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P6  =  Smooth15.MWhrSmooth.P6  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P6   =  Smooth15.MaxMWFlat.P6   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P6    =  Smooth15.MWhrFlat.P6    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P7 =  Smooth15.MaxMWSmooth.P7 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P7  =  Smooth15.MWhrSmooth.P7  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P7   =  Smooth15.MaxMWFlat.P7   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P7    =  Smooth15.MWhrFlat.P7    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P8 =  Smooth15.MaxMWSmooth.P8 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P8  =  Smooth15.MWhrSmooth.P8  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P8   =  Smooth15.MaxMWFlat.P8   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P8    =  Smooth15.MWhrFlat.P8    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P9 =  Smooth15.MaxMWSmooth.P9 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P9  =  Smooth15.MWhrSmooth.P9  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P9   =  Smooth15.MaxMWFlat.P9   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P9    =  Smooth15.MWhrFlat.P9    .* DataProc.Oxford86400_Max;

Scaled.Smooth15.MaxMWSmooth.P90 =  Smooth15.MaxMWSmooth.P90 .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrSmooth.P90  =  Smooth15.MWhrSmooth.P90  .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MaxMWFlat.P90   =  Smooth15.MaxMWFlat.P90   .* DataProc.Oxford86400_Max;
Scaled.Smooth15.MWhrFlat.P90    =  Smooth15.MWhrFlat.P90    .* DataProc.Oxford86400_Max;
%%

for y= 1:365
Scaled.FlatDFP.P1(1,y) = FlatDFP.P1(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P2(1,y) = FlatDFP.P2(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P3(1,y) = FlatDFP.P3(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P4(1,y) = FlatDFP.P4(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P5(1,y) = FlatDFP.P5(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P6(1,y) = FlatDFP.P6(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P7(1,y) = FlatDFP.P7(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P8(1,y) = FlatDFP.P8(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P9(1,y) = FlatDFP.P9(1,y) .* DataProc.Oxford86400_Max(1,y) ;
Scaled.FlatDFP.P90(1,y) = FlatDFP.P90(1,y) .* DataProc.Oxford86400_Max(1,y) ;

end



%save('Y:\Research\Osama\Revisions\OneSecFlatDFP\Revisions_BESS_OneSec_ScaledSmooth15.mat','Scaled','-v7.3')