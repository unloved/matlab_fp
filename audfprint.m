function audfprint(varargin)
% audfprint(varargin)
% Utility to create audio fingerprint databases and match audio
% files to it.
%
% Usage;
%   audfprint [options]
%
%   See http://labrosa.ee.columbia.edu/projects/audfprint
%   for full documentation
%
% 2011-08-21 Dan Ellis dpwe@ee.columbia.edu
% $Header: $

VERSION = 0.82;
DATE = 20130527;

% Parse out the optional arguments
[ADD, MATCH, DENSITY, ...
 OVERSAMP, ...
 SKIP, MAXDUR, ...
 XTRA] = ...
    process_options(varargin, ...
                    '-add', '', ...
                    '-match', '', ...
                    '-density', 7, ...
                    '-oversamp', 0, ...
                    '-skip', 0, ...
                    '-maxdur', 0);

HELP = 0;
if length(XTRA) > 0
  % if -add or -match are specified, add extra options to that
  if length(ADDFILES)
    ADDFILES = [ADDFILES, XTRA];
  elseif length(MATCHFILES)
    MATCHFILES = [MATCHFILES, XTRA];
  elseif length(REMOVEFILES)
    REMOVEFILES = [REMOVEFILES, XTRA];
  else
    % don't know what the extra options are
    HELP = length(strmatch('-help',XTRA,'exact')) > 0;
    if ~HELP
      disp(['Unrecognized options:',sprintf(' %s',XTRA{1:end})]);
      HELP = 1;
    end
  end
end

if HELP
  disp(['audfprint v',num2str(VERSION),' of ',num2str(DATE)]);
  disp('usage: audfprint ...');
  disp('   -add <file ...>   Sound file(s) to add to database');
  disp('   -density <num>    Target hashes/sec (default: 7.0)');
  disp('   -match <file ...> Audio file(s) to match');
  disp('   -oversamp <num>   oversampling factor for queries (0..special)');
  disp('   -skip <time>      drop time from start of each sound');
  disp('   -maxdur <time>    truncate soundfiles at this duration (0=all)');
  return
end

HOPTIME = 0;

if (ADD)
    [N,T,H,HOPTIME] = add_hash(ADD, SKIP, MAXDUR, DENSITY);
end

if (MATCH)
    [R,N,T,HOPTIME] = match_hash(MATCH, SKIP, MAXDUR, DENSITY, OVERSAMP);
end
