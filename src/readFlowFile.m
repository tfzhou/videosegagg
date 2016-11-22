% read ldof
function flow = readFlowFile(fName)

  fp = fopen(fName, 'rb');

  c = fread(fp, 1, 'float=>float');

  w = fread(fp, 1, 'int32=>int32');
  h = fread(fp, 1, 'int32=>int32');

  tt = fread(fp, w*h*2, 'float=>float');
  tt = reshape(tt, [2, w, h]);

  vx = squeeze(tt(1,:,:))';
  vy = squeeze(tt(2,:,:))';

  flow = cat(3, vx, vy);
  
  fclose(fp);
