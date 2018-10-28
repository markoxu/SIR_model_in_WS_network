%====================================================
%Author: MarkoXu  704712641@qq.com
%Date: 2018-10-27
%Desc: SIR model in ws model with sufficient infectious disease
%Reference: Collective dynamic of 'small-world' networks Fig. 3b
%====================================================
clear,close all;
%% 设置重连概率p,产生WS网络
p = 10.^(-4);
WS_network

%% 100次传染实验，获取重连概率p与感染全网所需时间T的关系
T_p_avg = 0; %100次传播下的感染全网所需的平均时间
beta = 1; %设疾病的传染概率为1
for i = 1 : 100
    if mod(i,5) == 0
        WS_network  %每隔五轮实验产生一个新的且p不变的WS网络
    end
    T_p = 0; %记录本轮疾病感染全网所需时间
    node_state = zeros(N, 1); %节点状态，0为易感态S态，1为感染态I态
    %% 种子节点的感染过程=========================
    seed_node = randi(N,1); %随机选一个节点作为感染种子节点
    node_state(seed_node) = 1;  %将种子节点状态置为感染态
    infected_total_num = 1; %初始感染人数为1，即种子节点
    t = 1;
    neighbors = node_neighbors{seed_node}; %种子节点的邻居
    rand_num = rand(length(neighbors),1); %产生随机数与感染率感染概率比较
    %真正传播疾病需要满足两个条件：接触的节点为S态且能成功感染
    node_infected = neighbors((rand_num<beta)&(~node_state(neighbors)));
    infected_total_num = infected_total_num + length(node_infected);
    node_state(node_infected) = 1; %感染节点状态置为1
    %% 后续节点的感染过程=========================
    while infected_total_num ~= N
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
        T_p = T_p + 1;
    end
    T_p_avg = T_p_avg + T_p;
end
T_p_avg = T_p_avg / 100;
fprintf('重连概率p=%.5f时感染全网平均所需时间步为%.2f\n', p, T_p_avg);

%{
%% 记录p与T_p_avg的对应关系，绘制曲线
p_link = logspace(-4, 0, 9); %重连概率的取值范围0.0001~1，对数间隔
T_p = [347.9, 163.2, 65.1, 24.1, 14.7, 8.9, 6.1, 5, 5]; %对应感染全网所需的平均时间
T_0 = max(T_p);
plot(p_link, T_p/T_0, '.', 'markersize', 20);
xlabel('p'); ylabel('T(p)/T(0)');
title('T(p)/T(0)与p的关系图');
set(gca,'xscale','log')
%}

