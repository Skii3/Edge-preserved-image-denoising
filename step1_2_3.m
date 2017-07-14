function [ I2,w ] = step1_2_3( L_height_index,L_width_index, patch_size,L,I2,step_patch,w,L_select_width,L_select_height,m ,I,t,flag,I_origin,center )
% L_height_index����Χ�����Ͻ����������
% L_width_index����Χ�����ϽǺ��������
% patch_size:��ȡ��patch�Ĵ�С
% L��patch_group�Ĵ�С
% step_patch��ȡpatchʱ��step
% w�����ÿ�����ص�Ȩ�ؾ���
% L_select_width��L_select_height����L_select_width * L_select_height��Χ��ѡȡ���Ƶ�L��patch
% m:ÿ��patch�ĳ����
% I��ԭʼ������ͼƬ
% t�������Ĺ��Ʒ���
global k_record_index_iter
global k_record
global k_record_index
%% step1����patch grouping: block matching method
L_index_begin = [L_height_index L_width_index];                                                     % ȡL��Χ�����Ͻǵ������
patch_height_index = [L_index_begin(1):step_patch:L_index_begin(1) + L_select_height - 1 - m, ...    % ��Χ����patch���Ͻǳ�ʼλ�õ�����
    L_index_begin(1) + L_select_height - m];
patch_width_index = [L_index_begin(2):step_patch:L_index_begin(2) + L_select_width - 1 - m, ...    % ��Χ����patch���Ͻǳ�ʼλ�õ�����
    L_index_begin(2) + L_select_width - m];
ind = 0;
number_patch = length(patch_width_index) * length(patch_height_index);
y = zeros(number_patch, patch_size);
y2 = zeros(number_patch, patch_size);
P = zeros(patch_size, L + 1);
for k1 = 1:m
    for k2 = 1:m
        ind = ind + 1;
        y(:,ind) = reshape(I(patch_height_index + k1 - 1,patch_width_index + k2 - 1)',1,number_patch);                % �õ��ɷ�Χ���ڵ����ع��ɵ�patch
        y2(:,ind) = reshape(I_origin(patch_height_index + k1 - 1,patch_width_index + k2 - 1)',1,number_patch);  
    end
end
% ʹ��ŷ����þ��룬������patch���ڷ�Χ���ڣ�Ѱ����L�������
center_patch_num = 2;
for iii = 1:center_patch_num^2
    if flag == 1
        center_patch_x = floor((iii - 1) / center_patch_num) + 1;
        center_patch_y = iii - (center_patch_x - 1) * center_patch_num; 
        temp = round(length(patch_height_index) / (center_patch_num * 2) * (center_patch_x * 2 - 1) - 1) * length(patch_height_index) + ...
            round(length(patch_width_index) / (center_patch_num * 2) * (center_patch_y * 2 - 1));   % ȡ��Χ���м��patch��Ϊ����patch
        patch_center = y2(temp,:);                  %%%%%%
    else
        patch_center = center;
    end
    % ���㵱ǰ��ѡģ����������� 
    % [~,B,C,D] = dwt2(I(L_index_begin(1):L_index_begin(1) + L_select_height - 1,...
    %     L_index_begin(2):L_index_begin(2) + L_select_width - 1),'db1');                                              % ��άС���任
    % t_L = median(median(median(abs([B,C,D])))) / 0.6745 ;                   % ���������ı�׼ƫ��
    % 
    % t_par = (t / t_L)^3;
    % L = round(L * t_par);
    % if L >= number_patch
    %     L = number_patch - 1;
    % end
    % fprintf('%d\n',L);
%     temp_dis_norm = (y2 - repmat((mean(y2'))',1,m * m))./ repmat((var(y2'))',1,m * m)...
%         - repmat((patch_center - repmat(mean(patch_center),1,m * m))./repmat(var(patch_center),1,m*m),number_patch,1);      % �ȹ�һ��֮���ټ���ŷ����þ��룬��ԭ�Ĳ�ͬ
    y2 = y2(:,:) - repmat(mean(y2,2),1,patch_size) * 0.2;
    patch_center = patch_center - repmat(mean(patch_center),1,patch_size) * 0.2;    
    temp_dis = y2(:,:) -  repmat(patch_center,number_patch,1);               % ����������patch������patch֮���ŷ����þ���                  %%%%
    temp_dis2 = sum(temp_dis.^2,2);
    [~,index] = sort(temp_dis2(:));                                         % ����ŷ����þ����������
    P(:,1:L + 1) = y(index(1:L + 1),:)';                                    % ������ӽ���Զȡ��L��patch
    %% step2����SVD_based denoising
    P_ave = mean(P');
    P_SVD = zeros(size(P));
    P = P - repmat(P_ave',1,L + 1);
    [U,S,V] = svd(P);                                                       % ����SVD�任
    [M,N] = size(P);
    [n1,n2] = size(S);
    sum_k_1 = 0;
    k = 0;
    for j2 = min(n1,n2) : -1 : 2
        sum_k_1 = sum_k_1 + S(j2,j2)^2;                                     % ����ͨ��svd�任�õ�������ֵ���Ӻ���ǰ��ȡƽ����
        sum_k = sum_k_1 + S(j2 - 1,j2 - 1)^2;
        if sum_k_1 <= t^2 * (L + 1) * patch_size && sum_k >= t^2 * (L + 1) * patch_size             % ������������������֮��
            k = j2 - 1;                                                     % ���Ӧȡ��ά��
            break;
        end
    end
    S2 = zeros(k,k);
    U2 = zeros(M,k);
    V2 = zeros(N,k);
    S2(:,:) = S(1:k,1:k);                                                   % ����ά��r�ع�������
    U2(:,:) = U(:,1:k);
    V2(:,:) = V(:,1:k);
    P_SVD(:,:) = U2 * S2 * V2' + repmat(P_ave',1,L + 1);                                                 % ���任���patch group���浽����P_SVD 
%     fprintf('%d,%d\n',k,L);
    P_SVD_error = P_SVD - (P + repmat(P_ave',1,L + 1));
    P_SVD_error_var = var(P_SVD_error);
    P_SVD_select = (P_SVD_error_var <= (t^2 * 0.8)); 
    k_record_index = k_record_index + 1;
    k_record(k_record_index,k_record_index_iter) = k;
%     fprintf('%d\n',k);
    %% step3����aggregation
    % aggregate pixel
    w_temp = 0;
    if k < L + 1
        w_temp = 1 - k/(L + 1);                                             % ��������ص�Ȩ��
    elseif k == L + 1
        w_temp = 1/(L + 1);
    end
    for ii = 1 : L + 1
        %if P_SVD_select(ii) == 1 || flag == 2
            index_height = floor(index(ii) ./ length(patch_width_index)) + 1;
            index_width = index(ii) - length(patch_width_index) * (index_height - 1);
            if index_width == 0
                index_width = length(patch_width_index);
                index_height = index_height - 1;
            end
            X = patch_height_index(index_height);
            Y = patch_width_index(index_width);
            temp = w(X:X + m - 1,Y:Y + m - 1) + w_temp .* ones(m,m);
            I2(X:X + m - 1, Y: Y + m - 1) = ((I2(X:X + m - 1, Y: Y + m - 1) .* w(X:X + m - 1,Y:Y + m - 1) ...
                    + reshape(P_SVD(:,ii)',m,m)' * w_temp)) ./ temp;
            w(X:X + m - 1,Y:Y + m - 1) = temp;
       % end
    end
    if flag ~= 1
        break;
    end
end
end

