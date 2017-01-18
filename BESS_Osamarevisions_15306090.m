% NAME:     BESS_OsamaRevisions.m
% REV DATE: 22 Jul 2015
% Author: Osama Mansour

% Salem Battery Energy Storage System (BESS)
% This was developed to replicate & expand the 2014 Capstone script
% This was developed to replicate & expand the 2015 Capstone script
% clc; clear all;close all;
%clc; clear all; close all;
tic;
%% HEADING
% This section defines the header of the file.
fprintf('\nSALEM BATTERY ENERGY STORAGE SYSTEM (BESS)-  1 min -  Smooth 15-30:\n');



%% LOAD FILES
% This section loads a year's worth of Salem PV one minute data from 2014
% from January to December.
% The Oxford  load data is one minute data from Jan to Dec of 2012.
% The Oahu PV data is pne second data from 5pm-8pm from April 2010 to March
% 2011. 

DataRaw.Salem=csvread('SalemPVYear.csv');
DataRaw.Oxford=csvread('OXFD.csv');


%% Omit Last Day from Oxford
DataProc.Oxford= DataRaw.Oxford (1:1439,1:365);                 % Omit day 365
DataProc.Oxford(1440,1:365)=DataRaw.Oxford (1439,1:365);        % Data has 1439 points, assume 1440 =1439 for all days

%% CREATE TIME VECTOR
time.Entire = 1:1440;                       % Create time vector for entire day.


%% Maximum Load (Average Daily Maximum)
% Calculate max load & normalize load data
DataProc.OxfordMax = max(DataProc.Oxford);


%% Oxford Load Normalized
DataProc.OxfordNormalized=zeros(1440,365);

y=1;
while y <366

DataProc.OxfordNormalized(:,y)= DataProc.Oxford(:,y) / DataProc.OxfordMax(1,y);
y=y+1;
end
clear y

DataProc.OxfordNormMax= max(DataProc.OxfordNormalized);

%%  Salem PV Data convert to MW

DataProc.SalemMW= DataRaw.Salem / 1000;  % Change to MW



%% Salem PV Data Normalized

DataProc.SalemMax = max(DataProc.SalemMW);
DataProc.SalemNormalized=zeros(1440,365);

y=1;
while y <366

DataProc.SalemNormalized(:,y)= DataProc.SalemMW(:,y) / DataProc.SalemMax(1,y);
y=y+1;
end
clear y


%% Salem PV Data Scaled to PV Penetration 

PV.profile = [10:5:50];
PV.profile = 0.01 * PV.profile;     % Change % to decimal


%% Salem PV with different Penetrations

y=1;
while y <366 
    
DataProc.SalemPVpen.P1= DataProc.SalemNormalized .* PV.profile(1) .* DataProc.OxfordMax(1,y);

DataProc.SalemPVpen.P2= DataProc.SalemNormalized .* PV.profile(2).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P3= DataProc.SalemNormalized .* PV.profile(3).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P4= DataProc.SalemNormalized .* PV.profile(4).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P5= DataProc.SalemNormalized .* PV.profile(5).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P6= DataProc.SalemNormalized .* PV.profile(6).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P7= DataProc.SalemNormalized .* PV.profile(7).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P8= DataProc.SalemNormalized .* PV.profile(8).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P9= DataProc.SalemNormalized .* PV.profile(9).* DataProc.OxfordMax(1,y);
DataProc.SalemPVpen.P90= DataProc.SalemNormalized .* 0.9 .* DataProc.OxfordMax(1,y);

y=y+1;
end
clear y


% % 


%%
% % close all;
% % figure;
% % plot(time.Entire, [DataProc.SalemNormalized(:,1), DataProc.SalemPVpen.P1(:,1)])
% % legend('Salem PV' , ' Salem PV 10%')
% % 
% % 
% % % figure;
% % hold on;
% % plot(time.Entire, [DataProc.SalemNormalized(:,1), DataProc.SalemPVpen.P6(:,1)])
% % legend('Salem PV' , ' Salem PV 35%')
% % 
% % 
% % 
% % % figure;
% % hold on;
% % plot(time.Entire, [DataProc.SalemNormalized(:,1), DataProc.SalemPVpen.P9(:,1)])
% % legend('Salem PV' , ' Salem PV 50%')
% % 
% % 
% % 
% % % figure;
% % hold on;
% % plot(time.Entire, [DataProc.SalemNormalized(:,1), DataProc.SalemPVpen.P90(:,1)])
% % legend('Salem PV' , ' Salem PV 90%')
% % 
% % 
% % 
% % % % % 
% % % % % 
% % % % % 
%% PV plus Load

DataProc.PVplusLoad.P1 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P1;
DataProc.PVplusLoad.P2 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P2;
DataProc.PVplusLoad.P3 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P3;
DataProc.PVplusLoad.P4 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P4;
DataProc.PVplusLoad.P5 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P5;
DataProc.PVplusLoad.P6 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P6;
DataProc.PVplusLoad.P7 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P7;
DataProc.PVplusLoad.P8 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P8;
DataProc.PVplusLoad.P9 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P9;
DataProc.PVplusLoad.P90 =  DataProc.OxfordNormalized - DataProc.SalemPVpen.P90;


%%
% % close all;
% % 
% % DataRaw.Day=1;
% % 
% % figure;
% % plot(time.Entire/60, [DataProc.OxfordNormalized(:,DataRaw.Day), DataProc.PVplusLoad.P1(:,DataRaw.Day), -DataProc.SalemPVpen.P1(:,DataRaw.Day)])
% % legend('Load','Pv Plus Load' , ' Salem PV 10%','Location','best')
% % 
% % figure;
% % plot(time.Entire/60, [DataProc.OxfordNormalized(:,DataRaw.Day), DataProc.PVplusLoad.P6(:,DataRaw.Day), -DataProc.SalemPVpen.P6(:,DataRaw.Day)])
% % legend('Load','PV Plus Load' , ' Salem PV 35%','Location','best')
% % 
% % 
% % 
% % figure;
% % plot(time.Entire/60, [DataProc.OxfordNormalized(:,DataRaw.Day), DataProc.PVplusLoad.P9(:,DataRaw.Day), -DataProc.SalemPVpen.P9(:,DataRaw.Day)])
% % legend('Load','PV Plus Load' , ' Salem PV 50%','Location','best')
% % 
% % 
% % 
% % 
% % figure;
% % plot(time.Entire/60, [DataProc.OxfordNormalized(:,DataRaw.Day), DataProc.PVplusLoad.P90(:,DataRaw.Day), -DataProc.SalemPVpen.P90(:,DataRaw.Day)])
% % legend('Load','PV Plus Load' , ' Salem PV 90%','Location','best')





%% Flat DFP
y=1;
while y <366
FlatDFP.P1(1:1440,y) = mean(DataProc.PVplusLoad.P1(:,y));
FlatDFP.P2(1:1440,y) = mean(DataProc.PVplusLoad.P2(:,y));
FlatDFP.P3(1:1440,y) = mean(DataProc.PVplusLoad.P3(:,y));
FlatDFP.P4(1:1440,y) = mean(DataProc.PVplusLoad.P4(:,y));
FlatDFP.P5(1:1440,y) = mean(DataProc.PVplusLoad.P5(:,y));
FlatDFP.P6(1:1440,y) = mean(DataProc.PVplusLoad.P6(:,y));
FlatDFP.P7(1:1440,y) = mean(DataProc.PVplusLoad.P7(:,y));
FlatDFP.P8(1:1440,y) = mean(DataProc.PVplusLoad.P8(:,y));
FlatDFP.P9(1:1440,y) = mean(DataProc.PVplusLoad.P9(:,y));
FlatDFP.P90(1:1440,y) = mean(DataProc.PVplusLoad.P90(:,y));
y=y+1;
end
%%
% % 
% figure;
% 
% DataRaw.Day=80;
% plot(time.Entire/60, [DataProc.OxfordNormalized(:,DataRaw.Day), DataProc.PVplusLoad.P1(:,DataRaw.Day), -DataProc.SalemPVpen.P1(:,DataRaw.Day),FlatDFP.P1(:,DataRaw.Day)])
% hold on;
% plot(time.Entire/60, [DataProc.PVplusLoad.P9(:,DataRaw.Day), -DataProc.SalemPVpen.P9(:,DataRaw.Day),FlatDFP.P9(:,DataRaw.Day)]   )
% legend('Load', 'PV Plus Load 10%' , 'Salem PV 10% Pen','Flat 10%' , 'PV Plus Load 50%' , 'Salem PV 50% Pen', 'Flat 50%',  'Location','best')


