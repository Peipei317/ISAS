% Copyright (c) 2016
% All rights reserved. 
% Project Title: Non-dominated Sorting Genetic Algorithm II (NSGA-II)
% Developer: Dai Lingquan based on Yarpiz (www.yarpiz.com)
% Contact Info: dailingquan@163.com

% s1=n 水位满足约束； s2=n 流量满足约束
% s1=-n 水位不满足约束
% s1=-15 水位日差过大
% s2=1 未判断流量； s2=-5000 流量不满足下边界q1； s2=-1 流量不满足下边界0；s2=-2 流量不满足上边界
% s2=3 出力不满足约束


function [qoutsanxia1,zdownsanxia1,s1,s2]=WLQS(x)  %水位WL，流量Q，流量约束计算S。第一个参数返回下泄流量，第二个参数返回下游水位，第3个参数判断是否满足流量约束,第4个参数判断是否满足水位约束
global VarMin_B;
global VarMax_B;
global qinsanxia;
global day;
n=size(x,1);
vsanxia1=zeros(1,n);
qoutsanxia=zeros(1,n-1);
qoutsanxia1=zeros(1,n-1);
zdownsanxia1=zeros(1,n-1);
N=zeros(1,n-1);
zmin=VarMin_B;
zmax=VarMax_B;
q1=3000;

%%三峡水库水位-库容关系曲线
zsanxia=[53,56,59,62,65,68,71,74,77,80,83,86,89,92,95,98,101,104,107,110,113,116,119,122,125,128,131,134,137,140,143,146,149,152,155,158,161,164,167,170,173,176,179,182,185];
vsanxia=[0.1,0.2,0.5,0.9,1.4,2.0,2.6,3.6,5.1,7.0,9.2,11.5,14.1,16.9,20.0,23.4,27.3,31.9,37.1,43.0,49.6,56.9,65.1,74.0,84.0,95.3,107.3,119.7,132.9,147.0,161.6,176.4,191.6,208.6,228.0,248.1,269.2,292.2,317.0,344.0,373.0,403.2,434.8,468.4,505.0]*10^8;
%%三峡水库下游尾水位-流量关系
qdownsanxia=[0,6167.4,11894.3,19603.5,29074.9,36563.9,46916.3,59911.9,87224.7,101762];
zdownsanxia=[64.4015,64.7104,65.3282,66.2548,67.9537,69.2664,71.2741,73.8996,79.4595,82.3938];

k=0;
for i=1:n
    if x(i)>=zmin(i) && x(i)<=zmax(i)
        k=k+1;
    end
end

if k==n
     s1=n;%赋予一个正数而已
     for i=1:n
         vsanxia1(i)=interp1(zsanxia,vsanxia,x(i),'linear'); %水位对应的库容
     end  
     
     % 求三峡水库的下泄流量
%      qoutsanxia(1)=qinsanxia(1);
%      qoutsanxia(n)=qinsanxia(n);
     for i=1:n-1
        qoutsanxia(i)=qinsanxia(i)-(vsanxia1(i+1)-vsanxia1(i))/(day(i)*24*3600); 
     end
     if  min(qoutsanxia)>=q1 && max(qoutsanxia)<=56700
         qoutsanxia1=qoutsanxia;
         s2=n; %满足流量约束条件
     elseif min(qoutsanxia)<q1 && min(qoutsanxia)>=0
         qoutsanxia1=qoutsanxia;
         s2=-5000;
         disp('流量不满足下边界约束q1');
     elseif min(qoutsanxia)<0
         qoutsanxia1(i)=0;
         s2=-1;
         disp('流量不满足下边界约束0');
     else
         s2=-2;
         disp('流量不满足上边界约束');
     end
     
     for i=1:n-1
         zdownsanxia1(i)=interp1(qdownsanxia,zdownsanxia,qoutsanxia1(i),'linear');%下游水位
     end
     
%      for i=1:n-1
%          N(i)=((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933;%电站出力
%          if N(i)<4990000||N(i)>224000000
%             s2=3;
%             disp('出力不满足边界约束');
%          end
%      end

else
    s1=-1*n;%水位不满足约束
    s2=1;
    disp('水位不满足边界约束');
end

%%再用水位日变幅判断
deltZ=zeros(1,n-1);
for i=1:n-1
    deltZ(i)=abs(x(i+1)-x(i));
end
  b=max(deltZ);
if s1>0 && s2>0
    if b>15.0
       s1=-15;       
    end
end

end