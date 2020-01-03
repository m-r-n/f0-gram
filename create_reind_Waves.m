
%===================================================================
% The Reindexing PEAK has a shape, which resembles a mexican hat
% We try to define a fitting curve on that (hamming weighted sin).
% maybe best way is to extract it from the signal itself.
% 2019-07-10
%===================================================================

clear t;
clear Wave;
clear Wave1;
clear Wave2;
clear Wave3;

winLen = 52;                 % length /in samples/ of the weighting function
sinLen = round (winLen/2.5); % how many samples corresponds to 2Pi?

% ----------------
t=1:winLen;         % time axis of the weighting curve       
t = 2*pi*t/sinLen;  % resampling time 
Wave = sin(t);      % fitting Sine in time
% ----------------
w= hamming (winLen);
Wave1 = w'.*Wave;    % weighting the sine w Hamming
% ----------------
w= hanning (winLen);
Wave2 = w'.*Wave;    % weighting the sine w Hanning
% ----------------
figure(8)
clf;
hold on;
plot(Wave1, 'b')
plot(Wave2, 'r')
title('Wave1 - Hamming, Wave2 - Hanning')
% ----------------