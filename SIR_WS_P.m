%====================================================
%Author: MarkoXu  04712641@qq.com
%Date: 2018-10-27
%Desc: SIR model in ws model with different p
%Reference: Collective dynamic of 'small-world' networks Fig. 3a
%====================================================

%% 设置重连概率p,产生WS网络
p = 10.^(-4);
WS_network

%% 多次感染过程，出现一次半数感染即可
count = 0; %实验重复次数
T = 1000; %设置疾病传播的总时间步数
beta = 0.35; %疾病的感染率，调整该值使得恰好能感染超过半数人群
flag = 0; %成功感染半数人群的标志
while count < 1000
    node_state = zeros(N, 1); %节点状态，0为易感态S态，1为感染态I态
    %% 种子节点的感染过程=========================
    seed_node = randi(N,1); %随机选取一个节点作为感染的种子节点
    node_state(seed_node) = 1;  %随机选一个节点作为感染种子节点
    infected_total_num = 1; %初始感染人数为1，即种子节点
    t = 1;
    neighbors = node_neighbors{seed_node}; %种子节点的邻居
    rand_num = rand(length(neighbors),1);%产生随机数与感染率感染概率比较
    %真正传播疾病需要满足两个条件：接触的节点为S态且能成功感染
    node_infected = neighbors((rand_num<beta)&(~node_state(neighbors))); 
    infected_total_num = infected_total_num + length(node_infected);
    node_state(node_infected) = 1; %感染节点状态置为1
    %% 后续节点的感染过程=========================
    while t <= 1000
        t = t + 1;
        node_infected_temp = []; %记录新感染的邻居节点，可能存在重复，后面去重
        for j = 1 : length(node_infected)
            neighbors = node_neighbors{node_infected(j)};
            rand_num = rand(length(neighbors),1);
            node_infected_temp = [node_infected_temp; neighbors((rand_num<beta)&(~node_state(neighbors)))];
        end
        node_infected = unique(node_infected_temp, 'stable'); %去除重复的感染邻居
        infected_total_num = infected_total_num + length(node_infected);
        node_state(node_infected) = 1;
    end
    count = count + 1;
    %感染超过半数则传播停止
    if infected_total_num/N >= 0.5
        flag = 1;
        break;
    end
end

if flag == 1
     fprintf('该p和beta组合可以成功感染半数，可尝试适当调低疾病的感染率beta\n');
else
    fprintf('该p和beta组合不能成功感染半数，可尝试适当调高疾病的感染率beta\n');
end

%% 记录多次实验结果，绘制曲线
%{
%重连概率的取值范围0.0001~1
p_link = logspace(-4, 0, 9); %重连概率的取值范围0.0001~1，对数间隔
%要达到半感染条件最小的beta值
r_half = [0.34,0.33,0.28,0.25,0.21,0.18,0.16,0.137,0.135]; 
%绘制曲线
plot(p_link, r_half, '.', 'markersize', 20);
xlabel('p');ylabel('r_{half}');
title('r_{half}与p的关系图');
set(gca,'xscale','log')
%}

