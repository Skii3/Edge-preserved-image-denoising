function [ I2 ] = svd_again( I2,patch_size,L, step_patch,w,L_select_width,L_select_height,m,I,t,I_origin)
% patch_size:��ȡ��patch�Ĵ�С
% L��patch_group�Ĵ�С
% step_patch��ȡpatchʱ��step
% w�����ÿ�����ص�Ȩ�ؾ���
% L_select_width��L_select_height����L_select_width * L_select_height��Χ��ѡȡ���Ƶ�L��patch
% m:ÿ��patch�ĳ����
% I��ԭʼ������ͼƬ
% t�������Ĺ��Ʒ���

[height, width] = size(I2);
[I2_sort,index] = sort(reshape(I2',1,width * height));                      % ��ȥ��ͼ�������ֵ������������
ind = 1;
while(1)
    if I2_sort(ind) < 0
        ind = ind + 1;
    else
        break;
    end
end
while(1)
    if I2_sort(ind) ~= 0
        break;
    else                                                                    % ��������ֵΪ0�ĵ㣬����Ҫ������е�����svd����
        x = floor(index(ind) / width) + 1;                                       % ����õ�������ֵ������λ��
        y = index(ind) - width * (x - 1);
        if y == 0
            x = x - 1;
            y = width;
        end
        %% �õ���Χ�����Ͻǵ������
        temp_L_height_index = x - round(L_select_height / 3);               % ���㷶Χ�����Ͻǵ��������ͺ����꣨����ʹ��x��y���м䣩
        temp_L_width_index = y - round(L_select_width / 3);
        if temp_L_height_index < 1                                          % �����Ͻǵ��������Խ��
            temp_L_height_index = 1;
        elseif temp_L_height_index + L_select_height - 1 > height           % �����Ͻǵ����������ɷ�Χ��Խ��
            temp_L_height_index = height - L_select_height + 1;
        end
        if temp_L_width_index < 1                                          % �����Ͻǵ�ĺ�����Խ��
            temp_L_width_index = 1;
        elseif temp_L_width_index + L_select_width - 1 > width           % �����Ͻǵ�ĺ�������ɷ�Χ��Խ��
            temp_L_width_index = width - L_select_width + 1;
        end
        %% �õ�����δ��ֵ���ص������patch��ֵ
        temp_p_height_index = x - round(m / 3);               % ���㷶Χ�����Ͻǵ��������ͺ����꣨����ʹ��x��y���м䣩
        temp_p_width_index = y - round(m / 3);
        if temp_p_height_index < 1                                          % �����Ͻǵ��������Խ��
            temp_p_height_index = 1;
        elseif temp_p_height_index + m - 1 > height           % �����Ͻǵ����������ɷ�Χ��Խ��
            temp_p_height_index = height - m + 1;
        end
        if temp_p_width_index < 1                                          % �����Ͻǵ�ĺ�����Խ��
            temp_p_width_index = 1;
        elseif temp_p_width_index + m - 1 > width           % �����Ͻǵ�ĺ�������ɷ�Χ��Խ��
            temp_p_width_index = width - m + 1;
        end
        center = reshape(I_origin(temp_p_height_index:temp_p_height_index + m - 1,temp_p_width_index:temp_p_width_index + m - 1)',1,m * m);             %%%%%
        [I2,w] = step1_2_3( temp_L_height_index,temp_L_width_index, patch_size,L,I2,step_patch,w,L_select_width,L_select_height,m,I,t,2,I_origin,center);
        %% �ݹ���ã�ֱ�������������ص�
        I2 = svd_again( I2,patch_size,L, step_patch,w,L_select_width,L_select_height,m,I,t,I_origin);
        break;
    end
end

end