%% Smooth15 Initite Variables

%%% Smoothed DFP
 Smooth15.Smoothed.P1=zeros(1440,365);     % Smoothed PV Plus Load 10%
 Smooth15.Smoothed.P2=zeros(1440,365);     % Smoothed PV Plus Load 15%
 Smooth15.Smoothed.P3=zeros(1440,365);     % Smoothed PV Plus Load 20%
 Smooth15.Smoothed.P4=zeros(1440,365);     % Smoothed PV Plus Load 25%
 Smooth15.Smoothed.P5=zeros(1440,365);     % Smoothed PV Plus Load 30%
 Smooth15.Smoothed.P6=zeros(1440,365);     % Smoothed PV Plus Load 35%
 Smooth15.Smoothed.P7=zeros(1440,365);     % Smoothed PV Plus Load 40%
 Smooth15.Smoothed.P8=zeros(1440,365);     % Smoothed PV Plus Load 45%
 Smooth15.Smoothed.P9=zeros(1440,365);     % Smoothed PV Plus Load 50%
 Smooth15.Smoothed.P90=zeros(1440,365);    % Smoothed PV Plus Load 90%
 
 
 
 
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
 Smooth15.BESSrefLine.P1 =zeros(1440,365);     % Reference Line Smooth 10%
 Smooth15.BESSrefLine.P2 =zeros(1440,365);     % Reference Line Smooth 15%
 Smooth15.BESSrefLine.P3 =zeros(1440,365);     % Reference Line Smooth 20%
 Smooth15.BESSrefLine.P4 =zeros(1440,365);     % Reference Line Smooth 25%
 Smooth15.BESSrefLine.P5 =zeros(1440,365);     % Reference Line Smooth 30%
 Smooth15.BESSrefLine.P6 =zeros(1440,365);     % Reference Line Smooth 35%
 Smooth15.BESSrefLine.P7 =zeros(1440,365);     % Reference Line Smooth 40%
 Smooth15.BESSrefLine.P8 =zeros(1440,365);     % Reference Line Smooth 45%
 Smooth15.BESSrefLine.P9 =zeros(1440,365);     % Reference Line Smooth 50%
 Smooth15.BESSrefLine.P90 =zeros(1440,365);     % Reference Line Smooth 90%


 
 
 %% Run Smoothing Function 
 % calculates MW MWhr - Smooth and Flat
 % 15 min
tail=15;  
 
tic;
 for y=1:365;
  
[Smooth15.Smoothed.P1(:,y), Smooth15.MaxMWSmooth.P1(:,y), Smooth15.MWhrSmooth.P1(:,y),  Smooth15.MaxMWFlat.P1(:,y) ,  Smooth15.MWhrFlat.P1(:,y) ,  Smooth15.BESSrefLine.P1(:,y)] = PolySama2( DataProc.PVplusLoad.P1(:,y), FlatDFP.P1(1:1440,y) ,tail);
[Smooth15.Smoothed.P2(:,y), Smooth15.MaxMWSmooth.P2(:,y), Smooth15.MWhrSmooth.P2(:,y),  Smooth15.MaxMWFlat.P2(:,y) ,  Smooth15.MWhrFlat.P2(:,y) ,  Smooth15.BESSrefLine.P2(:,y)] = PolySama2( DataProc.PVplusLoad.P2(:,y), FlatDFP.P2(1:1440,y) ,tail);
[Smooth15.Smoothed.P3(:,y), Smooth15.MaxMWSmooth.P3(:,y), Smooth15.MWhrSmooth.P3(:,y),  Smooth15.MaxMWFlat.P3(:,y) ,  Smooth15.MWhrFlat.P3(:,y) ,  Smooth15.BESSrefLine.P3(:,y)] = PolySama2( DataProc.PVplusLoad.P3(:,y), FlatDFP.P3(1:1440,y) ,tail);
[Smooth15.Smoothed.P4(:,y), Smooth15.MaxMWSmooth.P4(:,y), Smooth15.MWhrSmooth.P4(:,y),  Smooth15.MaxMWFlat.P4(:,y) ,  Smooth15.MWhrFlat.P4(:,y) ,  Smooth15.BESSrefLine.P4(:,y)] = PolySama2( DataProc.PVplusLoad.P4(:,y), FlatDFP.P4(1:1440,y) ,tail);
[Smooth15.Smoothed.P5(:,y), Smooth15.MaxMWSmooth.P5(:,y), Smooth15.MWhrSmooth.P5(:,y),  Smooth15.MaxMWFlat.P5(:,y) ,  Smooth15.MWhrFlat.P5(:,y) ,  Smooth15.BESSrefLine.P5(:,y)] = PolySama2( DataProc.PVplusLoad.P5(:,y), FlatDFP.P5(1:1440,y) ,tail);
[Smooth15.Smoothed.P6(:,y), Smooth15.MaxMWSmooth.P6(:,y), Smooth15.MWhrSmooth.P6(:,y),  Smooth15.MaxMWFlat.P6(:,y) ,  Smooth15.MWhrFlat.P6(:,y) ,  Smooth15.BESSrefLine.P6(:,y)] = PolySama2( DataProc.PVplusLoad.P6(:,y), FlatDFP.P6(1:1440,y) ,tail);
[Smooth15.Smoothed.P7(:,y), Smooth15.MaxMWSmooth.P7(:,y), Smooth15.MWhrSmooth.P7(:,y),  Smooth15.MaxMWFlat.P7(:,y) ,  Smooth15.MWhrFlat.P7(:,y) ,  Smooth15.BESSrefLine.P7(:,y)] = PolySama2( DataProc.PVplusLoad.P7(:,y), FlatDFP.P7(1:1440,y) ,tail);
[Smooth15.Smoothed.P8(:,y), Smooth15.MaxMWSmooth.P8(:,y), Smooth15.MWhrSmooth.P8(:,y),  Smooth15.MaxMWFlat.P8(:,y) ,  Smooth15.MWhrFlat.P8(:,y) ,  Smooth15.BESSrefLine.P8(:,y)] = PolySama2( DataProc.PVplusLoad.P8(:,y), FlatDFP.P8(1:1440,y) ,tail);
[Smooth15.Smoothed.P9(:,y), Smooth15.MaxMWSmooth.P9(:,y), Smooth15.MWhrSmooth.P9(:,y),  Smooth15.MaxMWFlat.P9(:,y) ,  Smooth15.MWhrFlat.P9(:,y) ,  Smooth15.BESSrefLine.P9(:,y)] = PolySama2( DataProc.PVplusLoad.P9(:,y), FlatDFP.P9(1:1440,y) ,tail);
[Smooth15.Smoothed.P90(:,y), Smooth15.MaxMWSmooth.P90(:,y), Smooth15.MWhrSmooth.P90(:,y),  Smooth15.MaxMWFlat.P90(:,y) ,  Smooth15.MWhrFlat.P90(:,y) ,  Smooth15.BESSrefLine.P90(:,y)] = PolySama2( DataProc.PVplusLoad.P90(:,y), FlatDFP.P90(1:1440,y) ,tail);



 end

toc;





%% Smooth30 Initite Variables

