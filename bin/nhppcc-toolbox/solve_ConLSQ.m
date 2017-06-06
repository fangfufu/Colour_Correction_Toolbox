function res = solve_ConLSQ(A,X,C,x_c)
%min_x |A*x=X| s.t. C*x=x_c
         lastwarn('');
         res = [2*A'*A, C'; C, zeros(size(C,1))]\[2*A'*X;x_c];
         [~, msgid] = lastwarn;
         if strcmp(msgid,'MATLAB:singularMatrix')||strcmp(msgid,'MATLAB:nearlySingularMatrix')
            lambda = 0.0001;
            res = [2*A'*A + lambda*eye(size(A'*A)), C'; C, zeros(size(C,1))]\[2*A'*X;x_c];
         end
end

