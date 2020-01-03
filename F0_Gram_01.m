% ===========================================
% mrn.pass
% written in Octave (Matlab uses slightly different routines for Audio)
%
% 2019.07.07 : 1st version w linear freq_axis
% 2019.12.07 : 2nd verison w musical scale axis
% 2019.12.12 : 3rd verison w musical scale axis and Formant-Filter (LUT)
%============================================
% To Do:
% - apply pitch-sync framing, in order to suppress pitch line discontinuity, 
% - use non-linear Axis for Musical scales.
% - use linear Axis for voice pitch extraction
% - extract musical scales from pitch candidates
% - implement AGC on spectral bins over time.
% - Biz. 
%============================================
% Sound Sources:
% https://samplefocus.com/categories/piano
%============================================
% load wav
% Marian> 1/2/3/4
%[x, Fs]=audioread('1234_4sec_22k.wav');

% Flora> 1/2/3/4
%[x, Fs]=audioread('1234_4sec_22k_Flora.wav');

% Piano
%[x, Fs]=audioread('sa20_zong_03.wav');

% kENDRICK
%[x, Fs]=audioread('love_s_gonna_get_you_killed.wav');
%[x, Fs]=audioread('kendric_1st_chords.wav');


% piano
%[x, Fs]=audioread('chords01.wav');
%[x, Fs]=audioread('lil_pianpo_part1.wav'); % ok w labelling
[x, Fs]=audioread('chords.wav');
% play
player = audioplayer (x, Fs, 16);
play (player);

%=====================
% define frameLEngth, StepSize etc.
%=====================
segLen = 512;
%segLen = 1024
segStep = 256
  %Fs = 22050
  Nfft = 2048
  
  signalIsPiano = 1
  signalIsVoice = 0

nSamples = size(x,1)
nFrames=floor((nSamples-segStep)/segStep)

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
   spec = (0.01 + fft(frame2proc, Nfft));
   %spec = (0.001+ abs(fft(inputFrame, Nfft)))
   specFrames(i, :) = log10(abs(spec(1:segLen))); % we cut the gram
   anglFrames(i, :) = angle(spec(1:segLen));    % we cut the gram
   
  endfor

  % test spect of frame nr frame2LookAt
  figure (10)
  subplot(312)
  plot(specFrames(frame2LookAt,1:300));
  
  %=====================
  % show spectrogram
  %=====================
  figure (11)
  subplot(211)
  imagesc(specFrames(:,1:300)');
  title(['Spectrogram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('Audio frame index [-]')
  ylabel ('11.000Hz ------------ Linear Frequency axis ----------- 0 Hz')
  
  %=====================
  % prepare reindexing
  %=====================
 
  plotSubresults = 1;
  
  if signalIsPiano,
    [LUT1, LUT2, minF0, maxF0] = create_reind_LUTs_4music(Fs, Nfft, plotSubresults);
    disp ('!!! Analyzing w Piano scale. !!!')
  elseif signalIsVoice
    [LUT1, LUT2, minF0, maxF0] = create_reind_LUTs_4voice(Fs, Nfft, plotSubresults);
    disp ('!!! Analyzing w Linear Pitch scale. !!!')
    endif
  
  %=====================
  % perform reindexing
  %=====================
  
  % the dim.200 is hard-coded in the LUT generator routine.
  reindFrames = zeros (nFrames, 200);
  
  plotThisFrame = 0; % do not plot every frame during reindexing
  tic;
  for i=1:nFrames,
    %disp ([num2str(i), '. frame Processed, out of ', num2str(nFrames)])
    reindFrames(i, :) = reind_one_frame(frames(i, :), Fs, Nfft, minF0, maxF0, LUT1, LUT2, plotThisFrame);
    endfor
   toc;
  
  
  % add a plot below the spectrogram
  
  figure(11)
  subplot(212)
  colormap(jet);
  imagesc(reindFrames')
  title(['Fo-Gram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('Audio frame index [-]')
  %ylabel ('pitch -50Hz')
  ylabel ('880Hz --------- 440Hz --------- 220Hz --------- 110Hz --------- 55Hz')
  
  % create a new plot  for note-picking
  
  figure(21)
  clf
  %subplot(212)
  colormap(jet);
  imagesc(reindFrames')
  title(['Fo-Gram,  segLen=', num2str(segLen), ',  Nfft=', num2str(Nfft)])
  xlabel ('Audio frame index [-]')
  %ylabel ('pitch -50Hz')
  ylabel ('880Hz --------- 440Hz --------- 220Hz --------- 110Hz --------- 55Hz')
  
  
  
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
  %ylabel ('pitch -50Hz + dist over conv')
  ylabel ('880Hz --------- 440Hz --------- 220Hz --------- 110Hz --------- 55Hz')
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
  %ylabel ('pitch -50Hz + dist over conv')
  ylabel ('880 ---------- 440Hz ---------- 220Hz ---------- 110Hz ---------- 55Hz')
 
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
  
  
