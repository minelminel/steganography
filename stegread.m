%% function msgstring = stegread(picture, skip, outputfile)
% * * * CALLING FUNCTION WITH NO INPUT ARGS OPENS THE HELP WIZARD * * *
% * * * * SUPRESS FUNCTION OUTPUT BY ASSIGNING A DUMMY VARIABLE * * * *
%
% stegread TAKES AN INPUT IMAGE EITHER AS FILE.png OR AS ARRAY AND
% SYSTEMATICALLY DECODES THE HIDDEN MESSAGE
%
% 'SKIP' IS THE STRIDE INTERVAL BETWEEN HIDDEN ELEMENTS
% NOTE: IF SKIP VALUE IS UNKNOWN, USE WIZARD AND HIT RETURN WHEN PROMPTED
%   TO ENTER SKIP VALUE. A CELL ARRAY OF ALL POSSIBLE MESSAGES WILL BE
%   RETURNED.
%
% --INPUT ARGS--
% picture .....[uint8 array] OR '.png'
% skip ........[double]..... number of unaltered pixels between bits
% outputfile ..[string]..... .txt name of decoded text file
%
% --OUTPUT ARG--
% msgstring ...[string]
%
% Example:
% msgstring = stegread('MyStegWriteExample.png', 21)
% 
% © 2019 Michael Lawrenson
% 14-Feb-2019 00:02:04
function msgstring = stegread(varargin)


%% Initialization
filetype = '.png';
Print = true;    % set TRUE to print decoded message to screen
ShortestMessage = 5;  % smallest feasible length of message for CheckAllSkip
CheckAllSkip = false;


%% Interpret Arguments
switch nargin

    case 1      % decode picture with skip = 0
        picture = varargin{1};
        skip = 0;
        WriteFile = false;
        
    case 2      % decode picture with skip specified
        picture = varargin{1};
        skip = varargin{2};
        WriteFile = false;
        
    case 3
        picture = varargin{1};
        skip = varargin{2};
        outputfile = varargin{3};
        WriteFile = true;
        if contains(outputfile, '.txt') == 1
            outfilename = outputfile;
        else
            outfilename = strcar(outputfile, '.txt');
        end
        
    case 0  % WIZARD
        fprintf('\nWELCOME TO STEGREAD WIZARD!\n\n');
        picture = input('Enter image name [variable or .png file]: ','s');
        if isempty(picture)
            return
        end
        skip = abs(round(str2double(input('Enter skip number [ENTER if unknown]: ','s'))));
        if isnan(skip)
            % check all possible skip values
            CheckAllSkip = true;
        end
        outputfile = input('Enter filename for decoded text [ENTER to bypass]: ','s');
        if isempty(outputfile)
            fprintf('Message will not be saved to file.\n');
            WriteFile = false;
        else
            WriteFile = true;
        end        
        
    otherwise
        fprintf('\nWarning: Invalid arguments.\nType "help stegread" for more info.\n');
end


%% Read Image
% check if picture is a filename, or image array
pic_string = string(picture);
if contains(pic_string, filetype) == 1
    % picture is a filename
    Imageimport = imread(picture);
else
    % picture is an image array
    Imageimport = picture;
end


%% Check if SKIP value is known
if CheckAllSkip
    MaxIteration = floor(numel(Imageimport)/ShortestMessage);
    skip = 1:MaxIteration;
end


%% Allocate memory for array of decoded strings
msgstring = repmat({''}, numel(skip), 2);

    
%% Decode Image
for i = 1:length(skip)
    try
        Skip = skip(i);
        maxlen = ceil(numel(Imageimport)/(Skip+1));
        msgcell = cell(1, maxlen);   % initialize empty row vector
        for msgindex = 1:maxlen
            [Rm,Cm] = ind2sub(size(Imageimport),msgindex*(Skip+1));
            content = Imageimport(Rm,Cm);
            if content == 255
                break
            end
            msgcell(1,msgindex) = {char(content)};
        end
        msgcell = msgcell(~cellfun('isempty', msgcell));
        msgstring{Skip,2} = char(msgcell).';
        msgstring{Skip,1} = Skip;
    catch
        msgstring{Skip,2} = '';
        msgstring{Skip,1} = Skip;
    end
end


%% Remove rows with empty cells
msgstring(any(cellfun(@(x) any(isempty(x)),msgstring),2),:)=[];
Table = cell2table(msgstring);
Table.Properties.VariableNames = {'Skip','Message'};


%% Write .txt file (if specified)
if WriteFile
    fid = fopen(outfilename, 'wt');
    fprintf(fid, '%s', msgstring);
    fclose(fid);
end


%% Display Message (optional)
if Print
    switch numel(skip)
        case 1
            fprintf('\n%s\n', msgstring{1,2});
        otherwise
            disp(Table);
    end
end
% end of script
