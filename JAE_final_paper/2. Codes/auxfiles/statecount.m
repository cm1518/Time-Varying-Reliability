function ct =statecount(sst,nst)
% sst is a row vector of states from 1,...,K
% nst is the number of states (K)

sstd = diff(sst);
ct = zeros(nst);

for tr = [sst(1:end-1);sst(2:end)]
    ct(tr(1),tr(2)) = ct(tr(1),tr(2)) + 1;
end

