%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA120
% Project Title: Non-dominated Sorting Genetic Algorithm II (NSGA-II)
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function [pop, F]=NonDominatedSorting(pop)

    nPop=numel(pop);

    for i=1:nPop
        pop(i).DominationSet=[];
        pop(i).DominatedCount=0;
    end
    
    F{1}=[];%单元数组
    
    for i=1:nPop
        for j=i+1:nPop% 跟后面的每个数比较
            p=pop(i);
            q=pop(j);
            
            if Dominates(p,q)
                p.DominationSet=[p.DominationSet j]; % 大于（支配了）第几个数，即比它小的数的编号
                q.DominatedCount=q.DominatedCount+1; % 小于几个数，即排序号（从0开始）
            end
            
            if Dominates(q.Cost,p.Cost)
                q.DominationSet=[q.DominationSet i];
                p.DominatedCount=p.DominatedCount+1;
            end
            
            pop(i)=p;% 更新每个结构体的DS和DC
            pop(j)=q;
        end
        
        if pop(i).DominatedCount==0
            F{1}=[F{1} i];% 进入F的编号表示此编号的值比它后面的值都大
            pop(i).Rank=1;% 找到了排名第1的数
        end
    end    
    k=1;
    
    while true
        
        Q=[];
        
        for i=F{k}% 对于F内第k个单元里的每个值
            p=pop(i);
            
            for j=p.DominationSet% 对于每个比它小的数
                q=pop(j);
                
                q.DominatedCount=q.DominatedCount-1;
                
                if q.DominatedCount==0
                    Q=[Q j]; %#ok    将排名第2，3，...的数的编号存入
                    q.Rank=k+1;% 找到排名第2,3,...的数
                end
                
                pop(j)=q;
            end
        end
        
        if isempty(Q)
            break;
        end
        
        F{k+1}=Q; %#ok
        
        k=k+1;
        
    end
    
end