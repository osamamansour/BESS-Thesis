% NAME:     BESS_OsamaSummer.m
% REV DATE: 22 Jul 2015
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

PV.profile = 35;
DataRaw.TailSize=3600; %15min

% PVprofile = 0;
% fprintf('\nAVAILABLE PV PROFILES: 10%% to 50%%, in increments of 5%%\n');
% while(PVprofile~=10 && PVprofile~=15 && PVprofile~=20 ...
%       && PVprofile~=25 && PVprofile~=30 && PVprofile~=DataRaw.Day ...
%       && PVprofile~=40 && PVprofile~=DataRaw.Day && PVprofile~=50 ...
%       && PVprofile~=27)  % Last value is for testing
%   PVprofile = input('\Enter the desired PV profile percentage (10-50): ');
%   if(PVprofile~=10 && PVprofile~=15 && PVprofile~=20 ...
%       && PVprofile~=25 && PVprofile~=30 && PVprofile~=DataRaw.Day ...
%       && PVprofile~=40 && PVprofile~=DataRaw.Day && PVprofile~=50 ...
%       && PVprofile~=27)  % Last value is for testing
%     fprintf('\n** Please choose one: 10/15/20/25/30/DataRaw.Day/40/DataRaw.Day/50 **\n');
%   end
% end
% %fprintf('\nSELECTED PV PROFILE IS %d%%.\nAll calculations & plots are based on this value.\n',...
% %  PVprofile);

PV.profile = 0.01 * PV.profile;     % Change % to decimal
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
%feederSize = 10;          % [MW] Feeder Size = 10 MW (nameplate)

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

% % % % %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&EXPLAIN!!
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
  
  
%   if DataProc.Oxford86400(i,x) == 0 
%       try
%       DataProc.Oxford86400(i,x)= DataProc.Oxford86400(i-1,x);
%       catch
%       end
%   end
%   
%   
  
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


% y=1;
% while y < 365+1
%     DataProc.OahuEnvelopeNorm(:,y)= PVenvelopeV2(time.New,DataProc.OahuNormalized(:,y) );
%     y=y+1;
% end 

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
CHECK.maxNEGNormalExpandedORPV = min(DataProc.SalemNormalized);    % CHECK: = -1?

figure;plot(time.New,DataProc.SalemNormalized(:,5))


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

% DatProc.SalemEnvShift(50402:54000,:)= zeros(3599,365);

% 
% for i = 50402:54000;
%     DataProc.SalemEnvShift(i,:)= 0;
% end



%%
DataProc.SalemEnvelope=-DataProc.SalemEnvShift;


%%
%figure;plot(time.New,DataProc.SalemEnvelope(:,5))
%%
%hold on
%plot(time.New,DataProc.SalemEnvelope(:,170))


%% SALEM ENVELOPE NORMALIZED


DataProc.SalemEnvMax = max ( DataProc.SalemEnvelope);
y=1;
i=1;


while y < 366
    
    DataProc.SalemEnvNorm(:,y) = (DataProc.SalemEnvelope(:,y) / abs (DataProc.SalemEnvMax(1,y)));
    y=y+1;
end


CHECK.maxSalemEnv= max(DataProc.SalemEnvNorm);

%%  start edit


% x = 1;      %Column    
% y=0;
% interval = 0;
% DataProc.Env86400= zeros;
% 
% while y < 365
% 
%     i = 1;      %Row
%     k = 1;
%     
% while i < (length(time.Entire)+1)
%   
%   DataProc.Env86400(i,x) = DataProc.SalemEnvNorm(k,x);
%   
%   i = i + 1;
%   
%   if interval==60                       % Interval=floor(54000/900)
%     k = k + 1;                          %   (900 load data pts)
%     interval = 0;                       % This effectively interpolates
%   else                                  %   each minute value over 60 sec
%     interval = interval + 1;
%   end %if interval==60
%   
%   
% end %while i < (length(timeNew)+1)
% 
% 
% y=y+1;
% x=x+1;
% 
% end
% 
% DataProc.Env86400_Max = max(DataProc.Env86400);
% 


 
 % % % % % % y=1;
% % % % % % %DataProc.SalemEnvelope=zeros;
% % % % % % while y < 366+1
% % % % % % 
% % % % % % try 
% % % % % % DataProc.SalemEnvelope(:,y) = PVenvelopeV2(time.New,DataProc.SalemNormalized(:,y) );
% % % % % % 
% % % % % % catch
% % % % % %     %continue
% % % % % % end 
% % % % % %  y=y+1;
% % % % % % end



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
% if DataProc.SalemNormalized  > DataProc.SalemEnvNorm
    DataProc.SalemOsama= (DataProc.SalemNormalized .* -DataProc.OahuDiff_60) + DataProc.SalemNormalized;