%%% Smoothed DFP
 Smooth30.Smoothed.P1=zeros(1440,365);     % Smoothed PV Plus Load 10%
 Smooth30.Smoothed.P2=zeros(1440,365);     % Smoothed PV Plus Load 15%
 Smooth30.Smoothed.P3=zeros(1440,365);     % Smoothed PV Plus Load 20%
 Smooth30.Smoothed.P4=zeros(1440,365);     % Smoothed PV Plus Load 25%
 Smooth30.Smoothed.P5=zeros(1440,365);     % Smoothed PV Plus Load 30%
 Smooth30.Smoothed.P6=zeros(1440,365);     % Smoothed PV Plus Load 35%
 Smooth30.Smoothed.P7=zeros(1440,365);     % Smoothed PV Plus Load 40%
 Smooth30.Smoothed.P8=zeros(1440,365);     % Smoothed PV Plus Load 45%
 Smooth30.Smoothed.P9=zeros(1440,365);     % Smoothed PV Plus Load 50%
 Smooth30.Smoothed.P90=zeros(1440,365);    % Smoothed PV Plus Load 90%
 
 
 
 
%%% MW Smoothed DFP
 Smooth30.MaxMWSmooth.P1=zeros(1,365);         % MW Smooth DFP 10%
 Smooth30.MaxMWSmooth.P2=zeros(1,365);         % MW Smooth DFP 15%
 Smooth30.MaxMWSmooth.P3=zeros(1,365);         % MW Smooth DFP 20%
 Smooth30.MaxMWSmooth.P4=zeros(1,365);         % MW Smooth DFP 25%
 Smooth30.MaxMWSmooth.P5=zeros(1,365);         % MW Smooth DFP 30%
 Smooth30.MaxMWSmooth.P6=zeros(1,365);         % MW Smooth DFP 35%
 Smooth30.MaxMWSmooth.P7=zeros(1,365);         % MW Smooth DFP 40%
 Smooth30.MaxMWSmooth.P8=zeros(1,365);         % MW Smooth DFP 45%
 Smooth30.MaxMWSmooth.P9=zeros(1,365);         % MW Smooth DFP 50%
 Smooth30.MaxMWSmooth.P90=zeros(1,365);        % MW Smooth DFP 90%
 
 
%%% MWhr Smoothed DFP
 Smooth30.MWhrSmooth.P1=zeros(1,365);          % MWhr Smooth DFP 10%
 Smooth30.MWhrSmooth.P2=zeros(1,365);          % MWhr Smooth DFP 15%
 Smooth30.MWhrSmooth.P3=zeros(1,365);          % MWhr Smooth DFP 20%
 Smooth30.MWhrSmooth.P4=zeros(1,365);          % MWhr Smooth DFP 25%
 Smooth30.MWhrSmooth.P5=zeros(1,365);          % MWhr Smooth DFP 30%
 Smooth30.MWhrSmooth.P6=zeros(1,365);          % MWhr Smooth DFP 35%
 Smooth30.MWhrSmooth.P7=zeros(1,365);          % MWhr Smooth DFP 40%
 Smooth30.MWhrSmooth.P8=zeros(1,365);          % MWhr Smooth DFP 45%
 Smooth30.MWhrSmooth.P9=zeros(1,365);          % MWhr Smooth DFP 50%
 Smooth30.MWhrSmooth.P90=zeros(1,365);         % MWhr Smooth DFP 90%
 
  
%%% MW Flat DFP  
 Smooth30.MaxMWFlat.P1=zeros(1,365);           % MW Flat DFP 10%
 Smooth30.MaxMWFlat.P2=zeros(1,365);           % MW Flat DFP 15%
 Smooth30.MaxMWFlat.P3=zeros(1,365);           % MW Flat DFP 20%
 Smooth30.MaxMWFlat.P4=zeros(1,365);           % MW Flat DFP 25%
 Smooth30.MaxMWFlat.P5=zeros(1,365);           % MW Flat DFP 30%
 Smooth30.MaxMWFlat.P6=zeros(1,365);           % MW Flat DFP 35%
 Smooth30.MaxMWFlat.P7=zeros(1,365);           % MW Flat DFP 40%
 Smooth30.MaxMWFlat.P8=zeros(1,365);           % MW Flat DFP 45%
 Smooth30.MaxMWFlat.P9=zeros(1,365);           % MW Flat DFP 50%
 Smooth30.MaxMWFlat.P90=zeros(1,365);          % MW Flat DFP 900%
 
 
%%% MW Flat DFP  
 Smooth30.MWhrFlat.P1=zeros(1,365);            % MWhr Flat DFP 10%
 Smooth30.MWhrFlat.P2=zeros(1,365);            % MWhr Flat DFP 15%
 Smooth30.MWhrFlat.P3=zeros(1,365);            % MWhr Flat DFP 20%
 Smooth30.MWhrFlat.P4=zeros(1,365);            % MWhr Flat DFP 25%
 Smooth30.MWhrFlat.P5=zeros(1,365);            % MWhr Flat DFP 30%
 Smooth30.MWhrFlat.P6=zeros(1,365);            % MWhr Flat DFP 35%
 Smooth30.MWhrFlat.P7=zeros(1,365);            % MWhr Flat DFP 40%
 Smooth30.MWhrFlat.P8=zeros(1,365);            % MWhr Flat DFP 45%
 Smooth30.MWhrFlat.P9=zeros(1,365);            % MWhr Flat DFP 50%
 Smooth30.MWhrFlat.P90=zeros(1,365);           % MWhr Flat DFP 90%
 
 
 
%%% Reference Line Smooth DFP
 Smooth30.BESSrefLine.P1 =zeros(1440,365);     % Reference Line Smooth 10%
 Smooth30.BESSrefLine.P2 =zeros(1440,365);     % Reference Line Smooth 15%
 Smooth30.BESSrefLine.P3 =zeros(1440,365);     % Reference Line Smooth 20%
 Smooth30.BESSrefLine.P4 =zeros(1440,365);     % Reference Line Smooth 25%
 Smooth30.BESSrefLine.P5 =zeros(1440,365);     % Reference Line Smooth 30%
 Smooth30.BESSrefLine.P6 =zeros(1440,365);     % Reference Line Smooth 35%
 Smooth30.BESSrefLine.P7 =zeros(1440,365);     % Reference Line Smooth 40%
 Smooth30.BESSrefLine.P8 =zeros(1440,365);     % Reference Line Smooth 45%
 Smooth30.BESSrefLine.P9 =zeros(1440,365);     % Reference Line Smooth 50%
 Smooth30.BESSrefLine.P90 =zeros(1440,365);     % Reference Line Smooth 90%


 
 
 %% Run Smoothing Function 
 % calculates MW MWhr - Smooth and Flat
 % 15 min
tail=30;  
 
tic;
 for y=1:365;
  
