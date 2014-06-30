function [OutImg OutImgIdx] = PCA_output(InImg, InImgIdx, PatchSize, NumFilters, V,scale)
% Computing PCA filter outputs
% ======== INPUT ============
% InImg         Input images (cell structure); each cell can be either a matrix (Gray) or a 3D tensor (RGB)   
% InImgIdx      Image index for InImg (column vector)
% PatchSize     Patch size (or filter size); the patch is set to be sqaure
% NumFilters    Number of filters at the stage right before the output layer 
% V             PCA filter banks (cell structure); V{i} for filter bank in the ith stage  
% ======== OUTPUT ===========
% OutImg           filter output (cell structure)
% OutImgIdx        Image index for OutImg (column vector)
% ========= CITATION ============
% T.-H. Chan, K. Jia, S. Gao, J. Lu, Z. Zeng, and Y. Ma, 
% "PCANet: A simple deep learning baseline for image classification?" submitted to IEEE TPAMI. 
% ArXiv eprint: http://arxiv.org/abs/1404.3606 

% Tsung-Han Chan [thchan@ieee.org]
% Please email me if you find bugs, or have suggestions or questions!

addpath('./Utils')
% 预处理以及与滤波器相卷积
ImgZ = length(InImg);
mag = (PatchSize-1)/2;
OutImg = cell(NumFilters*ImgZ,1); 
cnt = 0;
for i = 1:ImgZ
    [ImgX, ImgY, NumChls] = size(InImg{i});
    img = zeros(ImgX+PatchSize-1,ImgY+PatchSize-1, NumChls);
    img((mag+1):end-mag,(mag+1):end-mag,:) = InImg{i};     % 0-padding
    im = im2col_general(img,[PatchSize PatchSize]); % collect all the patches of the ith image in a matrix
    im = bsxfun(@minus, im, mean(im)); % patch-mean removal 
    [img_cs_1d,Theta_1d,Phi,mat_dct_1d]=getCSdata(im*im',scale);
    Theta_1d=Phi*mat_dct_1d;  
    sparse_rec_1d=zeros(size(im*im',1),size(im*im',1)); 
    for s=1:NumFilters
        cnt = cnt + 1;
        sparse_rec_1d=V(:,s)'*im;
%         size(V(:,s))
%         size(im)
%         double(reshape(sparse_rec_1d,ImgX,ImgY))
        OutImg{cnt} = double(reshape(sparse_rec_1d,ImgX,ImgY));
%         figure
%         subplot(2,1,1)
%         imagesc(OutImg{cnt})
%         subplot(2,1,2)
%         imagesc(img)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    InImg{i} = [];
end
OutImgIdx = kron(InImgIdx,ones(NumFilters,1)); 