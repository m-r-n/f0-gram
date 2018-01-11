% -------------------------------------------------------------
%                             popi_demo
%
% This code is based on the following conference papers:
% [1] M. Képesi, L. Weruaga, E. Schofield, “Detailed Multidimensional Analysis of our Acoustical Environment,” 
%     Forum Acusticum. Budapest (Hu), September 2005, pp. 2649-2654.
% [2] M. Képesi and L. Weruaga, “High-resolution noise-robust spectral-based pitch estimation,” 
%     Interspeech 2005, pp. 313-316, Lisboa (P), Sep. 2005
% See also https://signalprocessingideas.wordpress.com/2008/12/07/spectral-reindexing-for-pitch-estimation/
%         contact: mrn-at-post in cz
% -------------------------------------------------------------

% here run "rec_waves_01" to record S1 and S2
disp ('----------- jan4---------------')

% -------------------------------------------------------------
% 	Load Data
% -------------------------------------------------------------
% loading example waves, also present on https://github.com/m-r-n > wavesurfing.
load "waves_s1_s2"
Fs = 22050
Nfft = 4096
freqPerBin = Fs/Nfft
%cut part of s1:
startInd=1
endInd=startInd+2000-1
%ss1= s1(startInd:endInd);
ss2 =s2(startInd:endInd);

figure 100; clf
subplot(211); plot(ss2)
title("vowel")

noHarmonics = 5;  % number of harmonix used
minF0 = 50
maxF0 = 249


% --- spectrum of a frame --- 
spZ1=20*log (0.0001+ abs(fft(ss2, Nfft)));

figure 100
subplot(212);
plot(spZ1(1:400));grid
xlabel("freq.bin index")
title(["logSpectr, Hz/Bin: ", num2str(freqPerBin)])

% --- reindexing LUT preparaion ---

pitchAxis= minF0:maxF0;
pitchAxis = pitchAxis/freqPerBin;
pitAxis1 = pitchAxis;
pitAxis2 = 2*pitAxis1;
pitAxis3 = 3*pitAxis1;
pitAxis4 = 4*pitAxis1;
pitAxis5 = 5*pitAxis1;

pitAxis1n = 1.5*pitAxis1;
pitAxis2n = 2.5*pitAxis1;
pitAxis3n = 3.5*pitAxis1;
pitAxis4n = 4.5*pitAxis1;
pitAxis5n = 5.5*pitAxis1;

% plot the scanning curves
figure 102; clf; 
hold on
xlabel(["f0-", num2str(minF0), "[Hz]"])
ylabel("corresponding spectral bin index")
title(["freqPerBin: ", num2str(freqPerBin)]);
grid
plot(pitAxis1, 'r')
plot(pitAxis2, 'g')
plot(pitAxis3, 'c')
plot(pitAxis4, 'k')
plot(pitAxis5, 'r')

plot(pitAxis1n, 'r-.')
plot(pitAxis2n, 'g-.')
plot(pitAxis3n, 'c-.')
plot(pitAxis4n, 'k-.')
plot(pitAxis5n, 'r-.')

% positive Spectral components
reindSpec1 = spZ1(round(pitAxis1));
reindSpec2 = spZ1(round(pitAxis2));
reindSpec3 = spZ1(round(pitAxis3));
reindSpec4 = spZ1(round(pitAxis4));
reindSpec5 = spZ1(round(pitAxis5));

% negative Spectral components
reindSpec1n = spZ1(round(pitAxis1n));
reindSpec2n = spZ1(round(pitAxis2n));
reindSpec3n = spZ1(round(pitAxis3n));
reindSpec4n = spZ1(round(pitAxis4n));
reindSpec5n = spZ1(round(pitAxis5n));

figure 101; clf;
subplot(211)
hold on; 
plot(reindSpec1,'r')
plot(reindSpec2,'b')
plot(reindSpec3,'c')
plot(reindSpec4,'k')
plot(reindSpec5,'r')

plot(reindSpec1n,'r-.')
plot(reindSpec2n,'b-.')
plot(reindSpec3n,'c-.')
plot(reindSpec4n,'k-.')
plot(reindSpec5n,'r-.')
grid on;
xlabel(["f0-", num2str(minF0), "[Hz]"])
ylabel("lo-spectral enery")

% ---- fast Reindexing ----
sumReindPlus = reindSpec1 + reindSpec2 + reindSpec3 + reindSpec4 + reindSpec5;
sumReindMinus = reindSpec1n + reindSpec2n + reindSpec3n + reindSpec4n + reindSpec5n;
sumReind = sumReindPlus - sumReindMinus/2;

% ---- plot  results ----
figure 101; 
subplot(212); hold on
title(["Reind +/-(red/black) an final (blue)freqPerBin: ", num2str(freqPerBin)]);
xlabel (["f0-", num2str(minF0), "[Hz]"])
plot(sumReindPlus, 'r')
plot(sumReindMinus, 'k')
plot(sumReind, 'b')
grid


