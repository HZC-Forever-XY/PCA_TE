data=load('TE_data.mat');
%���ݶ�ȡ
data = struct2cell(data);
testdata =  data(1:22);
train = cell2mat(data(23));
train = train';
train_mean = mean(train);  %���� Xtrain ƽ��ֵ                           
train_std = std(train);    %���׼��                       
[train_row,train_col] = size(train); %�� train �С�����                                                                
train=(train-repmat(train_mean,train_row,1))./repmat(train_std,train_row,1); 
%��һ��
%��Э������� 
sigmatrain = cov(train);
%��Э���������������ֽ⣬lamda Ϊ����ֵ���ɵĶԽ���T����Ϊ��λ�������������� lamda �е�����ֵһһ��Ӧ��
[T,lamda] = eig(sigmatrain);
disp('����������С����'); 
disp(lamda); 
disp('����������'); 
disp(T);
%ȡ�Խ�Ԫ��(���Ϊһ������)���� lamda ֵ�������·�תʹ��Ӵ�С���У���Ԫ������ֵΪ 1�����ۼƹ�����С�� 90
%��������Ԫ���� 
D = flipud(diag(lamda));                             
num_pc = 1;                                          
while sum(D(1:num_pc))/sum(D) < 0.9    
num_pc = num_pc +1; 
end   
%ȡ�� lamda ���Ӧ���������� 
P = T(:,train_col-num_pc+1:train_col);
%ÿһ�д���һ����������
%�����Ŷ�Ϊ 99%��95%ʱ�� T2 ͳ�ƿ�����                        
T2UCL1=num_pc*(train_row-1)*(train_row+1)*finv(0.99,num_pc,train_row - num_pc)/(train_row*(train_row - num_pc)); 
T2UCL2=num_pc*(train_row-1)*(train_row+1)*finv(0.95,num_pc,train_row - num_pc)/(train_row*(train_row - num_pc)); 
%��ʼ����SPEͳ����
for i = 1:3 
    theta(i) = sum((D(num_pc+1:train_col)).^i); 
end 
h0 = 1 - 2*theta(1)*theta(3)/(3*theta(2)^2); 
ca = norminv(0.99,0,1); 
SPE = theta(1)*(h0*ca*sqrt(2*theta(2))/theta(1) + 1 + theta(2)*h0*(h0 - 1)/theta(1)^2)^(1/h0); 
%�������SPEͳ����
for k = 1:22
    %22���������
    test = cell2mat(testdata(k));
    %��ʼ���߼��
    n = size(test,1); 
    test=(test-repmat(train_mean,n,1))./repmat(train_std,n,1); 
    %����������һ��
    [r,y] = size(P*P'); 
    I = eye(r,y); %��λ����
    T2_test = zeros(n,1); 
    SPE_test = zeros(n,1); 
    for i = 1:n 
        T2_test(i)=test(i,:)*P*inv(lamda(52-num_pc+1:52,52-num_pc+1:52))*P'*test(i,:)';                                           
        SPE_test(i) = test(i,:)*(I - P*P')*test(i,:)';                                                                                    
    end 
    %��ͼ 
    figure (k);
    subplot(2,1,1); 
    plot(1:n,T2_test,'k');                                     
    title('��Ԫ����ͳ�����仯ͼT2'); 
    xlabel('������'); 
    ylabel('T^2'); 
    hold on;     
    line([0,n],[T2UCL1,T2UCL1],'LineStyle','--','Color','r');%������־�� 
    line([0,n],[T2UCL2,T2UCL2],'LineStyle','--','Color','g'); 
    subplot(2,1,2); 
    plot(1:n,SPE_test,'k'); 
    title('��Ԫ����ͳ�����仯ͼSPE')
    xlabel('������'); 
    ylabel('SPE'); 
    hold on;  
    line([0,n],[SPE,SPE],'LineStyle','--','Color','r'); 
end