% else
% for y=1:365
%  for x =1:54000
% % if DataProc.SalemNormalized(x,y) < DataProc.SalemEnvNorm(x,y) && 100 * ((DataProc.SalemNormalized(x,y) - DataProc.SalemEnvNorm(x,y)) / DataProc.SalemEnvNorm(x,y)) < 20
% %      DataProc.SalemOsama(x,y) = DataProc.SalemNormalized(x,y);
% 
% 
% if -100* ((DataProc.SalemNormalized(x,y) - DataProc.SalemEnvNorm(x,y)) / DataProc.SalemEnvNorm(x,y)) < 20
%     DataProc.SalemOsama(x,y) = DataProc.SalemNormalized(x,y);
%     
% end
% end
% end

DataProc.SalemOsama(isinf(DataProc.SalemOsama))=0;
DataProc.SalemOsama(isnan(DataProc.SalemOsama))=0;


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
DataProc.SalemScaledd = DataProc.SalemScaledd .* PV.profile;

DataProc.PVplusLoad =  DataProc.Oxford86400_Normalized + DataProc.SalemScaledd;



y=1;

while y < 366
   
    x=1;

    while x<54001
        try
        if DataProc.PVplusLoad(x,y) == 0;
            DataProc.PVplusLoad(x,y) = NaN;
        end
                catch
        end
        x=x+1;


    end
    y=y+1;
end


%% Plotting Evil

DataRaw.Day=335;
% 
% 
figure(1)
plot(time.New/3600, [DataProc.SalemEnvNorm(:,DataRaw.Day) DataProc.SalemNormalized(:,DataRaw.Day)]);
%plot(time.Entire, [-DataProc.SalemEnvelope(:,DataRaw.Day) ]);%DataProc.SalemNormalized(:,DataRaw.Day)]);
%  
% EnvPlotTitle = sprintf('Combined Plots: Day %d with PV Profile = %.0d%%',DataRaw.Day, 100*PV.profile);
%   title(EnvPlotTitle,'fontweight','bold');
% legend('Expanded Feeder Load (Oxford)','PV with Fluctuation (Oregon)','PV + Load',...
%    '1800-pt Polyfit (PV + Load)','BESS Reference Signal', 'BESS Output','location','eastoutside');  
% % legend('Expanded Feeder Load (Oxford)','PV with Fluctuation (Oregon)','PV + Load','1800-pt Polyfit (PV + Load)','BESS Reference Signal', 'BESS Output','location','east');
%   set(0,'DefaultAxesFontName', 'Times New Roman')
%   xlabel('Time of Day  [24-hr clock]');
%   ylabel('Power  [MW]');
%   set(findall(gcf,'type','text'),'FontSize',30,'fontWeight','bold');
%   xlim([8 17]);
%   ylim([-1.1 1.1]);
%   ylim([(-DataRaw.feederSize*0.55) (DataRaw.feederSize*1.1)]);
%   set(gca,'xTick',0:4:24);
%   grid on;
%   hold off;




figure(3)
 plot(time.New, [DataProc.OahuEnvelope(:,DataRaw.Day) -DataProc.OahuNormalized(:,DataRaw.Day)]);

figure(2)
plot(time.New/3600, [DataProc.SalemEnvNorm(:,DataRaw.Day) DataProc.SalemOsama(:,DataRaw.Day)]);



figure(4)
plot(time.Entire, [DataProc.Oxford86400_Normalized(:,DataRaw.Day) DataProc.PVplusLoad(:,DataRaw.Day) DataProc.SalemScaledd(:,DataRaw.Day)]);

%DataProc.SalemScaledd

%% PV Plus Load: Part 2
% Smoothing 


 DataProc.Smoothed=zeros(86400,365);
 DataProc.MaxMW=zeros(1,365);
 DataProc.MWhr=zeros(1,365);
 DataProc.BESSrefLine =zeros(86400,365);
 DataProc.BESSapprox=zeros(86400,365);
 
 
 %%
 for y=1:365;
% try   
[DataProc.Smoothed(:,y), DataProc.MaxMW(1,y), DataProc.BESSrefLine(:,y), DataProc.BESSapprox(:,y) , DataProc.MWhr(1,y)] = PolySama(DataProc.PVplusLoad(:,y), DataRaw.TailSize);
fprintf('Day %d', y);
%  catch 
%      fprintf('\n\n\nERRRRRRORRRRRR!!!!!!!!!!!! %d\n\n\n',y);
 %end
 end
