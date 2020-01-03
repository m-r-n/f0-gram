% =====================
% mrn.pass
% 
% 2019.07.07
%======================

% load wav
%Marian> 1/2/3/4
[x, Fs]=audioread('1234_4sec_22k.wav');

%Flora> 1/2/3/4
[x, Fs]=audioread('1234_4sec_22k_Flora.wav');

%Zongora
[x, Fs]=audioread('sa20_zong_03.wav');

% play
player = audioplayer (x, Fs, 16);
play (player);

% define frameLEngth, StepSize etc.

segLen = 512;
%segLen = 1024
segStep = 256
  %Fs = 22050
  Nfft = 2048

nSamples = size(x,1)
nFrames=floor(nSamples/segStep)

%=====================
% cut into frames
%=====================

frames = zeros (nFrames, segLen);
size(frames);

semiFrameLen = segLen/2

for i=1:nFrames,
  midInd = i*semiFrameLen;
  startInd = midInd - segLen/2 +1;
  endInd   = midInd + segLen/2;
  frames(i, :)= x(startInd:endInd);
  endfor

  % show frame nr frame2LookAt
  frame2LookAt = 150
  figure (10)
  subplot(311)
  plot(frames(frame2LookAt,:));
  
 %===================== 
 % calcul. spectrogram
 %=====================
 specFrames = zeros (nFrames, segLen);
 anglFrames = zeros (nFrames, segLen);
 
size(specFrames);

 for i=1:nFrames,
   frame2proc = frames(i, :);
   spec = (0.00001 + fft(frame2proc));
   specFrames(i, :) = abs(spec);
   anglFrames(i, :) = angle(spec);
   
  endfor

  % test spect of frame nr frame2LookAt
  figure (10)
  subplot(312)
  plot(specFrames(frame2LookAt,1:300));
  
  %=====================
  % perform reindexing
  %=====================
  % the 200 is hard-coded in the LUT generator routine.
  reindFrames = zeros (nFrames, 200);
  
  plotSubresults = 1;
  [LUT1, LUT2, minF0, maxF0] = create_reind_LUTs(Fs, Nfft, plotSubresults);
 
  plotThisFrame = 0; % do not plot every frame during reindexing
  tic;
  for i=1:nFrames,
    %disp ([num2str(i), '. frame Processed, out of ', num2str(nFrames)])
    reindFrames(i, :) = reind_one_frame(frames(i, :), Fs, Nfft, minF0, maxF0, LUT1, LUT2, plotThisFrame);
  
   endfor
   toc;
  
  figure(11)
  colormap(jet);
  imagesc(reindFrames')
  title(['Fo-Gram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('frame index')
  ylabel ('pitch -50Hz')
  
  %=====================
  % smoothing the reindexing
  %=====================
  % generate smoothing curve(s)
  create_reind_Waves;

  % initialize smoothed gram 
  newLen = 200 + length(Wave1) -1
  smoothedFrames = zeros (nFrames, newLen);
  
  for i=1:nFrames,
     smoothedFrames (i, :) = conv (reindFrames(i, :), Wave1);
   endfor

   % extract voicyness after reindexing:
  vv0 = max (reindFrames, [], 2); 
  
  % extract voicyness after smoothing:
  vv1 = max (smoothedFrames, [], 2); 
  
  figure(12)
  colormap(jet);
  imagesc(smoothedFrames')
  title(['W1-smoothed Fo-Gram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('frame index')
  ylabel ('pitch -50Hz + dist over conv')
   %=====================
  % smoothing the reindexing
  %=====================

  newLen = 200 + length(Wave2) -1
  smoothedFrames = zeros (nFrames, newLen);
  
  for i=1:nFrames,
     smoothedFrames (i, :) = conv (reindFrames(i, :), Wave2);
     endfor
  % extract voicyness after smoothing:
  vv2 = max (smoothedFrames, [], 2);
  
  figure(13)
  colormap(jet);
  imagesc(smoothedFrames')
  title(['W2-smoothed Fo-Gram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('frame index')
  ylabel ('pitch -50Hz + dist over conv')
 
  %=========================================
  % Look at Reindexing and Smoothing of frame nr frame2LookAt
  %=========================================
 
 figure (13)
  clf;
  %subplot(313)
  plot(reindFrames(frame2LookAt,:));
  hold on
  tShift = 25; % floor (length(Wave2)+1);
  plot(smoothedFrames(frame2LookAt, 1+tShift:200+tShift)/10);
  grid on;
  
  %=========================================
  % Look at Voicyness / voicing, VAD, whatever
  %=========================================
 
 % REMARK:
  % max and min looks the same before and after smoothing.
  figure (14)
  clf;
  plot(4*vv0, 'r');
  hold on
  plot(vv1, 'g');
  plot(vv2, 'b');
  grid on;
  title('Max of Fr.Dom.Smoothed ...: R- reindexing, G - FeqSmoothing 1, B - FreqSmoothing 2')
  
  %================================================
  % Smoothing the Voicing Activity Curve over Time
  %================================================
  %[b, a]= butter(3, 0.2);
  %w = linspace (0, 4, 128);
 
  %figure(15)
  %freqs (b, a, w);
  %vv0_filtered = filter(b, a, vv1);
   
  vvS0 = vv0(1:end-4)+vv0(2:end-3)+vv0(3:end-2)+vv0(4:end-1)+vv0(5:end);
  vvS1 = vv1(1:end-4)+vv1(2:end-3)+vv1(3:end-2)+vv1(4:end-1)+vv1(5:end);
  vvS2 = vv2(1:end-4)+vv2(2:end-3)+vv2(3:end-2)+vv2(4:end-1)+vv2(5:end);

  figure(15);
  clf;
  hold on
  grid
  plot(4*vvS0, 'r')
  plot(vvS1, 'g')
  plot(vvS2, 'b') 
  title('Time-Domain Smoothed Max of Fr.Dom-Smoothed ...: R- reindexing, G - FreqSmoothing 1, B - FreqSmoothing 2')
  
  %================================================
  % Extracting Pitch from Reindexing, Voicing Activity 
  %================================================
  
  pitchCurve = zeros(1, nFrames);
  voicingAD  = zeros(1, nFrames);
  
  voicingThr = 4000;
  for i=1:(nFrames-10) % vvS2 is shorter, not nFrame
    if (vvS2(i)>voicingThr)
      voicingAD(i)=1;
      [maxVal, maxInd]=max(smoothedFrames(i, 1:200));
      %maxInd
      pitchCurve(i)=maxInd;
    end % if
  end % for
  
  figure(16)
  subplot(211)
  plot(voicingAD)
  title('Voicing Activity Detection')
  xlabel('frame Index')
    
  subplot(212)
  plot(pitchCurve)
  title('pitchCurve')
  xlabel('frame Index')
  
  
