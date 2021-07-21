% Big state matrix including delays:
% [y(k); y(k-1); ...; y(k-q+1)]
A_big = [
    [A, Ad]; 
    [eye(ny*(q-1)), zeros(ny*(q-1), ny)]
        ]; 
abs(eig(A_big))

