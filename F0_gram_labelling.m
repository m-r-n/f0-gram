
% ===================================
% defining the labels
% ===================================


octave1 = ["C"; "C#"; "D"; "D#"; "E"; "F"; "F#"; "G"; "G#"; "A"; "A#"; "H"];
octave2 = ["C2";"C#2";"D2";"D#2";"E2";"F2";"F#2";"G2";"G#";"A2";"A#2";"H2"];
octave3 = ["C3";"C#3";"D3";"D#3";"E3";"F3";"F#3";"G3";"G#";"A3";"A#3";"H3"];
octave4 = ["C4";"C#4";"D4";"D#4";"E4";"F4";"F#4";"G4";"G#";"A4";"A#4";"H4"];
octave5 = ["C5";"C#5";"D5";"D#5";"E5";"F5";"F#5";"G5";"G#";"A5";"A#5";"H5"];
octave6 = ["C6";"C#6";"D6";"D#6";"E6";"F6";"F#6";"G6";"G#";"A6";"A#6";"H6"];
octave7 = ["C7";"C#7";"D7";"D#7";"E7";"F7";"F#7";"G7";"G#";"A7";"A#7";"H7"];

notes = ["a"; "a#"; "h"; octave1; octave2; octave3; octave4; octave5; octave6; octave7];

% usage:
for i= 1:5
  notes(i, :)
  end

% ===================================
% decoding
% ===================================

%this is the key line from create_reind_LUTs_4mnusic.m:
%xZo = nthroot (2, 36) % - 1/3-felhangonkent => we are diviging the thing by 3 (36=3*12)
% ...  defining that one octave will be represented by 36 samples in the reindexing gram
% therefore we are going to divide the location of the peak by the same coeff.
% to get the reindexed spectroGram, run F0_Gram_01.m, first!

%coordX = [10,  20,   30,   40,   50]
%coordY = [100, 120, 130, 140, 150]
%labelEk = ["C"; "D";"E"; "F"; "G"]

% ===================================
%% F0-gram description
% ===================================

% input: reindFrames, size: nFrames x 200
[rX, rY] = size (reindFrames)

figure(21); clf;
imagesc(reindFrames')
colormap(jet);
% ===================================
% Init labelling vectors
% ===================================
%coordX = []
%coordY = []
%clear labelEk 
%labelEk = []
% ===================================
% New note found
% ===================================
stepX = 4
nNotes = floor(rX/stepX) % we will look at every 10 frames

for i = 1:nNotes
  % integrate the reindGram in order to see the max peak 
  intFrom = (i-1)*stepX + 1;  
  intTo  = i*stepX;  
  AA = sum (reindFrames(intFrom:intTo,:), 1);
  
  % apply some basic logic to check if the max peak is a Note
    
  % decode the max peak
  [maxAA, indexAA] = max (AA);
  
  % display the max Index
  text(intFrom, floor(indexAA-5), num2str(indexAA));
  
  % display the note
  ll = floor(indexAA/3);
  text(intFrom, floor(indexAA+5), notes(ll+1,:));
  end
  




%coordX = [coordX, 100]
%coordY = [coordY, 100]
%labelEk = [labelEk; "Z"]

% ===================================
% Label the F0-Gram
% ===================================

%figure(21); clf;
%imagesc(reindFrames')
%colormap(jet);
%text(coordX, coordY, labelEk)

% ===================================
