% -------------------------------------------------------------
%            Creating Lookup-Tables for the Reindexing
%
% This code is based on the following conference papers:
% [1] M. Kepesi, L. Weruaga, E. Schofield: Detailed Multidimensional Analysis of our Acoustical Environment,” 
%     Forum Acusticum. Budapest (Hu), September 2005, pp. 2649-2654.
% [2] M. Kepesi and L. Weruaga: High-resolution noise-robust spectral-based pitch estimation,” 
%     Interspeech 2005, pp. 313-316, Lisboa (P), Sep. 2005
% See also https://signalprocessingideas.wordpress.com/2008/12/07/spectral-reindexing-for-pitch-estimation/
%         contact: mrn-at-post in cz
% -------------------------------------------------------------

function [LUT1, LUT2, minF0, maxF0] = create_reind_LUTs (Fs, Nfft, plotSubresults)
  
  % LUT1 will store the indices of positive spectral components
  % LUT2 will store the indices of negative spectral components

% -------------------------------------------------------------
% 	Define Parameters
% -------------------------------------------------------------

%Fs = 22050
%Nfft = 4096 % leads to extreme sharp results.
%Nfft = 2048
freqPerBin = Fs/Nfft

noHarmonics = 5;  % number of harmonix used
% -------------------------------------------------------------
% -------------- Define Freq Axis for the LUT -----------------
% -------------------------------------------------------------

% hanyados a szomszedos Hz ertekek között:
%xZo = nthroot (2, 12) % - felhangonkent
%xZo = nthroot (2, 36) % - 1/3-felhangonkent
%xZo = nthroot (2, 60) % - 1/5-felhangonkent

%----------
minF0 = 55
%----------

% hanyados a szomszedos Hz ertekek között:
xZo = nthroot (2, 36) % - 1/3-felhangonkent

pitchAxis = minF0*ones(1, 200);
pitchAxix = minF0.*pitchAxis;
xZoVector = ones(1, 200);
for i=2:200
  xZoVector(i)=xZo * xZoVector(i-1);
  pitchAxis(i)=xZoVector(i) * pitchAxis(i);
end

%figure(2)
%subplot(211);plot(xZoVector)
%subplot(212);plot(pitchAxis)



% -------------------------------------------------------------
% -------------- reindexing LU Vector preparaion --------------
% -------------------------------------------------------------

% original, linear pitch axis leads-to non-linear reindexing shape
% for high F0s, therefore nonlinear is used below.

% --1-- Linear Way
%pitchAxis = minF0:maxF0;

% --2-- nonLinear Way
%nonlinearity introduced by division
%minF0 = 55
%maxF0 = 00
%f0 = linspace(1000/minF0, 1000/maxF0, 200);
%pitchAxis = 1000./f0;

% --3-- musical scale


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

% -------------------------------------------------------------
% ---------- storing the LU vectors into 2 LUTs ---------------
% -------------------------------------------------------------
LUT1 = zeros (5, 200);
LUT2 = zeros (5, 200);

% positive Spectral components
LUT1(1, :) = round(pitAxis1);
LUT1(2, :) = round(pitAxis2);
LUT1(3, :) = round(pitAxis3);
LUT1(4, :) = round(pitAxis4);
LUT1(5, :) = round(pitAxis5);

% negative Spectral components
LUT2(1, :) = round(pitAxis1n);
LUT2(2, :) = round(pitAxis2n);
LUT2(3, :)  = round(pitAxis3n);
LUT2(4, :)  = round(pitAxis4n);
LUT2(5, :)  = round(pitAxis5n);

% -------------------------------------------------------------
% ------------- plot the scanning curves ----------------------
% -------------------------------------------------------------
if plotSubresults
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
  end;