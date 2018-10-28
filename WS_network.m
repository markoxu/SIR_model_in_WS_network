%====================================================
%Author: MarkoXu  704712641@qq.com
%Date: 2018-10-27
%Desc: generate a WS network with rewired probability p
%Reference: Collective dynamic of 'small-world' networks Fig. 1
%====================================================

%% 设置网络的基本参数
N = 10000; %网络规模
K = 5; %节点单侧的邻居数为K
%p = 10.^(-4); %重连概率p
node_neighbors = cell(N, 1); %保存每个节点的邻居

%% 产生规范网络，即每个节点与左右K个节点相连
for i = 1 : N
    A = zeros(2*K, 1);
    for j = 1 : K
        if i+j <= N
            A(j) = i + j;
        else
            A(j) = i + j - N;
        end
        if i-j <= 0
            A(j+K) = i - j + N;
        else
            A(j+K) = i - j;
        end
    end
    node_neighbors{i,1} = A;
end

%% 规范网络所有边以概率p随机重连
for i = 1 : N
    for j = 1 : 2*K
        p_link = unifrnd(0,1); %产生一个重连概率
        tempt = node_neighbors{i}(1);%获取当前可能要断开的节点
        if isnan(tempt)
            node_neighbors{i}(1)=[];
            continue;
        end
        %不发生重连，将该节点放到邻居的最后
        if p_link >= p
            node_neighbors{i}= [node_neighbors{i}(2:size(node_neighbors{i},1));tempt];
        end
        %发生重连，寻找重连的节点，不发生重边与自边
        if p_link < p
            e = find(node_neighbors{tempt}==i);
            node_neighbors{i}(1) = [];
            node_neighbors{tempt}(e) = nan; %不能删掉，因为会影响节点的出栈顺序
            v_link = unidrnd(N); %选择一个重连的节点
            while v_link==i||ismember(v_link,node_neighbors{i}) %防止重边或者自边
                v_link = unidrnd(N);
            end
            node_neighbors{i} = [node_neighbors{i}; v_link]; %将重连节点放入邻居表中
            node_neighbors{v_link} = [node_neighbors{v_link}; i];
        end
    end
end
% 去除邻居表中的nan数据，因为这些点其实已经断开
for i = 1 : N
    node_neighbors{i}(isnan(node_neighbors{i})) = [];
end


