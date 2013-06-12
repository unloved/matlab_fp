function [N,T,P,Lq] = match_hash(F,TSKIP,TDUR,DENS,OSAMP, FILE_TYPE)
% [R,N,T,P,L,Lq] = match_hash(F,TSKIP,TDUR,DENS,OSAMP,QUIET)
%     Match landmarks from an audio query against the database.
%     Rows of R are potential maxes, in format
%      songID  modalDTcount modalDT totalCommonCount
%     i.e. there were <modalDTcount> occurrences of hashes 
%     that occurred in the query and reference with a difference of 
%     <modalDT> frames (of 32ms).  Positive <modalDT> means the
%     query matches after the start of the reference track.
%     N returns the number of landmarks for this query and T
%     returns its total duration.
%     P is the frame period of analysis in seconds.
%     L returns the actual landmarks that this implies for IX'th return.
%     as rows of <time in match vid> f1 f2 dt <timeskew of query>
%     Lq returns the landmarks for the query.
%     DENS and OSAMP are arguments to landmark calculation.
%     TSKIP > 0 drops that many seconds of sound from the start of
%     each file read, then TDUR truncates to at most that time.
% 2008-12-29 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2;  TSKIP = 0; end
if nargin < 3;  TDUR = 0; end
if nargin < 4;  DENS = 20;  end
if nargin < 5;  OSAMP = 0;  end

targetsr = 11025;
forcemono = 1;
[D,SR] = audioread(F,targetsr,forcemono,TSKIP,TDUR, FILE_TYPE);
T = length(D)/SR;

if length(D) == 0
  R = zeros(0,4);
  N = 0;
  T = 0;
  P = 0;
  L = [];
  Lq = [];
  return
end

if OSAMP == 0
  % special case - analyze each track four times & merge results
  % slow, but gives best results
  [Lq,P] = find_landmarks(D,SR, DENS, OSAMP);
  %Lq = fuzzify_landmarks(Lq);
  % Augment with landmarks calculated half-a-window advanced too
  landmarks_hopt = 0.032;
  Lq = [Lq;find_landmarks(D(round(landmarks_hopt/4*SR):end),SR, ...
                          DENS, OSAMP)];
  Lq = [Lq;find_landmarks(D(round(landmarks_hopt/2*SR):end),SR, ...
                          DENS, OSAMP)];
  Lq = [Lq;find_landmarks(D(round(3*landmarks_hopt/4*SR):end),SR, ...
                          DENS, OSAMP)];
  % add in quarter-hop offsets too for even better recall
else
  [Lq,P] = find_landmarks(D,SR, DENS, OSAMP);
end

%Hq = landmark2hash(Lq);
Hq = unique(landmark2hash(Lq), 'rows');
disp(Hq);

N = length(Hq);