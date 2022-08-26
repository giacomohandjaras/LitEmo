function SANe_Matlab2Gephi_color(GephiPrefix,AdjacencyMatrix,varargin)
% SANe_Matlab2Gephi exports a binary/weighted directed/undirected graph in
% Gephi readable format. It requires the output filename "GephiPrefix" and
% the graph "AdjacencyMatrix" to be specified.
%
% <GephiPrefix> specifies the name of output files. If a simple filename is
% provided, then files will be created in the current directory. Otherwise,
% a path can be specified and files will be stored accordingly. Two .csv
% files will be created: *_node.csv and *_edge.csv.
%
% <AdjacencyMatrix> stores the binary/weighted directed/undirected graph.
% AdjacencyMatrix is a n-by-n square matrix where the number of rows and
% columns corresponds to the number of nodes of the graph. For undirected
% graphs only the superior (or inferior) triangular part of the 
% AdjacencyMatrix is required.
%
% [NodeLabel] is a n-by-1 cell array storing node labels to be imported in
% Gephi. If not provided, node labels will be automatically created as 
% "Node_*".
%
% [NodeLabelAlt] is a n-by-1 cell array storing alternative node labels to be imported in
% Gephi. If not provided, node labels will be automatically created as 
% "Node_alt_*".
%
% [NodeAttribute] is a n-by-p numeric matrix storing node attributes, such
% as betweenness centrality or any other desired graph metric or attribute.
% If NodeAttribute is a matrix (i.e., p>1) multiple attributes will be
% assigned to each node and correctly interpreted by Gephi. If not
% provided, no attribute will be included in the *_node.csv file.
%
% [AttributeLabel] is a p-by-1 cell array storing attribute labels. If not
% provided, attribute labels will be automatically created as
% "Attribute_*".
%
% Usage:
% n_nodes = 10; %number of nodes
% labels = {'a','b','c','d','e','f','g','h','i','j'}; % node labels
% graph = randn(n_nodes,n_nodes).*...
%         randi([0,1],n_nodes,n_nodes).*...
%         ~eye(n_nodes,n_nodes); % create a random weighted directed graph
% SANe_Matlab2Gephi('mygraph',graph,'NodeLabel',labels)
%
% Luca Cecchetti, PhD. Social and Affective Neuroscience Group, MoMiLab,
% IMT School for Advanced Studies Lucca, Lucca, Italy.
% Contact: luca.cecchetti@imtlucca.it

InputOptions = inputParser; % Grab input settings

addRequired(InputOptions,'GephiPrefix',@(x)assert(ischar(x) ... % GephiPrefix is a required field. It is a character array
    && ~isempty(x) ... % not empty
    && isvector(x),... % an array
    'GephiPrefix is expected to be a character array'));

addRequired(InputOptions,'AdjacencyMatrix',@(x)assert(isnumeric(x) ... % AdjacencyMatrix is a required field. It has to be a numeric,
    && ~isempty(x) ... % not empty
    && size(x,1)==size(x,2) ... % squared
    && ismatrix(x) ... % matrix
    && sum(isnan(x(:)))==0,... % with no NaN
    'AdjacencyMatrix is expected to be a n-by-n numeric matrix with no NaN'));

addOptional(InputOptions,'NodeLabel',{},@(x)assert(iscell(x) ... % NodeLabel is an optional field. It has to be a cell
    && isvector(x),... % array storing nodes identity
    'NodeLabel should be a n-by-1 cell array'));

addOptional(InputOptions,'NodeLabelAlt',{},@(x)assert(iscell(x) ... % NodeLabelAlt is an optional field. It has to be a cell
    && isvector(x),... % array storing nodes identity
    'NodeLabelAlt should be a n-by-1 cell array'));
    
addOptional(InputOptions,'NodeAttribute',[],@(x)assert(iscell(x), ... % NodeAttribute is an optional field. It has to be a cell,
    'NodeAttribute is expected to be a n-by-p cell matrix'));

addOptional(InputOptions,'AttributeLabel',{},@(x)assert(iscell(x) ... % AttributeLabel is an optional field. It has to be a cell
    && isvector(x),... % array storing labels of node attributes
    'AttributeLabel should be a p-by-1 cell array'));

parse(InputOptions,GephiPrefix,AdjacencyMatrix,varargin{:}); % Parse input arguments

GephiPrefix = InputOptions.Results.GephiPrefix; % Read GephiPrefix
AdjacencyMatrix = InputOptions.Results.AdjacencyMatrix; % Read AdjacencyMatrix
NodeLabel = InputOptions.Results.NodeLabel; % Read NodeLabel
NodeLabelAlt = InputOptions.Results.NodeLabelAlt; % Read NodeLabel
NodeAttribute = InputOptions.Results.NodeAttribute; % Read NodeAttribute
AttributeLabel = InputOptions.Results.AttributeLabel; % Read AttributeLabel

NumberOfNodes = size(AdjacencyMatrix,1); % Estimate number of nodes

if isempty(NodeLabel) % If NodeLabel is empty
    NodeLabel = cell(NumberOfNodes,1); % Initialize empty node identity cell array
    
    for N = 1:NumberOfNodes % For each node
        NodeLabel{N} = strcat('Node_',num2str(N)); % the number is the identity
    end
else
    if numel(NodeLabel)~=NumberOfNodes % If the number of labels for nodes is not equal to the actual number of nodes
        fprintf(2,'[ERROR]: The number of node labels does not match the number of nodes in the AdjacencyMatrix.\n')
        return % Give feedback and exit the function
    end
end

