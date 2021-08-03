%Yangtze estimate

function y=Muskingum(Isx,Qqj,Qclj,Qhj,Qjj1)
% parameter setting
K=24*6; % h           假定
L=950; % km
x=0.421;              % 假定
dt=24;
Kl=dt;
n=K/Kl; %河段数
Ll=L/n;
xl=0.5-n*(1-2*x)/2;

% tributaries
Dc=450;             % 三峡都城陵矶距离
Dq=70;              % 三峡到清江距离 源自百度地图工具
Dh=70+88+67+225+240;% 三峡到汉口距离
nc=round(Dc/Ll)+1; % 城陵矶入流的河段
nq=round(Dq/Ll)+1;
nh=round(Dh/Ll)+1;

C0=(0.5*dt-Kl*xl)/(0.5*dt+Kl-Kl*xl);
C1=(0.5*dt+Kl*xl)/(0.5*dt+Kl-Kl*xl);
C2=(-0.5*dt+Kl-Kl*xl)/(0.5*dt+Kl-Kl*xl);

% compute I and Q
nj=size(Isx,2)-1;   %时段数
Isx=Isx(1:nj);
I=zeros(nj,n);    
Q=zeros(nj,n);
I(:,1)=Isx';
Q(1,n)=Qjj1;

% initial Q
j=1;
for i=1:n-1;
    Q(j,i)=I(j,1)+(Q(j,n)-I(j,1))*i/n;
end


for i=1:n
    for j=2:nj
        if i>1
            I(j,i)=Q(j,i-1);
            if i==nc
                I(j,i)=I(j,i)+Qclj(j);
            end
            if i==nq
                I(j,i)=I(j,i)+Qqj(j);
            end
            if i==nh
                I(j,i)=I(j,i)+Qhj(j);
            end
        end
        Q(j,i)=C0*I(j,i)+C1*I(j-1,i)+C1*Q(j-1,i);
    end
end

y=Q(:,n);
end


