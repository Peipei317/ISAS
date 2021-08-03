%%三峡水库多目标调度
% 注意修改典型年
% 注意修改保存的文件名

clc;
clear;
close all;

%% Problem Definition
global VarMin_B; % 各时段初的水库水位约束条件，在=WLQS函数中与此一致。
global VarMax_B;
global qinsanxia;
global day;
global nVar;

CostFunction=@(x) MOP2(x);      % Cost Function 目标函数
day=[5 5 5 5 5 6, 5 5 5 5 5 5, 5 5 5 5 5 6, 5 5 5 5 5 6, 5 5 5 5 5 3, 5 5 5 5 5 6]; % 每个调度时段包含的天数
nVar=36+1;             % Number of Decision Variables %水库从10月开始至次年3月，5天为一个时段，共36个时段，水位有37个。
VarSize=[1 nVar];    % Size of Decision Variables Matrix
ConditionYear=3;     % 选择典型年。1=枯水年，2=平水年，3=丰水年,4=2005-2005年
load DataInSanxia.mat
qinsanxia=Qinsanxia(:,ConditionYear);% 三峡水库入库流量，WLQS函数中会用到。假设为时段平均值，共36个。
VarMin_B=VarMin;VarMax_B=VarMax;% VarMin为水位搜索的约束，VarMin_B为水位的边界约束,即实际约束
a=zeros(nVar,1);
% a(1:19)=[154.5	158.2	161.8	165.5	169.1	172.8	175	175	175	175	175	175	175	175	175	175	175	175	175]; % 10-12月水位固定，只调1-3月
delt=1.8;% 相邻时段间最大的水位差
NIt=2000; %迭代代数

% Number of Objective Functions
a=[154.5	158.2	161.8	165.5	169.1	172.8	175	175	175	175	175	175	175	175	175	175	175	175	175	174.2647059	173.5294118	172.7941176	172.0588235	171.3235294	170.4411765	169.3877551	167.8571429	166.3265306	164.7959184	163.2653061	162.3469388	160.8163265	159.2857143	157.755102	156.2244898	155	155]'; 
nObj=numel(CostFunction(a)); %计算元素个数 % 根据目标函数，计算目标函数的个数


%% NSGA-II Parameters

MaxIt=NIt;      % Maximum Number of Iterations 最大迭代次数

nPop=30;        % Population Size 种群大小

pCrossover=0.7;                         % Crossover Percentage  交叉概率
nCrossover=2*round(pCrossover*nPop/2);  % Number of Parnets (Offsprings) % 四舍五入取整

pMutation=0.4;                          % Mutation Percentage  变异概率
nMutation=round(pMutation*nPop);        % Number of Mutants

mu=0.01;                    % Mutation Rate 突变率  特别说明，因为本程度的设计时只能有一个变异，因此mu*nVar<1,所以此处取0.01

sigma=0.1*(max(VarMax)-min(VarMin));  % Mutation Step Size


%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];
empty_individual.Rank=[];
empty_individual.DominationSet=[];
empty_individual.DominatedCount=[];
empty_individual.CrowdingDistance=[];


pop=repmat(empty_individual,nPop,1);% 堆叠矩阵

a=[154.5	158.2	161.8	165.5	169.1	172.8	175	175	175	175	175	175	175	175	175	175	175	175	175	174.2647059	173.5294118	172.7941176	172.0588235	171.3235294	170.4411765	169.3877551	167.8571429	166.3265306	164.7959184	163.2653061	162.3469388	160.8163265	159.2857143	157.755102	156.2244898	155	155]';
[~,~,s1,s2]=WLQS(a); %这个步骤中前两个参数，下泄流量和下游水位不需要，所以用‘~’表示省略
for k=1:nPop
    pop(k).Position=a;
    pop(k).Cost=CostFunction(pop(k).Position);%计算目标函数，放在 pop(i).Cost里
end

% Non-Dominated Sorting 将产生的初始群进行非支配排序
[pop, F]=NonDominatedSorting(pop);

% Calculate Crowding Distance  计算拥挤度
pop=CalcCrowdingDistance(pop,F);

% Sort Population 排序 
[pop, F]=SortPopulation(pop);


%% NSGA-II Main Loop

for it=1:MaxIt
    
  % Crossover
    popc=repmat(empty_individual,nCrossover/2,2);
      
    for k=1:nCrossover/2
         
        i1=randi([1 nPop]);% 在开区间（1,nPop）生成均匀分布的伪随机整数
        p1=pop(i1);
        
        i2=randi([1 nPop]);
        p2=pop(i2);
        
        [popc(k,1).Position, popc(k,2).Position]=Crossover(p1.Position,p2.Position);
        
        popc(k,1).Cost=CostFunction(popc(k,1).Position);
        popc(k,2).Cost=CostFunction(popc(k,2).Position);
        
    end
    popc=popc(:);% 变成一维列向量
    
    % Mutation
    popm=repmat(empty_individual,nMutation,1);
    for k=1:nMutation
        
        i=randi([1 nPop]);
        p=pop(i);
        
        popm(k).Position=Mutate(p.Position,mu,sigma);
        popm(k).Cost=CostFunction(popm(k).Position);        
    end
    
    % Merge
    pop=[pop
         popc
         popm]; %#ok
     
    % Non-Dominated Sorting
    [pop, F]=NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop=CalcCrowdingDistance(pop,F);

    % Sort Population
    pop=SortPopulation(pop);
    
    % Truncate
    pop=pop(1:nPop);
    
    % Non-Dominated Sorting
    [pop, F]=NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop=CalcCrowdingDistance(pop,F);

    % Sort Population
    [pop, F]=SortPopulation(pop);
    
    % Store F1
    F1=pop(F{1});
    numel(F1);
    F1.Cost;
   
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Number of F1 Members = ' num2str(numel(F1))]);
    
    % Plot F1 Costs
    figure(1);
    PlotCosts(F1);
    pause(0.01); 
    pop(F{1}).Cost
    pop(F{1}).Position    %输出水位优化结果   
end

%% Results
save result0503
