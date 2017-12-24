A = [1, 2, 3; 4, 5, 6; 7, 8, 9];

disp(A);

parfor i = 1 : 3
    
    A(i, :) = i * A(i, :);
    
end

A = A + 1;

disp(A);