%% Generate a safe trajectory from a set of positions
function [x, y, z] = puma_trajectory(X, Y, Z, phi, theta, psi)
    
    [t1, t2, t3, t4, t5, t6] = puma_ik(X(1), Y(1), Z(1), phi, theta, psi);

    output_vector_length = length(X);
    
    complete = false;
    i = 1;
    
    while(complete == false);
        
        %{
        if (i == 3),
            error('meh ');
        end
        %}
        
        t1_old = t1;
        t2_old = t2;
        t3_old = t3;
        t4_old = t4;
        t5_old = t5;
        t6_old = t6;             
        
        [t1, t2, t3, t4, t5, t6] = puma_ik(X(i), Y(i), Z(i), phi, theta, psi);
               
        
        % Check if joint angle rates exceeded
        if (abs(t1_old - t1) >= 5 || ...
            abs(t2_old - t2) >= 5 || ...
            abs(t3_old - t3) >= 5 || ...
            abs(t4_old - t4) >= 5 || ...
            abs(t5_old - t5) >= 5 || ...
            abs(t6_old - t6)),
        
            % Then run a append a new interpolated coordinate to the output 
            % vector and check again.
            
            Xinterp = (X(i) - X(i-1))/2;
            Yinterp = (Y(i) - Y(i-1))/2;
            Zinterp = (Z(i) - Z(i-1))/2;
                        
            Xleft = X(1:i);
            Yleft = Y(1:i);
            Zleft = Z(1:i);            
            
            Xright = X(i+1:output_vector_length);
            Yright = Y(i+1:output_vector_length);
            Zright = Z(i+1:output_vector_length);
            
            X = [Xleft Xinterp Xright];
            Y = [Yleft Yinterp Yright];
            Z = [Zleft Zinterp Zright];
            
            % Reset i and update length so we can check again
            output_vector_length = length(X);                               
            
        else
            
            % Move forward
            i = i + 1;
        end
        
        if (i == output_vector_length)
            complete = true;
        end
        
    end
    
    % Return
    x = X;
    y = Y;
    z = Z;
    
end
              
        
            