[Smooth30.Smoothed.P1(:,y), Smooth30.MaxMWSmooth.P1(:,y), Smooth30.MWhrSmooth.P1(:,y),  Smooth30.MaxMWFlat.P1(:,y) ,  Smooth30.MWhrFlat.P1(:,y) ,  Smooth30.BESSrefLine.P1(:,y)] = PolySama2( DataProc.PVplusLoad.P1(:,y), FlatDFP.P1(1:1440,y) ,tail);
[Smooth30.Smoothed.P2(:,y), Smooth30.MaxMWSmooth.P2(:,y), Smooth30.MWhrSmooth.P2(:,y),  Smooth30.MaxMWFlat.P2(:,y) ,  Smooth30.MWhrFlat.P2(:,y) ,  Smooth30.BESSrefLine.P2(:,y)] = PolySama2( DataProc.PVplusLoad.P2(:,y), FlatDFP.P2(1:1440,y) ,tail);
[Smooth30.Smoothed.P3(:,y), Smooth30.MaxMWSmooth.P3(:,y), Smooth30.MWhrSmooth.P3(:,y),  Smooth30.MaxMWFlat.P3(:,y) ,  Smooth30.MWhrFlat.P3(:,y) ,  Smooth30.BESSrefLine.P3(:,y)] = PolySama2( DataProc.PVplusLoad.P3(:,y), FlatDFP.P3(1:1440,y) ,tail);
[Smooth30.Smoothed.P4(:,y), Smooth30.MaxMWSmooth.P4(:,y), Smooth30.MWhrSmooth.P4(:,y),  Smooth30.MaxMWFlat.P4(:,y) ,  Smooth30.MWhrFlat.P4(:,y) ,  Smooth30.BESSrefLine.P4(:,y)] = PolySama2( DataProc.PVplusLoad.P4(:,y), FlatDFP.P4(1:1440,y) ,tail);
[Smooth30.Smoothed.P5(:,y), Smooth30.MaxMWSmooth.P5(:,y), Smooth30.MWhrSmooth.P5(:,y),  Smooth30.MaxMWFlat.P5(:,y) ,  Smooth30.MWhrFlat.P5(:,y) ,  Smooth30.BESSrefLine.P5(:,y)] = PolySama2( DataProc.PVplusLoad.P5(:,y), FlatDFP.P5(1:1440,y) ,tail);
[Smooth30.Smoothed.P6(:,y), Smooth30.MaxMWSmooth.P6(:,y), Smooth30.MWhrSmooth.P6(:,y),  Smooth30.MaxMWFlat.P6(:,y) ,  Smooth30.MWhrFlat.P6(:,y) ,  Smooth30.BESSrefLine.P6(:,y)] = PolySama2( DataProc.PVplusLoad.P6(:,y), FlatDFP.P6(1:1440,y) ,tail);
[Smooth30.Smoothed.P7(:,y), Smooth30.MaxMWSmooth.P7(:,y), Smooth30.MWhrSmooth.P7(:,y),  Smooth30.MaxMWFlat.P7(:,y) ,  Smooth30.MWhrFlat.P7(:,y) ,  Smooth30.BESSrefLine.P7(:,y)] = PolySama2( DataProc.PVplusLoad.P7(:,y), FlatDFP.P7(1:1440,y) ,tail);
[Smooth30.Smoothed.P8(:,y), Smooth30.MaxMWSmooth.P8(:,y), Smooth30.MWhrSmooth.P8(:,y),  Smooth30.MaxMWFlat.P8(:,y) ,  Smooth30.MWhrFlat.P8(:,y) ,  Smooth30.BESSrefLine.P8(:,y)] = PolySama2( DataProc.PVplusLoad.P8(:,y), FlatDFP.P8(1:1440,y) ,tail);
[Smooth30.Smoothed.P9(:,y), Smooth30.MaxMWSmooth.P9(:,y), Smooth30.MWhrSmooth.P9(:,y),  Smooth30.MaxMWFlat.P9(:,y) ,  Smooth30.MWhrFlat.P9(:,y) ,  Smooth30.BESSrefLine.P9(:,y)] = PolySama2( DataProc.PVplusLoad.P9(:,y), FlatDFP.P9(1:1440,y) ,tail);
[Smooth30.Smoothed.P90(:,y), Smooth30.MaxMWSmooth.P90(:,y), Smooth30.MWhrSmooth.P90(:,y),  Smooth30.MaxMWFlat.P90(:,y) ,  Smooth30.MWhrFlat.P90(:,y) ,  Smooth30.BESSrefLine.P90(:,y)] = PolySama2( DataProc.PVplusLoad.P90(:,y), FlatDFP.P90(1:1440,y) ,tail);



 end

toc;


%% Smooth60 Initite Variables

%%% Smoothed DFP
 Smooth60.Smoothed.P1=zeros(1440,365);     % Smoothed PV Plus Load 10%
 Smooth60.Smoothed.P2=zeros(1440,365);     % Smoothed PV Plus Load 15%
 Smooth60.Smoothed.P3=zeros(1440,365);     % Smoothed PV Plus Load 20%
 Smooth60.Smoothed.P4=zeros(1440,365);     % Smoothed PV Plus Load 25%
 Smooth60.Smoothed.P5=zeros(1440,365);     % Smoothed PV Plus Load 30%
 Smooth60.Smoothed.P6=zeros(1440,365);     % Smoothed PV Plus Load 35%
 Smooth60.Smoothed.P7=zeros(1440,365);     % Smoothed PV Plus Load 40%
 Smooth60.Smoothed.P8=zeros(1440,365);     % Smoothed PV Plus Load 45%
 Smooth60.Smoothed.P9=zeros(1440,365);     % Smoothed PV Plus Load 50%
 Smooth60.Smoothed.P90=zeros(1440,365);    % Smoothed PV Plus Load 90%
 
 
 
 
%%% MW Smoothed DFP
 Smooth60.MaxMWSmooth.P1=zeros(1,365);         % MW Smooth DFP 10%
 Smooth60.MaxMWSmooth.P2=zeros(1,365);         % MW Smooth DFP 15%
 Smooth60.MaxMWSmooth.P3=zeros(1,365);         % MW Smooth DFP 20%
 Smooth60.MaxMWSmooth.P4=zeros(1,365);         % MW Smooth DFP 25%
 Smooth60.MaxMWSmooth.P5=zeros(1,365);         % MW Smooth DFP 30%
 Smooth60.MaxMWSmooth.P6=zeros(1,365);         % MW Smooth DFP 35%
 Smooth60.MaxMWSmooth.P7=zeros(1,365);         % MW Smooth DFP 40%
 Smooth60.MaxMWSmooth.P8=zeros(1,365);         % MW Smooth DFP 45%
 Smooth60.MaxMWSmooth.P9=zeros(1,365);         % MW Smooth DFP 50%
 Smooth60.MaxMWSmooth.P90=zeros(1,365);        % MW Smooth DFP 90%
 
 
%%% MWhr Smoothed DFP
 Smooth60.MWhrSmooth.P1=zeros(1,365);          % MWhr Smooth DFP 10%
 Smooth60.MWhrSmooth.P2=zeros(1,365);          % MWhr Smooth DFP 15%
 Smooth60.MWhrSmooth.P3=zeros(1,365);          % MWhr Smooth DFP 20%
 Smooth60.MWhrSmooth.P4=zeros(1,365);          % MWhr Smooth DFP 25%
 Smooth60.MWhrSmooth.P5=zeros(1,365);          % MWhr Smooth DFP 30%
 Smooth60.MWhrSmooth.P6=zeros(1,365);          % MWhr Smooth DFP 35%
 Smooth60.MWhrSmooth.P7=zeros(1,365);          % MWhr Smooth DFP 40%
 Smooth60.MWhrSmooth.P8=zeros(1,365);          % MWhr Smooth DFP 45%
 Smooth60.MWhrSmooth.P9=zeros(1,365);          % MWhr Smooth DFP 50%
 Smooth60.MWhrSmooth.P90=zeros(1,365);         % MWhr Smooth DFP 90%
 
  
%%% MW Flat DFP  
 Smooth60.MaxMWFlat.P1=zeros(1,365);           % MW Flat DFP 10%
 Smooth60.MaxMWFlat.P2=zeros(1,365);           % MW Flat DFP 15%
 Smooth60.MaxMWFlat.P3=zeros(1,365);           % MW Flat DFP 20%
 Smooth60.MaxMWFlat.P4=zeros(1,365);           % MW Flat DFP 25%
 Smooth60.MaxMWFlat.P5=zeros(1,365);           % MW Flat DFP 30%
 Smooth60.MaxMWFlat.P6=zeros(1,365);           % MW Flat DFP 35%
 Smooth60.MaxMWFlat.P7=zeros(1,365);           % MW Flat DFP 40%
 Smooth60.MaxMWFlat.P8=zeros(1,365);           % MW Flat DFP 45%
 Smooth60.MaxMWFlat.P9=zeros(1,365);           % MW Flat DFP 50%
 Smooth60.MaxMWFlat.P90=zeros(1,365);          % MW Flat DFP 900%
 
 
