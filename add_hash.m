function [N,T,H,thop] = add_hash(D, TSKIP, TDUR, dens, FILE_TYPE)
% [N,T,H,thop] = add_hash(D, TSKIP, TDUR, dens)
%    Add audio files to the hashtable database.  
%    D is a cell array of paths to audio files.
%    dens is hash density per second (default 7).
%    TSKIP > 0 drops that many seconds of sound from the start of
%    each file read, then TDUR truncates to at most that time.
%    existing ref item.
%    N returns the total number of hashes added, T returns total
%    duration in secs of tracks added.
%
% 2011-12-01 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2;  TSKIP = 0; end
if nargin < 3;  TDUR = 0; end

% Target query landmark density
% (reference is 7 lm/s)
if nargin < 4; dens = 7; end

tstart = tic;

nd = length(D);
N = 0;
T = 0;
H = [];
thop = 0;

  targetsr = 11025;
  forcemono = 1;
  [d,sr] = audioread(D,targetsr,forcemono,TSKIP,TDUR, FILE_TYPE);
%  maxdur = 1200;  % truncate at 20 min
%  actdur = length(d)/sr;
%  if actdur > maxdur
%    if ~quiet
%      disp(['truncating ',F,' (dur ',sprintf('%.1f',actdur),' s) at ', ...
%            num2str(maxdur),' s']);
%    end
%    d = d(1:(maxdur*sr),:);
%  end
  
  if length(d) == 0
    H = [];
    n = 0;
    t = 0;
    thop = 0;
  else
    
    oversamp = 1;
    [LM,thop] = find_landmarks(d,sr,dens,oversamp);
    H = landmark2hash(LM);
    disp(num2str(H));
  end


clocktime = toc(tstart);