%  
%  
 %% Save Data
 DataSave.PVplusLoad=DataProc.PVplusLoad;
 DataSave.Smoothed=DataProc.Smoothed;
 DataSave.MaxMW=DataProc.MaxMW;
 DataSave.MWhr=DataProc.MWhr;
 DataSave.BESSrefLine=DataProc.BESSrefLine;
 DataSave.BESSapprox=DataProc.BESSapprox;
 
% save('Y:\Research\Osama\Smooth60\50p3600tail_Oct.mat','DataSave', '-v7.3')
 
 

 
 
 
 %% Scale Up
 
 
 
 
 
%  MWhr = DataProc.MWhr * DataRaw.feederSize;
%  MW = DataRaw.feederSize * DataProc.MaxMW;
%  
 
 
 
 %% SALEM + OAHU SUPERIMPOSED
% % % Superimpose Oahu fluctuation on Oregon PV data

% % % The fluctuation starts at different points, depending on the season
% % % The starting point is determined from the start of Oregon PV fluctuation

% % % % % % % % % % % % % % % % % % % % % % % % % 
DataRaw.Day=274;
% % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % THE PLOT OF ALL PLOTS
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
f10=figure (10);
plot(time.Entire/3600,DataProc.Oxford86400_Normalized(:,DataRaw.Day),'b','linewidth',1.25);
hold on;
plot(time.Entire/3600,DataProc.SalemScaledd(:,DataRaw.Day),'r','linewidth',1.25);
plot(time.Entire/3600,DataProc.PVplusLoad(:,DataRaw.Day),'g','linewidth',1.25);     % Summed PV & Load Data
plot(time.Entire/3600,DataProc.Smoothed(:,DataRaw.Day),'m--','linewidth',1.5);   % 2014 Capstone Polyfit Curve
%plot(time.Entire/3600,DataProc.Smoothed(:,DataRaw.Day),'b-.','linewidth',1.5);   % Target
plot(time.Entire/3600,DataProc.BESSrefLine(:,DataRaw.Day),'y','linewidth',2.5);  % BESS reference line
plot(time.Entire/3600,DataProc.BESSrefLine(:,DataRaw.Day),'k','linewidth',1.5);
plot(time.Entire/3600,DataProc.BESSapprox(:,DataRaw.Day),'g','linewidth',1);
  combinedPlotTitle = sprintf('Combined Plots: Day %d with PV Profile = %.0d%%',DataRaw.Day, 100*PV.profile);
  title(combinedPlotTitle,'fontweight','bold');
%legend('Expanded Feeder Load (Oxford)','PV with Fluctuation (Oregon)','PV + Load',...
 %  '1800-pt Polyfit (PV + Load)','BESS Reference Signal', 'BESS Output','location','eastoutside');  
% legend('Expanded Feeder Load (Oxford)','PV with Fluctuation (Oregon)','PV + Load','1800-pt Polyfit (PV + Load)','BESS Reference Signal', 'BESS Output','location','east');
  set(0,'DefaultAxesFontName', 'Times New Roman')
  xlabel('Time of Day  [24-hr clock]');
  ylabel('Power  [MW]');
  set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');
  xlim([0 24]);
  ylim([-0.5 1.1]);
  %ylim([(-DataRaw.feederSize*0.55) (DataRaw.feederSize*1.1)]);
  set(gca,'xTick',0:4:24);
  grid on;
  hold off;
  
   %saveas(f10, fullfile('Y:\Research\Osama\Thesis_images\PlotofAllplots'),'png');
   % saveas(f10, fullfile('Y:\Research\Osama\Thesis_images\PlotofAllplots'),'eps');
    
  
  
  
% % 
% % %%
% % %normalOahuPVfluctuation=zeros;
% % %y=1;
% % % 
% % % while y < 365+1   
% % %     
% % %     normalOahuPVfluctuation(:,y) = DataProc.OahuFluct(:,y) ./ maxOahuPVfluctuation(1,y);
% % %     y=y+1;
% % %     
% % % end
% % % CHECK.maxNormalLoad.Oahu = max(normalOahuPVfluctuation);    % CHECK: = 1?
% % 
% % 
%%


%% CLEAR UNNECCESSARY VARIABLES
clearvars y x k interval i t %DataProc.SalemOsama
toc;
%close all
















































