%%% MW Flat DFP  
 Smooth60.MWhrFlat.P1=zeros(1,365);            % MWhr Flat DFP 10%
 Smooth60.MWhrFlat.P2=zeros(1,365);            % MWhr Flat DFP 15%
 Smooth60.MWhrFlat.P3=zeros(1,365);            % MWhr Flat DFP 20%
 Smooth60.MWhrFlat.P4=zeros(1,365);            % MWhr Flat DFP 25%
 Smooth60.MWhrFlat.P5=zeros(1,365);            % MWhr Flat DFP 30%
 Smooth60.MWhrFlat.P6=zeros(1,365);            % MWhr Flat DFP 35%
 Smooth60.MWhrFlat.P7=zeros(1,365);            % MWhr Flat DFP 40%
 Smooth60.MWhrFlat.P8=zeros(1,365);            % MWhr Flat DFP 45%
 Smooth60.MWhrFlat.P9=zeros(1,365);            % MWhr Flat DFP 50%
 Smooth60.MWhrFlat.P90=zeros(1,365);           % MWhr Flat DFP 90%
 
 
 
%%% Reference Line Smooth DFP
 Smooth60.BESSrefLine.P1 =zeros(1440,365);     % Reference Line Smooth 10%
 Smooth60.BESSrefLine.P2 =zeros(1440,365);     % Reference Line Smooth 15%
 Smooth60.BESSrefLine.P3 =zeros(1440,365);     % Reference Line Smooth 20%
 Smooth60.BESSrefLine.P4 =zeros(1440,365);     % Reference Line Smooth 25%
 Smooth60.BESSrefLine.P5 =zeros(1440,365);     % Reference Line Smooth 30%
 Smooth60.BESSrefLine.P6 =zeros(1440,365);     % Reference Line Smooth 35%
 Smooth60.BESSrefLine.P7 =zeros(1440,365);     % Reference Line Smooth 40%
 Smooth60.BESSrefLine.P8 =zeros(1440,365);     % Reference Line Smooth 45%
 Smooth60.BESSrefLine.P9 =zeros(1440,365);     % Reference Line Smooth 50%
 Smooth60.BESSrefLine.P90 =zeros(1440,365);     % Reference Line Smooth 90%


 
 
 %% Run Smoothing Function 
 % calculates MW MWhr - Smooth and Flat
 % 15 min
tail=60;  
 
tic;
 for y=1:365;
  
[Smooth60.Smoothed.P1(:,y), Smooth60.MaxMWSmooth.P1(:,y), Smooth60.MWhrSmooth.P1(:,y),  Smooth60.MaxMWFlat.P1(:,y) ,  Smooth60.MWhrFlat.P1(:,y) ,  Smooth60.BESSrefLine.P1(:,y)] = PolySama2( DataProc.PVplusLoad.P1(:,y), FlatDFP.P1(1:1440,y) ,tail);
[Smooth60.Smoothed.P2(:,y), Smooth60.MaxMWSmooth.P2(:,y), Smooth60.MWhrSmooth.P2(:,y),  Smooth60.MaxMWFlat.P2(:,y) ,  Smooth60.MWhrFlat.P2(:,y) ,  Smooth60.BESSrefLine.P2(:,y)] = PolySama2( DataProc.PVplusLoad.P2(:,y), FlatDFP.P2(1:1440,y) ,tail);
[Smooth60.Smoothed.P3(:,y), Smooth60.MaxMWSmooth.P3(:,y), Smooth60.MWhrSmooth.P3(:,y),  Smooth60.MaxMWFlat.P3(:,y) ,  Smooth60.MWhrFlat.P3(:,y) ,  Smooth60.BESSrefLine.P3(:,y)] = PolySama2( DataProc.PVplusLoad.P3(:,y), FlatDFP.P3(1:1440,y) ,tail);
[Smooth60.Smoothed.P4(:,y), Smooth60.MaxMWSmooth.P4(:,y), Smooth60.MWhrSmooth.P4(:,y),  Smooth60.MaxMWFlat.P4(:,y) ,  Smooth60.MWhrFlat.P4(:,y) ,  Smooth60.BESSrefLine.P4(:,y)] = PolySama2( DataProc.PVplusLoad.P4(:,y), FlatDFP.P4(1:1440,y) ,tail);
[Smooth60.Smoothed.P5(:,y), Smooth60.MaxMWSmooth.P5(:,y), Smooth60.MWhrSmooth.P5(:,y),  Smooth60.MaxMWFlat.P5(:,y) ,  Smooth60.MWhrFlat.P5(:,y) ,  Smooth60.BESSrefLine.P5(:,y)] = PolySama2( DataProc.PVplusLoad.P5(:,y), FlatDFP.P5(1:1440,y) ,tail);
[Smooth60.Smoothed.P6(:,y), Smooth60.MaxMWSmooth.P6(:,y), Smooth60.MWhrSmooth.P6(:,y),  Smooth60.MaxMWFlat.P6(:,y) ,  Smooth60.MWhrFlat.P6(:,y) ,  Smooth60.BESSrefLine.P6(:,y)] = PolySama2( DataProc.PVplusLoad.P6(:,y), FlatDFP.P6(1:1440,y) ,tail);
[Smooth60.Smoothed.P7(:,y), Smooth60.MaxMWSmooth.P7(:,y), Smooth60.MWhrSmooth.P7(:,y),  Smooth60.MaxMWFlat.P7(:,y) ,  Smooth60.MWhrFlat.P7(:,y) ,  Smooth60.BESSrefLine.P7(:,y)] = PolySama2( DataProc.PVplusLoad.P7(:,y), FlatDFP.P7(1:1440,y) ,tail);
[Smooth60.Smoothed.P8(:,y), Smooth60.MaxMWSmooth.P8(:,y), Smooth60.MWhrSmooth.P8(:,y),  Smooth60.MaxMWFlat.P8(:,y) ,  Smooth60.MWhrFlat.P8(:,y) ,  Smooth60.BESSrefLine.P8(:,y)] = PolySama2( DataProc.PVplusLoad.P8(:,y), FlatDFP.P8(1:1440,y) ,tail);
[Smooth60.Smoothed.P9(:,y), Smooth60.MaxMWSmooth.P9(:,y), Smooth60.MWhrSmooth.P9(:,y),  Smooth60.MaxMWFlat.P9(:,y) ,  Smooth60.MWhrFlat.P9(:,y) ,  Smooth60.BESSrefLine.P9(:,y)] = PolySama2( DataProc.PVplusLoad.P9(:,y), FlatDFP.P9(1:1440,y) ,tail);
[Smooth60.Smoothed.P90(:,y), Smooth60.MaxMWSmooth.P90(:,y), Smooth60.MWhrSmooth.P90(:,y),  Smooth60.MaxMWFlat.P90(:,y) ,  Smooth60.MWhrFlat.P90(:,y) ,  Smooth60.BESSrefLine.P90(:,y)] = PolySama2( DataProc.PVplusLoad.P90(:,y), FlatDFP.P90(1:1440,y) ,tail);



 end

toc;


%% Smooth90 Initite Variables

