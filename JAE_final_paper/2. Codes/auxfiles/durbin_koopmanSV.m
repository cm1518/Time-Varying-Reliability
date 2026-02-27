function [alphat,Vt] = durbin_koopmanSV(y,Z,H,Qt,m,p,t,B0,V0,kdraw)
% This is the Durbin and Koopman (2002) Kalman filter and smoother
% It includes mixture innovation for Q(t)

if isempty(kdraw)
    kdraw=ones(t,1);
end;

% initializing
vt=zeros(p,t);
Ft=zeros(p,p,t);
Lt=zeros(m,m,t);
at(:,1)=B0;
Pt(:,:,1)=V0;
Tt=eye(m);

% filtering
for i=1:t
    Ht=H((i-1)*p+1:i*p,:);
    Zt=Z((i-1)*p+1:i*p,:);
    vt(:,i)=y(:,i)-Zt*at(:,i);
    Ft(:,:,i)=Zt*Pt(:,:,i)*Zt'+Ht;
    Kt=Tt*Pt(:,:,i)*Zt'/Ft(:,:,i);
    Lt(:,:,i)=Tt-Kt*Zt;
    %at(:,i+1)=Tt*at(:,i)+Kt*vt(:,i);
    at(:,i+1)=at(:,i)+Kt*vt(:,i);
    %Pt(:,:,i+1)=Tt*Pt(:,:,i)*Lt(:,:,i)'+kdraw(i,:)*Qt;
    Pt(:,:,i+1)=Pt(:,:,i)*Lt(:,:,i)'+kdraw(i,:)*Qt;
end;

% smoothing
r=zeros(m,1);
N=zeros(m,m);
alphat(:,t) = at(:,t);
Vt(:,:,t) = Pt(:,:,t);
for i=t-1:-1:1
    Zt=Z((i-1)*p+1:i*p,:);    
    tmp=Zt'/Ft(:,:,i);
    r=tmp*vt(:,i)+Lt(:,:,i)'*r;
    N=tmp*Zt+Lt(:,:,i)'*N*Lt(:,:,i);
    alphat(:,i)=at(:,i)+Pt(:,:,i)*r;
    Vt(:,:,i)=Pt(:,:,i)-Pt(:,:,i)*N*Pt(:,:,i);
end;

alphat=alphat(:,1:t);
Vt=Vt(:,:,1:t);


