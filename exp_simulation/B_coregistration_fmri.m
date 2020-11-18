%% generate fMRI BOLD signals in scout areas
% resample volume of T1 to dowmsample the fMRI voxels
% delete the formmer interpolation and caculate the new one:[MRI registration]
% import the cortex named as 'cort'
% import T2 Mask as 'M'
% import T2-mean as 'T2'
% import T2-mean-copy as T2C
SNR=10;           %ָ������ȣ� 5 10 15
load fMRI

% % plan1  % % % f1-V1=v1l
% % % % % % % % % f2-V2=v1r
% % % % % % % % % f3-V3=v2l
% % % % % % % % % f4-V4=v2r
% atlas=cort.Atlas(8).Scouts;
% % plan2  % % %
% f1-S1: lateral occipital R
% f2-S2: rostralmiddlefrontal L
% f3-S3: rostralmiddlefrontal R
% f4-S4: supramarginal L
atlas=cort.Atlas(9).Scouts;
%% get the ROI vertices
V=cell(1,4);
for i=1:4;
    V{i}=atlas(i).Vertices;
end
% wait a second, to coregistrate the cortex and voxel first
%% cortex(eeg) and voxels(fmri) coregistration
% ���룬����������
mask=cort.tess2mri_interp;    
[likelihood ind]=max(mask);   %ind: index of cortex
if isempty(find(likelihood<=0.7))
    sprintf('fully project');
end
%% ��ʼ������
%T2_t:T2 time course
%T2_r:T2 reshape
%T2_non0: T2 space which is non-zero;
%fv: index of unique ROI areas in fMRI 
%fc: fmri core area intersected with T2 area.
%% index parameters
coor=cell(1,4);                   %��ͬԴ����������
fv=cell(1,4);                     %fmri unique source
fc=cell(1,4);                     %fmri core area intersected with T2 area. 
fcore_bold=cell(1,4);             %fmri core bold signals
SNR_check=cell(1,4);              %check SNR of different ROI
%% area parameters:
% plan 1
mask_t=find(M.Cube~=0);           %import Mask.hdr as 'M'
mask_o=find(M.Cube==0);           %out of mask area
% plan 2
% T2_non0=find(T2.Cube~=0);         %T2 space : non-zero space which T2 belongs to
% T2_thr=find(T2.Cube>76);          %T2 outline
% time length
t=size(fmri_b{1},2);              %time course of fMRI
[r1 r2 r3]=size(T2.Cube);
%% ����fMRI�ռ�
% ����һ��mask�ڵ�Ϊ������fMRI��mask���ȫΪ0
T2_r=double(reshape(T2.Cube,[r1*r2*r3,1])); 
% �����ʼ��
T2_t=zeros(size(T2_r,1),t);
T2_t(mask_t,:)=T2_r(mask_t)*zeros(1,t);    %������Ϊ0
T2_t(mask_o,:)=T2_r(mask_o)*zeros(1,t);    %������Ϊ0����ʵ���Գ���eyes���󣬼������Ᵽ��ԭ״
% �����ڼ�����
T2_t(mask_t,:)=T2_t(mask_t,:)+randn(size(T2_t(mask_t,:))); %��������Ϊ0
T2_t(mask_t,:)=T2_t(mask_t,:).*0.01 ;         %���ŵ�0.1��������֤�ɵ��������8.7dB����

% ��������������Դ��һ����ͼ��ֻ�Ա�Ե����ƥ��






%% ��������
for k=1:4
[x y z]=ind2sub([91 109 91],ind(1,V{k}));
coor{k}=[x;y;z]';
aug=[];
%augmentation voxels space����ÿ�������Ϊ��������6����
     for i=1:size(V{k},2)         
        for j=1:3        
           for u=coor{k}(i,j)-2:coor{k}(i,j)+2
               temp=coor{k}(i,:);
               temp(j)=u;
               aug=[aug;temp];
           end
         end
     end
