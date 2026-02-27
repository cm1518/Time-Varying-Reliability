function IRF=computeIRF(bet,C,p,M,H)

IRF_Wold = zeros(M,M,H); % row is variable, column is shock
IRF_Wold(:,:,1) = eye(M);

for l = 1:H    
    if l < H
        for j=1:min(l,p)
            IRF_Wold(:,:,l+1) = IRF_Wold(:,:,l+1) + bet(1+(j-1)*M:j*M,:)'*IRF_Wold(:,:,l-j+1);
        end
    end
    
end

IRF = NaN(M,M,H);
for i_hor = 1:H
    IRF(:,:,i_hor) = IRF_Wold(:,:,i_hor) * C;
end

end