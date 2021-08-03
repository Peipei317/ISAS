% 计算长江和鄱阳湖水量交换 

function y=Exchange(QJiujiang,HXingzi)
    % 数据加载与预处理
    load('model_exchange.mat')
    data_in = [QJiujiang HXingzi];
    minmax=[9030 7.32;58400 20.28]; % 训练时输入数据的最大值，对应归一化的1
    [~,ps]=mapminmax(minmax',0,1);
    scenario_in=mapminmax('apply',data_in',ps)';
    %% 预测结果
    tmp_2 = ones(size(QJiujiang,1),1);
    [test_pre,~,~] = svmpredict(tmp_2,scenario_in,model);

    y=test_pre;
end