function showObjectInfo(obj, methodList, url)

fullName = class(obj);
idx = find(fullName == '.');
if isempty(idx), 
    idx = 0;
end
scopedName = fullName(idx+1:end);
fprintf('<a href="matlab:help %s.%s">%s</a>\n', fullName, scopedName, fullName);

if isvalid(obj)
    fprintf('  name: %s\n', obj.name);
else
    
end
fprintf('  methods: ');
for i=1:numel(methodList)    
    fprintf('<a href="matlab:help %s.%s">%s</a>  ', class(obj), methodList{i}, methodList{i});
end
fprintf('\n');

if ~isvalid(obj)
  fprintf('\nThis object has been deleted and is no longer valid\n');
end

