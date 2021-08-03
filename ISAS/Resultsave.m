
% 保存结果
% 先加载结果文件（注意典型年选取），然后直接运行

Sol=[F1.Position];
Costs=[pop.Cost];
plot(Costs(1,:),Costs(2,:),'o','MarkerSize',10);
    xlabel('1^{st} Objective 发电量');
    ylabel('2^{nd} Objective 生态');

% 选取代表解
[Cost1_1,c_1] =max(Costs(2,:));% 发电量最小的最优解
[Cost1_30,c_30] =max(Costs(1,:));% 发电量最大的最优解

hold on;
plot(Costs(1,c_1),Costs(2,c_1),'go','MarkerSize',10);
hold on;
plot(Costs(1,c_30),Costs(2,c_30),'ro','MarkerSize',10);

% 水库水位
Sol_1=Sol(:,c_1);
Sol_30=Sol(:,c_30);

figure();
plot([Sol_1 Sol_30 a]);

% 水库下泄流量
[Q_1,~,s1_1,s2_1]=WLQS(Sol_1);
[Q_30,~,s1_30,s2_30]=WLQS(Sol_30);
b=WLQS(a);b=b';

Q_1=Q_1';
Q_30=Q_30';

figure();
plot([Q_1 Q_30]);