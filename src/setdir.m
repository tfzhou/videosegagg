function p = setdir( p )

if ~exist(p, 'dir')
  system(['mkdir -p ' p]);
end