  
  % 1. use wav_io_test to load frames of audio
  %    and to save them in "frames".
  
  frameInd = 200 % which frame to test
  Fs = 22050
  Nfft = 2048
  plotThisFrame = 1; % plot or not
  
  % 2. then use create_reind_LUTs to generate the lookup tables
  [LUT1, LUT2, minF0, maxF0] = create_reind_LUTs
  
  % 3. reindexing of oe frame:
  
  for i=frameInd:frameInd,
    disp ([num2str(i), '. frame out of ', num2str(nFrames)])
    
     reindFrames(i, :) = reind_one_frame(frames(i, :), Fs, Nfft, minF0, maxF0, LUT1, LUT2, plotThisFrame);
  
   endfor