%%% Smoothed DFP
 Smooth90.Smoothed.P1=zeros(1440,365);     % Smoothed PV Plus Load 10%
 Smooth90.Smoothed.P2=zeros(1440,365);     % Smoothed PV Plus Load 15%
 Smooth90.Smoothed.P3=zeros(1440,365);     % Smoothed PV Plus Load 20%
 Smooth90.Smoothed.P4=zeros(1440,365);     % Smoothed PV Plus Load 25%
 Smooth90.Smoothed.P5=zeros(1440,365);     % Smoothed PV Plus Load 30%
 Smooth90.Smoothed.P6=zeros(1440,365);     % Smoothed PV Plus Load 35%
 Smooth90.Smoothed.P7=zeros(1440,365);     % Smoothed PV Plus Load 40%
 Smooth90.Smoothed.P8=zeros(1440,365);     % Smoothed PV Plus Load 45%
 Smooth90.Smoothed.P9=zeros(1440,365);     % Smoothed PV Plus Load 50%
 Smooth90.Smoothed.P90=zeros(1440,365);    % Smoothed PV Plus Load 90%
 
 
 
 
%%% MW Smoothed DFP
 Smooth90.MaxMWSmooth.P1=zeros(1,365);         % MW Smooth DFP 10%
 Smooth90.MaxMWSmooth.P2=zeros(1,365);         % MW Smooth DFP 15%
 Smooth90.MaxMWSmooth.P3=zeros(1,365);         % MW Smooth DFP 20%
 Smooth90.MaxMWSmooth.P4=zeros(1,365);         % MW Smooth DFP 25%
 Smooth90.MaxMWSmooth.P5=zeros(1,365);         % MW Smooth DFP 30%
 Smooth90.MaxMWSmooth.P6=zeros(1,365);         % MW Smooth DFP 35%
 Smooth90.MaxMWSmooth.P7=zeros(1,365);         % MW Smooth DFP 40%
 Smooth90.MaxMWSmooth.P8=zeros(1,365);         % MW Smooth DFP 45%
 Smooth90.MaxMWSmooth.P9=zeros(1,365);         % MW Smooth DFP 50%
 Smooth90.MaxMWSmooth.P90=zeros(1,365);        % MW Smooth DFP 90%
 
 
%%% MWhr Smoothed DFP
 Smooth90.MWhrSmooth.P1=zeros(1,365);          % MWhr Smooth DFP 10%
 Smooth90.MWhrSmooth.P2=zeros(1,365);          % MWhr Smooth DFP 15%
 Smooth90.MWhrSmooth.P3=zeros(1,365);          % MWhr Smooth DFP 20%
 Smooth90.MWhrSmooth.P4=zeros(1,365);          % MWhr Smooth DFP 25%
 Smooth90.MWhrSmooth.P5=zeros(1,365);          % MWhr Smooth DFP 30%
 Smooth90.MWhrSmooth.P6=zeros(1,365);          % MWhr Smooth DFP 35%
 Smooth90.MWhrSmooth.P7=zeros(1,365);          % MWhr Smooth DFP 40%
 Smooth90.MWhrSmooth.P8=zeros(1,365);          % MWhr Smooth DFP 45%
 Smooth90.MWhrSmooth.P9=zeros(1,365);          % MWhr Smooth DFP 50%
 Smooth90.MWhrSmooth.P90=zeros(1,365);         % MWhr Smooth DFP 90%
 
  
%%% MW Flat DFP  
 Smooth90.MaxMWFlat.P1=zeros(1,365);           % MW Flat DFP 10%
 Smooth90.MaxMWFlat.P2=zeros(1,365);           % MW Flat DFP 15%
 Smooth90.MaxMWFlat.P3=zeros(1,365);           % MW Flat DFP 20%
 Smooth90.MaxMWFlat.P4=zeros(1,365);           % MW Flat DFP 25%
 Smooth90.MaxMWFlat.P5=zeros(1,365);           % MW Flat DFP 30%
 Smooth90.MaxMWFlat.P6=zeros(1,365);           % MW Flat DFP 35%
 Smooth90.MaxMWFlat.P7=zeros(1,365);           % MW Flat DFP 40%
 Smooth90.MaxMWFlat.P8=zeros(1,365);           % MW Flat DFP 45%
 Smooth90.MaxMWFlat.P9=zeros(1,365);           % MW Flat DFP 50%
 Smooth90.MaxMWFlat.P90=zeros(1,365);          % MW Flat DFP 900%
 
 
%%% MW Flat DFP  
 Smooth90.MWhrFlat.P1=zeros(1,365);            % MWhr Flat DFP 10%
 Smooth90.MWhrFlat.P2=zeros(1,365);            % MWhr Flat DFP 15%
 Smooth90.MWhrFlat.P3=zeros(1,365);            % MWhr Flat DFP 20%
 Smooth90.MWhrFlat.P4=zeros(1,365);            % MWhr Flat DFP 25%
 Smooth90.MWhrFlat.P5=zeros(1,365);            % MWhr Flat DFP 30%
 Smooth90.MWhrFlat.P6=zeros(1,365);            % MWhr Flat DFP 35%
 Smooth90.MWhrFlat.P7=zeros(1,365);            % MWhr Flat DFP 40%
 Smooth90.MWhrFlat.P8=zeros(1,365);            % MWhr Flat DFP 45%
 Smooth90.MWhrFlat.P9=zeros(1,365);            % MWhr Flat DFP 50%
 Smooth90.MWhrFlat.P90=zeros(1,365);           % MWhr Flat DFP 90%
 
 
 
%%% Reference Line Smooth DFP
 Smooth90.BESSrefLine.P1 =zeros(1440,365);     % Reference Line Smooth 10%
 Smooth90.BESSrefLine.P2 =zeros(1440,365);     % Reference Line Smooth 15%
 Smooth90.BESSrefLine.P3 =zeros(1440,365);     % Reference Line Smooth 20%
 Smooth90.BESSrefLine.P4 =zeros(1440,365);     % Reference Line Smooth 25%
 Smooth90.BESSrefLine.P5 =zeros(1440,365);     % Reference Line Smooth 30%
 Smooth90.BESSrefLine.P6 =zeros(1440,365);     % Reference Line Smooth 35%
 Smooth90.BESSrefLine.P7 =zeros(1440,365);     % Reference Line Smooth 40%
 Smooth90.BESSrefLine.P8 =zeros(1440,365);     % Reference Line Smooth 45%
 Smooth90.BESSrefLine.P9 =zeros(1440,365);     % Reference Line Smooth 50%
 Smooth90.BESSrefLine.P90 =zeros(1440,365);     % Reference Line Smooth 90%


 
 
 %% Run Smoothing Function 
 % calculates MW MWhr - Smooth and Flat
 % 15 min
tail=90;  
 
tic;
 for y=1:365;
  
