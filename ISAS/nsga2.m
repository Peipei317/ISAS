%%三峡水库汛末蓄水期多目标调度
clc;
clear;
close all;

%% Problem Definition

CostFunction=@(x) MOP2(x);      % Cost Function 目标函数

nVar=18;             % Number of Decision Variables %水库从7月上旬开始至11月中旬，10天为一个时段，共14个时段。

VarSize=[1 nVar];   % Size of Decision Variables Matrix

%%约束条件，各旬的水位约束,在=WLQS函数中，也需要输入约束条件，并且必须保证与这一样
VarMin=[145,145,145,145,145,145,145,150,150,150,150,150,150,151,152.8,159,168,175];
VarMax=[147.4455,147.433,147.7655,149.075,154.5485,154.3741667,154.8075,157.139,160.2435,162.8025,165.431,167.751,170.272,172.269,173.854,175.0025,175,175];


%VarMin=[145,145,145,145,145,145,145,145,145,145,145,145,145,146.3,152.8,159,164,175];
%VarMax=[147.4455,147.433,147.7655,149.075,154.5485,154.3741667,154.8075,157.139,160.2435,162.8025,165.431,167.751,170.272,172.269,173.854,175.0025,175,175];

% Number of Objective Functions
k=1;
while(true)  %保证产生满足水位约束和流量约束的水位序列，这很关键
    a=unifrnd(VarMin,VarMax,VarSize);
    [qoutsanxia1,zdownsanxia1,s1,s2]=WLQS(a);
    if s1>0 && s2>0
        nObj=numel(CostFunction(a)); %根据目标函数，计算目标函数的个数
        k=k+1;
    end
     if k==2 %已经产生了一个满足约束条件水位序列
          break;
     end
end


%% NSGA-II Parameters

MaxIt=1000;      % Maximum Number of Iterations 最大迭代次数

nPop=30;        % Population Size 种群大小

pCrossover=0.7;                         % Crossover Percentage  交叉概率
nCrossover=2*round(pCrossover*nPop/2);  % Number of Parnets (Offsprings)

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


pop=repmat(empty_individual,nPop,1);

k=1;
while (true)   %保证产生nPop个满足约束条件的水位序列，关键步骤
     a=unifrnd(VarMin,VarMax,VarSize);
     [~,~,s1,s2]=WLQS(a); %这个步骤中前两个参数，下泄流量和下游水位不需要，所以用‘~’表示省略
     if s1>0 && s2>0  %s1>0表示满足流量约束，s2>0表示满足水位约束，需要同时满足
        pop(k).Position=a;
        pop(k).Cost=CostFunction(pop(k).Position);%计算目标函数，放在 pop(i).Cost里
        k=k+1;
     end
   
   if k==nPop+1  %表示已经产生了nPop个符合条件的初始水位序列值，可以break
       break;
   end
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
         
        i1=randi([1 nPop]);
        p1=pop(i1);
        
        i2=randi([1 nPop]);
        p2=pop(i2);
        
        [popc(k,1).Position, popc(k,2).Position]=Crossover(p1.Position,p2.Position);
        
        popc(k,1).Cost=CostFunction(popc(k,1).Position);
        popc(k,2).Cost=CostFunction(popc(k,2).Position);
        
    end
    popc=popc(:);
    
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

