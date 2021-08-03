% Copyright (c) 2016
% All rights reserved. 
% Project Title: Non-dominated Sorting Genetic Algorithm II (NSGA-II)
% Developer: Dai Lingquan based on Yarpiz (www.yarpiz.com)
% Contact Info: dailingquan@163.com
%

function y=Mutate(x,mu,sigma)

    nVar=numel(x);
    
    nMu=ceil(mu*nVar);%返回大于或者等于指定表达式的最小整数
   
    k=1;
    while (true)  %%变异后的水位序列值也必须满足水位及下泄流量约束， 很重要
            
    j=randsample(nVar,nMu); %从nVar 中随机取nMu个向量
    if numel(sigma)>1
        sigma = sigma(j);
    end
    y=x;
    y(j)=x(j)+sigma.*randn(size(j));
    [~,~,s1,s2]=WLQS(y);
          if s1>0 && s2>0
             a=y;y=a;k=k+1;
          end
        if k==2
            break;
        end
   end
 
end