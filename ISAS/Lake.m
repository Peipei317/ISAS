% 鄱阳湖水位模拟
% 连续预测

function y=Lake(station,FiveRivers,Jiujiang,Level0)

% 数据加载与预处理
load([num2str(station) '.mat']); %站点选择, 1=湖口; 2=星子; 3=都昌; 4=吴城; 5=棠荫; 6=康山
dat_change=zeros(182,7);
dat_change(:,1:6)=[FiveRivers Jiujiang];
dat_change(1,7)=Level0;
level=dat_change(:,7);
level_pre=level; % 连续预测水位的初始值

% 归一化规则
[num_r,num_c] = size(dat_raw);
data_in_1=zeros(num_r-1,num_c);
for i=1:num_r-1
    data_in_1(i,:) = [dat_raw(i+1,1:num_c-1) dat_raw(i,num_c)];% 从第2天开始
end
maxmin = [max(data_in_1);min(data_in_1)]; % 训练模型时输入数据的最大最小值
[~,ps]=mapminmax(maxmin',0,1); % 提取归一化规则

%输入变量整理
[num_r,num_c] = size(dat_change);
data_inp=zeros(num_r-1,num_c);
for i=1:num_r-1
    data_inp(i,:) = [dat_change(i+1,1:num_c-1) dat_change(i,num_c)];% 从第2天开始
end
data_inp=mapminmax('apply',data_inp',ps)';

for i=1:num_r-1
    [level_temp,~,~]=svmpredict(1,data_inp(i,:),model);% 求第i+1天的水位
    level_pre(i+1)=level_temp; 
    dat_change(i+1,num_c)=level_temp; 
    if i<num_r-1
        data_inp(i+1,:) = [dat_change(i+2,1:num_c-1) dat_change(i+1,num_c)];% 得到求i+2天水位所需要的输入数据
        data_inp(i+1,:)=mapminmax('apply',data_inp(i+1,:)',ps)';
    end    
end
y=level_pre;
end
