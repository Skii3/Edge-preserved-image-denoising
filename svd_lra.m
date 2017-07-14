% ���ģ�An efficient SVD_based method for image denoising
close all
clear
clc
clear global
global k_record
global k_record_index
global k_record_index_iter
k_record_index = 0;
k_record_index_iter = 1;
%% read the noise image
for noise_sigma = 10:10:10
    % I = imread('lena.jpg');                                           % ��ȡͼƬ
    I = imread('fingerprint.png'); 
% I = imread('3.jpg'); 
    I_origin = double(I);
    temp = size(I);                                                    % �õ�ͨ��������Ϊ3ͨ����ת��Ϊ1ͨ������Ϊ1ͨ���򲻴���
    if length(temp) == 3 && temp(3) == 3
        I = rgb2gray(I);
    end
    imwrite(I,'ԭͼ��.jpg');                                            % ����ԭʼͼ��
    imshow(I),title('ԭʼͼ��');                                        % ��ʾԭʼͼ��

    randn('seed', 0);                                                   % �����������
    noise = noise_sigma * randn(size(I));                                        % ͨ��������ӵõ�����ͼ��
    I = double(I);
    I = I + noise;                                                      % �õ���������֮���ͼ
    I = imresize(I, [512,512]);
     temp = size(I);   
%     I_origin = double(I);
    figure,imshow(I / 255),title('�Ӹ�˹������');                        % �����������֮���ͼ
    imwrite(I / 255,'�Ӹ�˹������.jpg');
    tic
    %% estimate noise standard devition by computing median absolute devition of the finest wavelet coefficients
    %% ���и�˹��ͨ�˲�
    f = fspecial('gaussian',[2 2],5);    
    I_origin_est = imfilter(I,f,'same');

    figure,imshow(I_origin_est,[]);

    [~,B,C,D] = dwt2(I,'db1');                                          % ��άС���任
    t = median(median(median(abs([B,C,D])))) / 0.6745 ;                  % ���������ı�׼ƫ��
%     scale = t_scale(t);
%     t = t * scale ;                                                     % �������Ƶ�У׼
    I_denoise = func_svd_lra4(I,t,I_origin_est);                        % ���ú�������svdȥ�룬I_origin_est��patch group�Ļ�׼����
    tab1 = tabulate(k_record(:,1));
    figure,imshow(I_denoise,[]),title('��һ��ȥ��ͼ��');
    imwrite(I_denoise / 255,'��һ��ȥ��.jpg');
    K = I_denoise;
    MSE = sum(sum((I_origin - K).^2)) / temp(1) / temp(2);
    PSNR1 = 20 * log10(255 / sqrt(MSE));
    %% back projection
    k_record_index_iter = 2;
    delta = 0.5;                                                          
    I_back = I_denoise + delta .* (I - I_denoise);                      % ����µ���������ͼ��
    I_origin_est = imfilter(I_back,f,'same');                           % �����˲�����ȥ��
    figure,imshow(I_origin_est,[]);
%     for gamma = 0.60:0.01:0.60
    gamma = 0.60;
        % t_2 = gamma * sqrt(abs(t^2 - sum(sum((I - I_back).^2))/(temp(1) * temp(2))));     
%         [~,B,C,D] = dwt2(I_back,'db1');                                     % ��άС���任
%         t_2 = median(median(median(abs([B,C,D])))) / 0.6745 * 0.8;                % ������ͼ��������ı�׼ƫ��
    %     scale = t_scale2(t_2);
    %     t_2 = t_2 * scale;
        t_2 = gamma * sqrt(abs((noise_sigma^2 * temp(1) * temp(2) - sum(sum(I - I_back).^2)))/ temp(1) / temp(2));
        I_final = func_svd_lra4(I_back,t_2,I_origin_est);                   % ��һ�ε��ú�������svdȥ��
        tab2 = tabulate(k_record(:,2));
        figure,imshow(I_final,[]),title('�ڶ���ȥ��ͼ��');
        imwrite(I_final / 255,'�ڶ���ȥ��.jpg');                             
        figure,imshow(I - I_denoise,[]);                                    %��ʾԭʼͼ�����һ��ȥ��ͼ��Ĳ�
        figure,imshow(I_final - I_back,[]);                                 %��ʾ�ڶ���ȥ��ͼ�����µ�������ͼ��֮��
        toc
        %% ���������
        K = I_final;
        MSE = sum(sum((I_origin - K).^2)) / temp(1) / temp(2);
        PSNR = 20 * log10(255 / sqrt(MSE))
%         close all
%         gamma
%     end
end