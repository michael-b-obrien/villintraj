% This script returns the barcodes of the i frames where i can be set via
% from 1 to all 82 and uses n epsilon intervals between 0.1 and 0.2 where n
% is defined by the user input
% This script saves all barcodes as .fig files for i frames, saves the
% output as PHclusterinResults_'date' where the date is automatically
% recorded by MATLAB for the file name.  A diary is kept in the same folder
% as the barcodes to record all actions within each script
%% First load Javaplex
cd 'C:\Users\Mike\Downloads\javaplex-4.3.0\javaplex-4.3.0\src\matlab\for_distribution'
load_javaplex
%% Change directory to desired folder with distance matrix/trajectory information
cd 'C:\Users\Mike\Documents\4. Senior 2017-2018\Summer 2017 Research\TDA'
clear
clc
tic
% Define the folders and file names to which the diary and workspace variables will be saved
b1='C:\Users\Mike\Documents\4. Senior 2017-2018\Summer 2017 Research\TDA\barcodes\Diary';
a1='C:\Users\Mike\Documents\4. Senior 2017-2018\Summer 2017 Research\TDA\PHclusterinResults_';
a2=datestr(now,'mmmm_dd_yyyy');
a3='.mat';
a4=strcat(a1,a2,a3);
b2=strcat(b1,a2);
diary(b2)
%% Load trajectory and define distance matrix
load villin_trj0.mat;
M = distMatrices;
nsize = size(M,2);
%clear old stored variables;
%% Define inputs for desired barcodes
frameamt=input('How many frames?  ');
eps=input('How many epsilon intervals?  ');
epsilons=linspace(0.1,0.2,eps);
frames=[1:frameamt];
for i = 1:length(frames)
    frame = frames(i);
    D = reshape(M(frame,:,:),nsize,nsize);
    
    m_space = metric.impl.ExplicitMetricSpace(D);
    max_dimension = 1; % Betti-0 and Betti-1 computed
    max_filtration_value = 0.6; % Maximum filtration value
    num_divisions = 1000; 
    stream = api.Plex4.createVietorisRipsStream(m_space, max_dimension, max_filtration_value, num_divisions);
    num_simplices = stream.getSize();   
    persistence = api.Plex4.getModularSimplicialAlgorithm(max_dimension,2);
    intervals = persistence.computeAnnotatedIntervals(stream);
    options.max_filtration_value = max_filtration_value;
    options.max_dimension = max_dimension - 1;
    options.min_dimension = options.max_dimension;
    
    %options.side_by_side = true;
    %options.line_width = 1.2;
    
    %figure;
    plot_barcodes(intervals, options);
    s1 = '.fig';
    s2 = num2str(i);
    s0='C:\Users\Mike\Documents\4. Senior 2017-2018\Summer 2017 Research\TDA\barcodes\barcode_Frame';
    s = strcat(s0,s2,s1);
    savefig(s)
    
    clear clustering_scale1 clustering_scale2 clustering_scale3;
    %Save: frame number, 3 scales, for each scale: # components and
    % what is in each component
  cluster=[];
   for jjj=1:eps
        epsilonval=epsilons(jjj);
        componentVertexIndices1 = verticesInEachComponent(stream, epsilonval);
        nsize1 = size(componentVertexIndices1,1);
        data{i}{1} = ['frame ', num2str(i)];
            for k1 = 1:nsize1
                k2=jjj+1;
                data{i}{k2}{k1} = {['scale=', num2str(epsilonval)], ['component ', num2str(k1), ' out of ', num2str(nsize1)], componentVertexIndices1{k1}};
            end
%        cluster=[cluster; clustering_scale1];
   end
%   data_cluster={};
%   for jj=1:size(cluster,1)
%       data_cluster{jj}={cluster(jj,:)};
%   end
%   data{i}{1} = {['frame ', num2str(i)]};
%   for kk=1:eps
%       k2=kk+1;
%       data{i}{k2} = {data_cluster(kk)}; 
%   end
end
readme = strcat('Clustering results using dimension 0 persistent homology for ',num2str(eps),' scales:    ',num2str(epsilons));
save(a4, 'readme', 'data');
toc
diary off