if isempty(NodeLabelAlt) % If NodeLabelAlt is empty
    NodeLabelAlt = cell(NumberOfNodes,1); % Initialize empty node identity cell array
    
    for N = 1:NumberOfNodes % For each node
        NodeLabelAlt{N} = strcat('Node_alt_',num2str(N)); % the number is the identity
    end
else
    if numel(NodeLabelAlt)~=NumberOfNodes % If the number of labels for nodes is not equal to the actual number of nodes
        fprintf(2,'[ERROR]: The number of alternative node labels does not match the number of nodes in the AdjacencyMatrix.\n')
        return % Give feedback and exit the function
    end
end


if ~isempty(NodeAttribute) % If node attributes is not empty
    
    NumberOfAttributes = size(NodeAttribute,2); % Then just grab the number of attributes as the number of columns
    
end

if ~isempty(NodeAttribute) % If a matrix of node attributes is provided
    if isempty(AttributeLabel) % but there are no label
        
        AttributeLabel = cell(1,NumberOfAttributes); % Initialize empty node attribute cell array
        AttributeHeader=[];
        
        for P = 1:NumberOfAttributes % For each attribute
            AttributeLabel{P} = strcat('Attribute_',num2str(P)); % the number is the identity
            AttributeHeader=cat(2,AttributeHeader,strcat(';Attribute_',num2str(P)));
        end
    else
        
        AttributeHeader=[];
        for P = 1:NumberOfAttributes % For each attribute        
            AttributeHeader=cat(2,AttributeHeader,strcat(';',AttributeLabel{P}));
        end
                
    end
    
end

if ~isempty(NodeAttribute) && ~isempty(AttributeLabel) % If NodeAttribute and AttributeLabel are present
    if NumberOfAttributes ~= numel(AttributeLabel) % If dimensions do not match
        
        fprintf(2,'[ERROR]: The number of attribute labels does not match the number of attributes in the NodeAttribute matrix.\n')
        return % Give feedback and exit the function
        
    end
end

GephiPrefixNode=strcat(GephiPrefix,'_node.csv'); % Create node table filename
GephiPrefixEdge=strcat(GephiPrefix,'_edge.csv'); % Create edge table filename

if isfile(GephiPrefixNode) && isfile(GephiPrefixEdge) % If files already exist
   
    fprintf(2,'[WARNING]: %s and %s already exist.\n',GephiPrefixNode,GephiPrefixEdge) % Give user a feedback
    OverwriteOpt=input('[INFO]: Overwrite? (y or n)\n','s'); % Ask how to proceed: overwrite files or not
    
    if strcmpi(OverwriteOpt,'n') || strcmpi(OverwriteOpt,'no') % If user prefers not to overwrite
        GephiPrefix=input('[INFO]: Please specify an alternative filename/path:\n','s'); % Then specify another filename/path
        GephiPrefixNode=strcat(GephiPrefix,'_node.csv'); % Update node table filename
        GephiPrefixEdge=strcat(GephiPrefix,'_edge.csv'); % Update edge table filename
        
    elseif strcmpi(OverwriteOpt,'y') || strcmpi(OverwriteOpt,'yes') % If user prefers to overwrite
        fprintf('[INFO]: Overwriting files.\n') % Just give a feedback
        
    else % Otherwise there is a problem with the choice. Exit and do nothing
        fprintf(2,'[ERROR]: No valid option (y or n) specified. Aborting\n')
        return
    end
    
end
    
%% Write node table

fidNodeTable = fopen(GephiPrefixNode,'w','native','UTF-8'); % Open text file to write node table

PrecisionOutput = 6; % This controls the digit precision in the csv file for node attributes

if ~isempty(AttributeLabel) % If node attributes are provided
    fprintf(fidNodeTable,'%s%s\n','Id;Label;AltLabel',AttributeHeader); % Write node table header
    for N = 1:NumberOfNodes % For each node
        fprintf(fidNodeTable,'%g;%s;%s;%s\n',... % Write in node table
            N,... % Node ID
            NodeLabel{N},... % Node Label
            NodeLabelAlt{N},... % Alt Node Label
            strrep(strrep(strrep(NodeAttribute{N,:},' ',';'),'[',''),']','')); % Node Attributes
    end
else
    fprintf(fidNodeTable,'%s\n','Id;Label;AltLabel'); % Write node table header
    for N = 1:NumberOfNodes % For each node
        fprintf(fidNodeTable,'%g;%s;%s\n',... % Write in node table
            N,... % Node ID
            NodeLabel{N},... % Node Label
            NodeLabelAlt{N}); % Alt Node Label
    end
end

fclose(fidNodeTable); % Close node file table

%% Write edge table

%[FromEdge,ToEdge] = find(AdjacencyMatrix~=0); % Find non-zero edges
%NumberOfEdges = numel(FromEdge); % Overall number of edges

%fidEdgeTable = fopen(GephiPrefixEdge,'w','native','UTF-8'); % Open text file to write edge table
%fprintf(fidEdgeTable,'%s\n','Source;Target;Label;Weight'); % Write header of the edge table

%for E = 1:NumberOfEdges % For each edge
    
%    fprintf(fidEdgeTable,'%g;%g;%s;%g\n',... % print
%        FromEdge(E),... % origin node
%        ToEdge(E),... % target node
%        strcat('Node_',num2str(FromEdge(E)),'_to_',num2str(ToEdge(E))),... % a label
%        AdjacencyMatrix(FromEdge(E),ToEdge(E))); % edge weigth
    
%end

%fclose(fidEdgeTable); % Close edge file table

fprintf('[INFO]: Process complete.\n[INFO]: %s and %s successfully created.\n',GephiPrefixNode,GephiPrefixEdge) % Give user a feedback

end