[Smooth90.Smoothed.P1(:,y), Smooth90.MaxMWSmooth.P1(:,y), Smooth90.MWhrSmooth.P1(:,y),  Smooth90.MaxMWFlat.P1(:,y) ,  Smooth90.MWhrFlat.P1(:,y) ,  Smooth90.BESSrefLine.P1(:,y)] = PolySama2( DataProc.PVplusLoad.P1(:,y), FlatDFP.P1(1:1440,y) ,tail);
[Smooth90.Smoothed.P2(:,y), Smooth90.MaxMWSmooth.P2(:,y), Smooth90.MWhrSmooth.P2(:,y),  Smooth90.MaxMWFlat.P2(:,y) ,  Smooth90.MWhrFlat.P2(:,y) ,  Smooth90.BESSrefLine.P2(:,y)] = PolySama2( DataProc.PVplusLoad.P2(:,y), FlatDFP.P2(1:1440,y) ,tail);
[Smooth90.Smoothed.P3(:,y), Smooth90.MaxMWSmooth.P3(:,y), Smooth90.MWhrSmooth.P3(:,y),  Smooth90.MaxMWFlat.P3(:,y) ,  Smooth90.MWhrFlat.P3(:,y) ,  Smooth90.BESSrefLine.P3(:,y)] = PolySama2( DataProc.PVplusLoad.P3(:,y), FlatDFP.P3(1:1440,y) ,tail);
[Smooth90.Smoothed.P4(:,y), Smooth90.MaxMWSmooth.P4(:,y), Smooth90.MWhrSmooth.P4(:,y),  Smooth90.MaxMWFlat.P4(:,y) ,  Smooth90.MWhrFlat.P4(:,y) ,  Smooth90.BESSrefLine.P4(:,y)] = PolySama2( DataProc.PVplusLoad.P4(:,y), FlatDFP.P4(1:1440,y) ,tail);
[Smooth90.Smoothed.P5(:,y), Smooth90.MaxMWSmooth.P5(:,y), Smooth90.MWhrSmooth.P5(:,y),  Smooth90.MaxMWFlat.P5(:,y) ,  Smooth90.MWhrFlat.P5(:,y) ,  Smooth90.BESSrefLine.P5(:,y)] = PolySama2( DataProc.PVplusLoad.P5(:,y), FlatDFP.P5(1:1440,y) ,tail);
[Smooth90.Smoothed.P6(:,y), Smooth90.MaxMWSmooth.P6(:,y), Smooth90.MWhrSmooth.P6(:,y),  Smooth90.MaxMWFlat.P6(:,y) ,  Smooth90.MWhrFlat.P6(:,y) ,  Smooth90.BESSrefLine.P6(:,y)] = PolySama2( DataProc.PVplusLoad.P6(:,y), FlatDFP.P6(1:1440,y) ,tail);
[Smooth90.Smoothed.P7(:,y), Smooth90.MaxMWSmooth.P7(:,y), Smooth90.MWhrSmooth.P7(:,y),  Smooth90.MaxMWFlat.P7(:,y) ,  Smooth90.MWhrFlat.P7(:,y) ,  Smooth90.BESSrefLine.P7(:,y)] = PolySama2( DataProc.PVplusLoad.P7(:,y), FlatDFP.P7(1:1440,y) ,tail);
[Smooth90.Smoothed.P8(:,y), Smooth90.MaxMWSmooth.P8(:,y), Smooth90.MWhrSmooth.P8(:,y),  Smooth90.MaxMWFlat.P8(:,y) ,  Smooth90.MWhrFlat.P8(:,y) ,  Smooth90.BESSrefLine.P8(:,y)] = PolySama2( DataProc.PVplusLoad.P8(:,y), FlatDFP.P8(1:1440,y) ,tail);
[Smooth90.Smoothed.P9(:,y), Smooth90.MaxMWSmooth.P9(:,y), Smooth90.MWhrSmooth.P9(:,y),  Smooth90.MaxMWFlat.P9(:,y) ,  Smooth90.MWhrFlat.P9(:,y) ,  Smooth90.BESSrefLine.P9(:,y)] = PolySama2( DataProc.PVplusLoad.P9(:,y), FlatDFP.P9(1:1440,y) ,tail);
[Smooth90.Smoothed.P90(:,y), Smooth90.MaxMWSmooth.P90(:,y), Smooth90.MWhrSmooth.P90(:,y),  Smooth90.MaxMWFlat.P90(:,y) ,  Smooth90.MWhrFlat.P90(:,y) ,  Smooth90.BESSrefLine.P90(:,y)] = PolySama2( DataProc.PVplusLoad.P90(:,y), FlatDFP.P90(1:1440,y) ,tail);



 end

toc;


%% Scale Normalization 
%%%%%%%%%%%%%%%%%%%%%%%%% SMOOTH15 MIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scaled.Smooth15.MaxMWSmooth.P1 =  Smooth15.MaxMWSmooth.P1 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P1  =  Smooth15.MWhrSmooth.P1  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P1   =  Smooth15.MaxMWFlat.P1   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P1    =  Smooth15.MWhrFlat.P1    .* DataProc.OxfordMax;


Scaled.Smooth15.MaxMWSmooth.P2 =  Smooth15.MaxMWSmooth.P2 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P2  =  Smooth15.MWhrSmooth.P2  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P2   =  Smooth15.MaxMWFlat.P2   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P2    =  Smooth15.MWhrFlat.P2    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P3 =  Smooth15.MaxMWSmooth.P3 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P3  =  Smooth15.MWhrSmooth.P3  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P3   =  Smooth15.MaxMWFlat.P3   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P3    =  Smooth15.MWhrFlat.P3    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P4 =  Smooth15.MaxMWSmooth.P4 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P4  =  Smooth15.MWhrSmooth.P4  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P4   =  Smooth15.MaxMWFlat.P4   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P4    =  Smooth15.MWhrFlat.P4    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P5 =  Smooth15.MaxMWSmooth.P5 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P5  =  Smooth15.MWhrSmooth.P5  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P5   =  Smooth15.MaxMWFlat.P5   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P5    =  Smooth15.MWhrFlat.P5    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P6 =  Smooth15.MaxMWSmooth.P6 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P6  =  Smooth15.MWhrSmooth.P6  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P6   =  Smooth15.MaxMWFlat.P6   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P6    =  Smooth15.MWhrFlat.P6    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P7 =  Smooth15.MaxMWSmooth.P7 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P7  =  Smooth15.MWhrSmooth.P7  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P7   =  Smooth15.MaxMWFlat.P7   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P7    =  Smooth15.MWhrFlat.P7    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P8 =  Smooth15.MaxMWSmooth.P8 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P8  =  Smooth15.MWhrSmooth.P8  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P8   =  Smooth15.MaxMWFlat.P8   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P8    =  Smooth15.MWhrFlat.P8    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P9 =  Smooth15.MaxMWSmooth.P9 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P9  =  Smooth15.MWhrSmooth.P9  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P9   =  Smooth15.MaxMWFlat.P9   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P9    =  Smooth15.MWhrFlat.P9    .* DataProc.OxfordMax;

Scaled.Smooth15.MaxMWSmooth.P90 =  Smooth15.MaxMWSmooth.P90 .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrSmooth.P90  =  Smooth15.MWhrSmooth.P90  .* DataProc.OxfordMax;
Scaled.Smooth15.MaxMWFlat.P90   =  Smooth15.MaxMWFlat.P90   .* DataProc.OxfordMax;
Scaled.Smooth15.MWhrFlat.P90    =  Smooth15.MWhrFlat.P90    .* DataProc.OxfordMax;


%%%%%%%%%%%%%%%%%%%%%%%%% SMOOTH30 MIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scaled.Smooth30.MaxMWSmooth.P1 =  Smooth30.MaxMWSmooth.P1 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P1  =  Smooth30.MWhrSmooth.P1  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P1   =  Smooth30.MaxMWFlat.P1   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P1    =  Smooth30.MWhrFlat.P1    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P2 =  Smooth30.MaxMWSmooth.P2 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P2  =  Smooth30.MWhrSmooth.P2  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P2   =  Smooth30.MaxMWFlat.P2   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P2    =  Smooth30.MWhrFlat.P2    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P3 =  Smooth30.MaxMWSmooth.P3 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P3  =  Smooth30.MWhrSmooth.P3  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P3   =  Smooth30.MaxMWFlat.P3   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P3    =  Smooth30.MWhrFlat.P3    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P4 =  Smooth30.MaxMWSmooth.P4 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P4  =  Smooth30.MWhrSmooth.P4  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P4   =  Smooth30.MaxMWFlat.P4   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P4    =  Smooth30.MWhrFlat.P4    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P5 =  Smooth30.MaxMWSmooth.P5 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P5  =  Smooth30.MWhrSmooth.P5  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P5   =  Smooth30.MaxMWFlat.P5   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P5    =  Smooth30.MWhrFlat.P5    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P6 =  Smooth30.MaxMWSmooth.P6 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P6  =  Smooth30.MWhrSmooth.P6  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P6   =  Smooth30.MaxMWFlat.P6   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P6    =  Smooth30.MWhrFlat.P6    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P7 =  Smooth30.MaxMWSmooth.P7 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P7  =  Smooth30.MWhrSmooth.P7  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P7   =  Smooth30.MaxMWFlat.P7   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P7    =  Smooth30.MWhrFlat.P7    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P8 =  Smooth30.MaxMWSmooth.P8 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P8  =  Smooth30.MWhrSmooth.P8  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P8   =  Smooth30.MaxMWFlat.P8   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P8    =  Smooth30.MWhrFlat.P8    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P9 =  Smooth30.MaxMWSmooth.P9 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P9  =  Smooth30.MWhrSmooth.P9  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P9   =  Smooth30.MaxMWFlat.P9   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P9    =  Smooth30.MWhrFlat.P9    .* DataProc.OxfordMax;

