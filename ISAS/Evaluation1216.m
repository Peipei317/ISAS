
% 调度效果评估分析，改自目标函数MOP2
% 根据需要计算的站点修改station、level0的赋值

% 先在工作区输入 x=0; 然后将x赋值为水库水位结果
% 根据典型年修改Conditionyear

x=[154.5
159.9600959
163.9788538
166.8230544
170.9554321
172.9237815
175
175
174.9437687
174.9991434
175
174.9702677
174.9986815
174.901454
174.9734804
174.9304837
175
174.9527132
174.985154
174.8686283
174.9956447
174.831612
174.9399392
173.9597671
172.977819
171.9597385
170.9679686
168.9398756
167.8670076
165.8820952
164.8420624
163.9702116
161.9818974
160.9333414
158.9864035
157.9390497
155
    ];

global VarMin_B;
global VarMax_B;
global qinsanxia;
global day;

day=[5 5 5 5 5 6, 5 5 5 5 5 5, 5 5 5 5 5 6, 5 5 5 5 5 6, 5 5 5 5 5 3, 5 5 5 5 5 6]; % 每个调度时段包含的天数
nVar=36+1;             % Number of Decision Variables %水库从10月开始至次年3月，5天为一个时段，共36个时段，水位有37个。
VarSize=[1 nVar];    % Size of Decision Variables Matrix
ConditionYear=1;     % 选择典型年。1=枯水年，2=平水年，3=丰水年
load DataInSanxia.mat
qinsanxia=Qinsanxia(:,ConditionYear);% 三峡水库入库流量，WLQS函数中会用到。假设为时段平均值，共36个。
VarMin_B=VarMin;VarMax_B=VarMax;% VarMin为水位搜索的约束，VarMin_B为水位的边界约束,即实际约束

load DataInM.mat; % 加载模型边界,需要根据站点修改的有 station和level0
station=2;
level0=14.61;

[qoutsanxia1,zdownsanxia1,s1,s2]=WLQS(x); % 计算水库的下泄流量和下游水位

%% 计算出力
%三峡机组单机最大引用流量966.0m3/s[190]，32台机组最大下泄流量为30912m3/s，当出库总流量大于30912m3/s时，多余部分为弃水，参考戴凌全博士论文
N=zeros(36,1); %各时段的出力
for i=1:36
    N(i)=((x(i)+x(i+1))/2-zdownsanxia1(i))*min(30912,qoutsanxia1(i))*9.81*0.933;
end

%% 计算鄱阳湖水位
qoutsanxia2=Expand(qoutsanxia1);% (1,36)维到（1,183）维
QJiujiang=Muskingum(qoutsanxia2,Qingjiang,Chenglingji,Hanjiang,Qjj1); 
LakeLevel=Lake(station,FiveRivers,QJiujiang,Level0);
if station==2
    HXingzi=LakeLevel;
end

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
        tD1=183;% 
end
%% 计算江湖水量交换
LakeFlow=Exchange(QJiujiang,HXingzi);

plot(LakeLevel)
figure()
plot(LakeFlow)
