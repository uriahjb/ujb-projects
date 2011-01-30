function pen_script(image_file_path)
  im = im2double(imread(image_file_path));
  linedrawing = photo2linedrawing(im,'pen');
  basename = regexprep(image_file_path,'\.[^.]+$','');
  imwrite(linedrawing,[basename '-pen.png']);
  figure;
  subplot(1,2,1);
  imshow(im);
  title('Photo');
  subplot(1,2,2);
  imshow(linedrawing);
  title('Pen drawing extraction');
end
