function [ A, maxMWSmooth, BESSrefLineSmooth, BESSapprox2, MWhr ] = PolySama( PVplusLoad ,tail)
% INPOUTS:
% PVplusLoad is a 86400 point vector that is the summation of load data
% obtained and photovoltaic
% tail specifies the # of points that will be observed to get smoothed
% For example 15% minuutes is assed as 0.25*60*60=3600 and so on so forth. 
% OUTPUTS:
% A= PVplusLoad original vector
% maxMWSmooth = MW requirement
% BESSrefLineSmooth = Smootheing accomplished
% BESSapprox2 = unneccesary
% MWhr= MWhr recommendation

tic;                                        % Starts a timer

A = PVplusLoad;                           % Summed PV & Load
C = A';
% Start a for loop to smooth the PV Plus Load over the specified tail value
% parfor is used in this case to utilize parallel processes. Regular for
% loop can be used if speed is not an issue. 

parfor i = tail+1: 86400                % 86400 is max number of points to analyze 
  t = i-tail:i-1;                       % 1800-pt window size (t=1 to 1800)
  magic1 = C(i-tail:i-1);               % Extracts 1800 pts from C=PVplusLoad'
  
                             
  B = polyfit(t,magic1,1);    % Creates best-fit curve for PV+Load data
                              % 'polyfit(x,y,n)' returns coefficients for
                              %   polynomial p(x) of degree n that is a best-fit
                              %   (in a least-squares sense) for the data
                              % Coefficients in p are in descending powers,
                              %   and the length of p is n+1
  
  A(i,:) = polyval(B,i);        % 'polyval(p,x)' returns the value of a polynomial
                              %   of degree n evaluated at x
                              % Input argument p is a vector of length n+1,
                              %   with elements that are coefficients in descending
                              %   powers of the polynomial
                              % 'polyval' evaluates B at each element of i
  
%   i = i + 1;                % Increments loop
end %i<86400

toc;                        % End Timer
%% ESTABLISH TARGET LINE & BESS REFERENCE SIGNAL (Smoothed)

% Straight-Line Target
BESSrefLineSmooth = A - PVplusLoad;         % BESS Reference Signal
                                    %SmoothDFP - PVplusLoad
% BESSrefLineSmooth(isnan(BESSrefLineSmooth))=0;
%% CALCULATE MAX MW REQUIREMENT (Smoothed)

maxMWSmooth = max(abs(BESSrefLineSmooth));
%CHECKmaxMW = max(abs(PVplusLoad - DFP))      % CHECK: = maxMW?
%fprintf('\tRecommended MW Capacity Smoothed PV+Load: %.3f MW\n', maxMWSmooth);


%% DETERMINE MWHRS Smoothed
BESSapprox2= A;                 % This is now the DFP

minusSmoothed= PVplusLoad - A;
hell=cumtrapz(minusSmoothed);
MWhr=max(hell)+abs(min(hell));%%%%% Divide by 36000 to get MWhr. This is not actual MWhr. It is MW24hr

 
end

