

%计算目标函数，使两个目标函数最大
% 要注意变化的值有：（1）调度期的各月，（2）2月份的天数，（3）鄱阳湖的初始水位，（4） 参考指标

% tD0修改为105——20200809

function z=MOP2(x)
    [qoutsanxia1,zdownsanxia1,s1,s2]=WLQS(x);
    
    z1=0;
    %%计算发电量
    %三峡机组单机最大引用流量966.0m3/s[190]，32台机组最大下泄流量为30912m3/s，当出库总流量大于30912m3/s时，多余部分为弃水，参考戴凌全博士论文
    % 10月份
    for i=1:5 % 时段编号
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*5;      %发电量
    end
    for i=6:6
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*6;      %发电量
    end
    % 11、12月份
    for i=7:17
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*5;      
    end
    for i=18:18
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*6;      
    end
    % 1月份
    for i=19:23
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*5;
    end
    for i=24:24
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*6;
    end
    % 2月份
    for i=25:29
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*5;
    end
    for i=30:30
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*3; % 2月份的天数
    end
    % 3月份
    for i=31:35
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*5;
    end
    for i=36:36
        z1=z1+((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933*24*6;
    end
    
    
    %%计算生态目标
    load DataInM.mat;
    qoutsanxia2=Expand(qoutsanxia1);% (1,36)维到（1,183）维
    QJiujiang=Muskingum(qoutsanxia2,Qingjiang,Chenglingji,Hanjiang,Qjj1); 
    LakeLevel=Lake(station,FiveRivers,QJiujiang,Level0);
    ZD0=7.8; tD0=105; TD0=40;                                       % 参考指标
    % 计算各生态目标
    n=size(LakeLevel);
    ZD=min(LakeLevel);
    TD=0;
    tD1=0;
    for i=2:n
        if LakeLevel(i-1)>9 && LakeLevel(i)<9 && LakeLevel(i+1)<9.1 && LakeLevel(i+2)<9.1
            tD1=i;break;
        end
    end
    for i=2:n
        if LakeLevel(i)<9
            TD=TD+1;
        end
    end
    if tD1==0
        tD1=183;
    end
    % 计算总生态目标
    z2=ZD/ZD0+tD1/tD0-TD/TD0;
    
    if s1==-n
        z1=-10;
    end
    if s1==-15
        z1=-2;
    end
    if s2==-5000
        z2=-1;
    end
    if s2==-1
        z2=-10;
    end
    if s2==-2
        z2=-100;
    end      
    
     
   z=[z1 z2]';
end