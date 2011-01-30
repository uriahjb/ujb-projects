%% Puma Demo ... runs some cool animations

p = puma260;

for i=1:100
    puma_viz(p, [i/20 i/100 0 0 0 0])
    pause(0.005)
end