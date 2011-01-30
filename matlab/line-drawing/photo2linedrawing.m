function [linedrawing] = photo2linedrawing(photo,preset)
  % thresholds and parameters 
  blur_threshold = 0.1;
  % blur width based on expected thickness of dark lines
  % 10 works well for pen lines in 800x600 image
  % 40 works well for ink marker lines in 800x600 image
  blur_width = 10;
  % intensify the lines by a multiplicative factor
  intensity_scale = 4.0; 
  % If the fill were perfect filled-photo == 0, but its not so we could
  % clip any values below a threshold: fill_epsilon
  fill_epsilon = 0.05;
  % remove speckles of speckle_threshold size or smaller
  speckle_threshold = 0;
  
  % keep width and height handy
  width = size(photo,1);
  height = size(photo,2);
  num_channels = size(photo,3);
  
  % presets for pen on paper drawing
  if(exist('preset','var') && strcmp(preset, 'pen'))
      blur_threshold = 0.1;
      blur_width = 10*(min([width height])/600);
      speckle_threshold = 10*(min([width height])/600);
      intensity_scale = 1.5;
      fill_epsilon = 0.05;
  % presets for ink on paper drawing
  elseif(exist('preset','var') && strcmp(preset, 'ink'))
      blur_threshold = 0.1;
      blur_width = 40*(min([width height])/600);
      speckle_threshold = 2*(min([width height])/600);
      intensity_scale = 1.5;
      fill_epsilon = 0.01;
  elseif(exist('preset','var'))
      error([preset ' is not an existing preset']);
  end
  
  % get edges from of photo
  %	grad = edge(photo(:,:,1)) + edge(photo(:,:,2)) + edge(photo(:,:,3));
  grad = reshape(edge(photo(:,:)),[width height num_channels]);
  grad = sum(grad,3);
  if(speckle_threshold>0)
    grad = double(bwareaopen(grad,round(speckle_threshold)));
  end
  % blur edges with a gaussian kernel somewhat proportional to image size
  h = fspecial('gaussian',round(blur_width),round(blur_width));
  blurred_grad=imfilter(grad,h);
  % normalize
  blurred_grad = blurred_grad./max(max(blurred_grad));
  % mask regions with strong edges
  % mask anything near an edge 
  thresh_grad = blurred_grad > blur_threshold;
  % fill in regions with strong edges, in each channel
  filled = roifill(photo(:,:),repmat(thresh_grad,[1,num_channels]));
  % reshape filled to be same size as photo
  filled = reshape(filled,[width height num_channels]);
  
  % OLD WAY
  %linedrawing = ...
  %  1.0 - ...
  %  (filled-photo)./ ...
  %  repmat(max(max(filled-photo)),[size(photo,1),size(photo,2),1]);
  %linedrawing = (linedrawing>1.0).*1.0 + (linedrawing<=1.0).*linedrawing;
  
  filled_minus_photo = filled - photo;
  % some negative numbers appear where filled regions overlap paper, set
  % these to zero
  filled_minus_photo = ...
    (filled_minus_photo<fill_epsilon).*0.0 + ...
    (filled_minus_photo>=fill_epsilon).*filled_minus_photo;
  % normalize inverse image so that brightest part of line == white
  linedrawing = filled_minus_photo ./ ...
    repmat(max(max(filled_minus_photo)),[width, height, 1]);
  % multiply by intensity threshold
  linedrawing = intensity_scale .* linedrawing;
  % clip between [0,1]
  linedrawing = ...
    (linedrawing>=1.0).*1.0 + ...
    (linedrawing<1.0).*linedrawing;
  % invert image so lines are black, paper is white
  linedrawing = 1.0 - linedrawing;
end