aug=aug(find((0<=aug(:,1)<=r1)&(0<=aug(:,2)<=r2)&(0<=aug(:,3)<=r3)),:);
coor{k}=[coor{k};aug];
%% ������4��Դ����������coor
ind_b=sub2ind([91 109 91],coor{k}(:,1),coor{k}(:,2),coor{k}(:,3));     %��������ֵ                   %��������λ��
fv{k}=unique(ind_b);                                                 %ɸѡ�����ظ��� 
%�ҳ���ͬ���֣�intersect
[core ia ib]=intersect(fv{k},mask_t);      % ɸѡ��λ�ڹ����������ڵ�����
%[core1 ia ib]=intersect(fv{1},T2_thr);    % plan 2
fc{k}=core;

%% ���Ӿ�����ֱ����ָ������ȵ�������fMRI�ź�
bold=repmat(fmri_b{k},size(fc{k}));
[bold_n noise]=noisegen(bold,SNR);         %����ָ������ȵ�����
SNR_check{k}=snr(bold(1,:),noise(1,:)) ;    %check SNR  
fcore_bold{k}=bold_n;                      %record signal;
T2_t(fc{k},:)=fcore_bold{k};               %bold with noise =bold +noise
end
clear ia ib x y z noise                    %������Ϣ �����������ſռ�
clear i j k
%% ��������֮���ٿ��ǹ�һ�� ƽ���� �� �����õ�4D����
%% T2��ƽ��Ӱ��
%��һ�����й�һ������ӳ�䵽����[a,b]�ڣ�mapminmax��x,a,b��
%�����࣬0�Ĳ�ӳ�䣬����ӳ�䵽80���£���������ӳ�䵽0-500��
T2_tmap=zeros(size(T2_r,1),t);
sum_v=size([fc{1};fc{2};fc{3};fc{4}],1);
core=unique([fc{1};fc{2};fc{3};fc{4}]);
%T2�����ڷ�����
T2_tmap(mask_t,:)=mapminmax(T2_t(mask_t,:),0,100);
%Դ�����ڷ�����
T2_tmap(core,:)=mapminmax(T2_t(core,:),0,800);             %% ���ű���Ϊ1��5 
%T2_tmap=diyscale(T2_t,mask_t,0,250);
%�ڶ������о�ֵ������
T2_mean=mean(T2_tmap,2);                          
T2C.Cube=uint8(reshape(T2_mean,[r1 r2 r3])); %���浽T2C���ڸ����ϲ鿴Ч��
% a=T2_t(mask_t,:);
% b=T2_t(core,:);
% c=T2_tmap(mask_t,:);
% d=T2_tmap(core,:);
%% T2��ʱ��Ӱ��T2 timecourse
T2_f=T2_tmap(:,2:t);
T2_f=reshape(T2_f,[r1,r2,r3,t-1]);
T2_ff=single(T2_f);
img=single(reshape(T2_mean,[r1 r2 r3]));

%% ���һ������T2C�ػ�brainstorm��T2C import �� mean copy
%   ֮����brainstorm����.nii�ļ���t2.nii
nii=load_nii('t2.nii');
nii.img=T2_ff;
nii.hdr.dime.dim=[4    r1   r2    r3   t-1     1     1     1];
nii.original.hdr.dime.dim=[4    r1   r2    r3   t-1     1     1     1];
save_nii(nii,'run-01.nii');

%% ���ҵļ��ʱд�ĳ���
% c=b(T2_non0);
% mean(c);
% h=histogram(c,500);

% T2_thr=find(b>60&b<160);
% b(T2_thr)=0;
% T2C.Cube=b;
% [core ia ib]=intersect(fv{1},T2_thr); 

% b(mask_t)=0;
% T2C.Cube=b;
%  [core ia ib]=intersect(fv{1},mask_t);

% �����
%              new_coor=coor{k}(i,:); 
%              if ((j==1||j==3)&&coor{k}(i,j)~=91)||(coor{k}(i,j)~=109&&j==2) 
%                new_coor(j)=coor{k}(i,j)+1;
%              end
% %              if ((j==1||j==3)&&coor{k}(i,j)~=90)||(coor{k}(i,j)~=108&&j==2) 
% %                new_coor(j)=coor{k}(i,j)+2;
% %              end
%              if coor{k}(i,j)~=0
%                new_coor(2,:)=new_coor(1,:);
%                new_coor(2,j)=coor{k}(i,j)-1;
%              end
%              coor{k}=[coor{k}; new_coor];
%          end