Scaled.Smooth30.MaxMWSmooth.P90 =  Smooth30.MaxMWSmooth.P90 .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrSmooth.P90  =  Smooth30.MWhrSmooth.P90  .* DataProc.OxfordMax;
Scaled.Smooth30.MaxMWFlat.P90   =  Smooth30.MaxMWFlat.P90   .* DataProc.OxfordMax;
Scaled.Smooth30.MWhrFlat.P90    =  Smooth30.MWhrFlat.P90    .* DataProc.OxfordMax;



%%%%%%%%%%%%%%%%%%%%%%%%% SMOOTH60 MIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scaled.Smooth60.MaxMWSmooth.P1 =  Smooth60.MaxMWSmooth.P1 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P1  =  Smooth60.MWhrSmooth.P1  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P1   =  Smooth60.MaxMWFlat.P1   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P1    =  Smooth60.MWhrFlat.P1    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P2 =  Smooth60.MaxMWSmooth.P2 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P2  =  Smooth60.MWhrSmooth.P2  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P2   =  Smooth60.MaxMWFlat.P2   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P2    =  Smooth60.MWhrFlat.P2    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P3 =  Smooth60.MaxMWSmooth.P3 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P3  =  Smooth60.MWhrSmooth.P3  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P3   =  Smooth60.MaxMWFlat.P3   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P3    =  Smooth60.MWhrFlat.P3    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P4 =  Smooth60.MaxMWSmooth.P4 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P4  =  Smooth60.MWhrSmooth.P4  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P4   =  Smooth60.MaxMWFlat.P4   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P4    =  Smooth60.MWhrFlat.P4    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P5 =  Smooth60.MaxMWSmooth.P5 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P5  =  Smooth60.MWhrSmooth.P5  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P5   =  Smooth60.MaxMWFlat.P5   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P5    =  Smooth60.MWhrFlat.P5    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P6 =  Smooth60.MaxMWSmooth.P6 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P6  =  Smooth60.MWhrSmooth.P6  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P6   =  Smooth60.MaxMWFlat.P6   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P6    =  Smooth60.MWhrFlat.P6    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P7 =  Smooth60.MaxMWSmooth.P7 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P7  =  Smooth60.MWhrSmooth.P7  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P7   =  Smooth60.MaxMWFlat.P7   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P7    =  Smooth60.MWhrFlat.P7    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P8 =  Smooth60.MaxMWSmooth.P8 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P8  =  Smooth60.MWhrSmooth.P8  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P8   =  Smooth60.MaxMWFlat.P8   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P8    =  Smooth60.MWhrFlat.P8    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P9 =  Smooth60.MaxMWSmooth.P9 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P9  =  Smooth60.MWhrSmooth.P9  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P9   =  Smooth60.MaxMWFlat.P9   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P9    =  Smooth60.MWhrFlat.P9    .* DataProc.OxfordMax;

Scaled.Smooth60.MaxMWSmooth.P90 =  Smooth60.MaxMWSmooth.P90 .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrSmooth.P90  =  Smooth60.MWhrSmooth.P90  .* DataProc.OxfordMax;
Scaled.Smooth60.MaxMWFlat.P90   =  Smooth60.MaxMWFlat.P90   .* DataProc.OxfordMax;
Scaled.Smooth60.MWhrFlat.P90    =  Smooth60.MWhrFlat.P90    .* DataProc.OxfordMax;




%%%%%%%%%%%%%%%%%%%%%%%%% SMOOTH90 MIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Scaled.Smooth90.MaxMWSmooth.P1 =  Smooth90.MaxMWSmooth.P1 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P1  =  Smooth90.MWhrSmooth.P1  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P1   =  Smooth90.MaxMWFlat.P1   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P1    =  Smooth90.MWhrFlat.P1    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P2 =  Smooth90.MaxMWSmooth.P2 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P2  =  Smooth90.MWhrSmooth.P2  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P2   =  Smooth90.MaxMWFlat.P2   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P2    =  Smooth90.MWhrFlat.P2    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P3 =  Smooth90.MaxMWSmooth.P3 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P3  =  Smooth90.MWhrSmooth.P3  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P3   =  Smooth90.MaxMWFlat.P3   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P3    =  Smooth90.MWhrFlat.P3    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P4 =  Smooth90.MaxMWSmooth.P4 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P4  =  Smooth90.MWhrSmooth.P4  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P4   =  Smooth90.MaxMWFlat.P4   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P4    =  Smooth90.MWhrFlat.P4    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P5 =  Smooth90.MaxMWSmooth.P5 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P5  =  Smooth90.MWhrSmooth.P5  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P5   =  Smooth90.MaxMWFlat.P5   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P5    =  Smooth90.MWhrFlat.P5    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P6 =  Smooth90.MaxMWSmooth.P6 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P6  =  Smooth90.MWhrSmooth.P6  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P6   =  Smooth90.MaxMWFlat.P6   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P6    =  Smooth90.MWhrFlat.P6    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P7 =  Smooth90.MaxMWSmooth.P7 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P7  =  Smooth90.MWhrSmooth.P7  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P7   =  Smooth90.MaxMWFlat.P7   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P7    =  Smooth90.MWhrFlat.P7    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P8 =  Smooth90.MaxMWSmooth.P8 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P8  =  Smooth90.MWhrSmooth.P8  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P8   =  Smooth90.MaxMWFlat.P8   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P8    =  Smooth90.MWhrFlat.P8    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P9 =  Smooth90.MaxMWSmooth.P9 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P9  =  Smooth90.MWhrSmooth.P9  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P9   =  Smooth90.MaxMWFlat.P9   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P9    =  Smooth90.MWhrFlat.P9    .* DataProc.OxfordMax;

Scaled.Smooth90.MaxMWSmooth.P90 =  Smooth90.MaxMWSmooth.P90 .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrSmooth.P90  =  Smooth90.MWhrSmooth.P90  .* DataProc.OxfordMax;
Scaled.Smooth90.MaxMWFlat.P90   =  Smooth90.MaxMWFlat.P90   .* DataProc.OxfordMax;
Scaled.Smooth90.MWhrFlat.P90    =  Smooth90.MWhrFlat.P90    .* DataProc.OxfordMax;




%%
% % 
for y= 1:365
Scaled.FlatDFP.P1(1,y) = FlatDFP.P1(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P2(1,y) = FlatDFP.P2(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P3(1,y) = FlatDFP.P3(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P4(1,y) = FlatDFP.P4(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P5(1,y) = FlatDFP.P5(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P6(1,y) = FlatDFP.P6(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P7(1,y) = FlatDFP.P7(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P8(1,y) = FlatDFP.P8(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P9(1,y) = FlatDFP.P9(1,y) .* DataProc.OxfordMax(1,y) ;
Scaled.FlatDFP.P90(1,y) = FlatDFP.P90(1,y) .* DataProc.OxfordMax(1,y) ;
 
end
%%



save('Y:\Research\Osama\Revisions_1min15306090',  '-v7.3')


% % 
% % save('Y:\Research\Osama\Smooth15', 'Smooth15', '-v7.3')
% % save('Y:\Research\Osama\Smooth30', 'Smooth30', '-v7.3')
% % save('Y:\Research\Osama\Smooth60', 'Smooth60', '-v7.3')
% % save('Y:\Research\Osama\Smooth90', 'Smooth90', '-v7.3')
% % 
% % 
