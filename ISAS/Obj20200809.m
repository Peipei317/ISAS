%重新计算目标2的结果，取tD0=105

load result0430.mat;
Obj=zeros(2,30);
for i=1:30
    x=Sol(:,i);
    z=MOP2(x);
    Obj(:,i)=z;
end