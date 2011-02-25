syms a b c d e f g h off DD alph L s1 c1 s2 c2 s3 c3 s4 c4 s5 c5 s6 c6 A1 A2 A3 A4 A5 A6 T a1 a2 a3 a4 a5 a6 DD1 DD2 DD3 DD4 DD5 DD6 T03

%{
Trans_x = [[1,0,0,a];
            [0,1,0,0];
            [0,0,1,0];
            [0,0,0,1]];

Trans_y = [[1,0,0,0];
            [0,1,0,b];
            [0,0,1,0];
            [0,0,0,1]];

Trans_z = [[1,0,0,0];
            [0,1,0,0];
            [0,0,1,c];
            [0,0,0,1]];

Rot_x = [[1,0,0,0];
          [0,c_alpha,-s_alpha,0];
          [0,s_alpha, c_alpha,0];
          [0,0,0,1]];
      
Rot_y = [[c_beta,0,s_beta,0];
          [0,1,0,0];
          [-s_beta,0,c_beta,0];
          [0,0,0,1]];
      
Rot_z = [[c_gamma,-s_gamma,0,0];
              [s_gamma,c_gamma,0,0];
              [0,0,1,0];
              [0,0,0,1]];
          
%}
          
% PUMA260 constants
a = 13.0*0.0254;
b = 3.5*0.0254;
c = 8.0*0.0254;
d = 3.0*0.0254;
e = 8.0*0.0254;
f = 2.5*0.0254;
g = 0.5*0.0254;
h = 1.1*0.0254;

off = [ 0 c 0 0 0 0 ];
DD = [ a -b -d e 0 f ];
alph = [ pi/2 0 -pi/2 pi/2 pi/2 0 ] ;
          
%             alpha / a / theta / d / 0
L1 = [ alph(1), off(1), 0, DD(1), 0];
L2 = [ alph(2), off(2), 0, DD(2), 0];
L3 = [ alph(3), off(3), 0, DD(3), 0];
L4 = [ alph(4), off(4), 0, DD(4), 0];
L5 = [ alph(5), off(5), 0, DD(5), 0 pi/2];
L6 = [ alph(6), off(6), 0, DD(6), 0];          
          
A1 = [
     [c1            0                      s1*sin(L1(1))            a1*c1];                     
     [s1            0                     -c1*sin(L1(1))               a1*s1];
     [0             sin(L1(1))             0                           DD1];
     [0             0                       0                      1              ];
     ];
 
 A2 = [
     [c2            -s2*cos(L2(1))         s2*sin(L2(1))            a2*c2];                     
     [s2            c2*cos(L2(1))          -c2*sin(L2(1))               a2*s2];
     [0             sin(L2(1))             cos(L2(1))                   DD2];
     [0             0                       0                      1              ];
     ];
 
 A3 = [
     [c3            0                       s3*sin(L3(1))            a3*c3];                     
     [s3            0                       -c3*sin(L3(1))               a3*s3];
     [0             sin(L3(1))              0                   DD3];
     [0             0                       0                      1              ];
     ];
 
 
 A4 = [
     [c4            0                       s4*sin(L4(1))            a4*c4];                     
     [s4            0                       -c4*sin(L4(1))               a4*s4];
     [0             sin(L4(1))              0                   DD4];
     [0             0                       0                      1              ];
     ];
 
 A5 = [
     [c5            0                      s5*sin(L5(1))            a5*c5];                     
     [s5            0                      -c5*sin(L5(1))               a5*s5];
     [0             sin(L5(1))             0                   DD5];
     [0             0                      0                      1              ];
     ];
 
 A6 = [
     [c6            -s6*cos(L6(1))         s6*sin(L6(1))            a6*c6];                     
     [s6            c6*cos(L6(1))          -c6*sin(L6(1))               a6*s6];
     [0             sin(L6(1))             cos(L6(1))                   DD6];
     [0             0                       0                      1              ];
     ];
 
 T03 = A1*A2*A3;
 