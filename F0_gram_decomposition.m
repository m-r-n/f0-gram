% ===================================
% labelling of MULTIPLE main dominant harmonic lineS by looking up
% possible corresponding musical notes.

%
% based on on F0gram labelling, 
% 2020/01/03
%
%
% ===================================

% 1. extract main peaks
% 2. remove the main peaks
% 3. write the new slice of the F0-gram into a new reindFrames matrix_type

% ===================================
%% F0-gram description
% ===================================

% input: reindFrames, size: nFrames x 200
[rX, rY] = size (reindFrames)

% create the new reindFrame which will have the main notes Deleted.
%reindFrames2 = zeros (rX, rY);
reindFrames2 = reindFrames;
reindFrames3 = reindFrames;

% this time w subplot
figure(21); clf;
subplot(211)
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
stepX = 10
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
  %subplot(211)
  %text(intFrom, floor(indexAA-5), num2str(indexAA));
  
  % display the note
  ll = floor(indexAA/3);
  subplot(211)
  text(intFrom, floor(indexAA+5), notes(ll+1,:));
  
  % display sailence
  meanAA = mean(AA);
  sailence = floor(maxAA/meanAA);
  %subplot(212)
  %text(intFrom, floor(indexAA), num2str(sailence));
   
  % ERASE the reindGram part AROUND the note in the new GRam
  resetValue = meanAA;
  eraseFrom = indexAA-3;
  eraseTo = indexAA + 3;
  for ii=intFrom:intTo
    reindFrames2(intFrom:intTo, eraseFrom:eraseTo) = resetValue;
    end;
   
 
  end %of the frame loop
 
% ===================================
%% Show the gam w/o the dominant peak
% ===================================
 
subplot(212)
imagesc(reindFrames2')
colormap(jet);
% ===================================
% extract the next note from the new GRam
% ===================================
 for i = 1:nNotes
  % integrate the reindGram in order to see the max peak 
  intFrom = (i-1)*stepX + 1;  
  intTo  = i*stepX;  
  AA = sum (reindFrames2(intFrom:intTo,:), 1);
  
  % apply some basic logic to check if the max peak is a Note
    
  % decode the max peak
  [maxAA, indexAA] = max (AA);
  
  % display the max Index
  %subplot(211)
  %text(intFrom, floor(indexAA-5), num2str(indexAA));
  
  % display the note
  ll = floor(indexAA/3);
  subplot(211)
  text(intFrom, floor(indexAA+5), notes(ll+1,:));
  
  % display sailence
  meanAA = mean(AA);
  sailence = floor(maxAA/meanAA);
  subplot(212)
  text(intFrom, floor(indexAA), num2str(sailence));
   
  % ERASE the reindGram part AROUND the note in the new GRam
  resetValue = meanAA;
  eraseFrom = indexAA-3;
  eraseTo = indexAA + 3;
  for ii=intFrom:intTo
    reindFrames3(intFrom:intTo, eraseFrom:eraseTo) = resetValue;
    end;
   
 
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
