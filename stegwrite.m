%% function picture = stegwrite(message, skip, outputfile, inputfile)
% * * * CALLING FUNCTION WITH NO INPUT ARGS OPENS THE HELP WIZARD * * *
% * * * * SUPRESS FUNCTION OUTPUT BY ASSIGNING A DUMMY VARIABLE * * * *
%
% stegwrite TAKES AN INPUT TEXT EITHER AS FILE.txt OR AS RAW STRING/CHAR AND
% SYSTEMATICALLY HIDES THE INDIVIDUAL CHARACTERS WITHIN AN IMAGE
%
% 'SKIP' IS THE STRIDE INTERVAL BETWEEN HIDDEN ELEMENTS, DEFAULT IS 0
% NOTE: as per MATLAB convention, data is written in columns
%   top of column --> bottom of column
%            left --> right
%
% --INPUT ARGS--
% message .....[string]..... text to be encoded
% skip ........[double]..... number of unaltered pixels between bits
% outputfile ..[string]..... .png name of image to create
% inputfile ...[string]..... .png of image to overwrite
%
% --OUTPUT ARG--
% picture .....[uint8 array]
%
% Example:
% picture = stegwrite('Hello, world!', 21, 'MyStegWriteExample.png');
% 
% © 2019 Michael Lawrenson
% 13-Feb-2019 22:47:13
function picture = stegwrite(varargin)


%% Initialization
endbit = 'ÿ'; % acts as a DELIMITER to break decryption loop
filetype = '.png';
defaultselect = 0;
DisplayImage = true;  % set this to TRUE to display image upon creation


%% Assign variables based on number of arguments
switch nargin
    
    case 1  % Message
        % encode message to blank initialized array with skip = 0
        message = char(varargin(1));
        skip = 0;
        WriteFile = false;
        ReadFile = false;
        
    case 2  % Message, Skip
        message = char(varargin(1));
        skip = cell2mat(varargin(2));
        WriteFile = false;
        ReadFile = false;
        
    case 3  % Message, Skip, OutputFile
        message = char(varargin(1));
        skip = cell2mat(varargin(2));
        outputfile = char(varargin(3));
        WriteFile = true;
        ReadFile = false;
        
    case 4  % Message, Skip, OutputFile, InputFile
        message = char(varargin(1));
        skip = cell2mat(varargin(2));
        outputfile = char(varargin(3));
        inputfile = char(varargin(4));
        WriteFile = true;
        ReadFile = true;
        
    case 0  % WIZARD
        fprintf('\nWELCOME TO STEGWRITE WIZARD!\n\n');
        message = input('Enter message to be hidden [string or .txt file]: ','s');
        if isempty(message)
            return
        end
        skip = abs(round(str2double(input('Enter skip number [ENTER to use default 0]: ','s'))));
        if isnan(skip)
            skip = 0;
        end
        outputfile = input('Enter filename for created image [ENTER to bypass]: ','s');
        if isempty(outputfile)
            fprintf('Image will not be saved to file.\n');
            WriteFile = false;
        else
            WriteFile = true;
        end
        inputfile = input('Enter filename for background image [ENTER to choose from defaults]: ','s');
        if isempty(inputfile)   % ask if NOISE or BLACK or WHITE
            ReadFile = false;
            fprintf('\nSpecify default background\n1 -- NOISE\n2 -- WHITE\n3 -- BLACK\n');
            defaultselect = round(str2double(input('Enter selection number: ','s')));
            if isnan(defaultselect) || defaultselect > 3 || defaultselect < 1
                defaultselect = 0;
                fprintf('Utilizing default.\n');
            end
        else
            ReadFile = true;
        end
        
    otherwise
        fprintf('\nWarning: Invalid arguments.\nType "help stegwrite" for more info.\n');
        return
end


%% Check if Message is raw string or .txt file
msg_string = string(message);
% check if message is a filename, or string
if contains(msg_string, '.txt')
    % message is a filename
    try
        message = fileread(which(message));
    catch
        fprintf('%s not found.\n', message);
        return
    end
else
    % message is a raw string
end


%% Calculate required Image size
message = uint8(strcat(message, endbit));
message_length = length(message);
needed = (skip+1) * message_length;
dimen = ceil(sqrt(needed));


%% Check if requested array is of excessive size
if dimen > 1E5
    Question = sprintf('You are requesting an image of size %d x %d\nAre you sure you would like to proceed?\nImages of this size may require excessive CPU resources.',dimen,dimen);
    Answer = questdlg(Question,'Warning','Yes','No','No');
    if isempty(Answer) || strcmp(Answer,'No')
        return
    end
end

%% Pre-allocate Image array
% UN-COMMENT TO SET DEFAULT BACKGROUND ((ONLY 1 LINE SHOULD BE ENABLED))
% * * * * * * * * * * * * * * * * * * * *
% * * * * * * * * * * * * * * * * * * * *
default = uint8(round(255*(rand(dimen))));      % NOISE
% default = 255 * ones(double(dimen), 'uint8');   % WHITE
% default = zeros(double(dimen), 'uint8');        % BLACK
% * * * * * * * * * * * * * * * * * * * *
% * * * * * * * * * * * * * * * * * * * *

if ~ReadFile
    switch defaultselect
        case 1  % NOISE
            Image = uint8(round(255*(rand(dimen))));
        case 2  % WHITE
            Image = 255 * ones(double(dimen), 'uint8');
        case 3  % BLACK
            Image = zeros(double(dimen), 'uint8');
        otherwise   % 0
            Image = default;
    end
else
    if contains(inputfile, filetype) == 1
        filename = inputfile;
    else
        filename = strcat(inputfile, filetype);
    end
    try
        Image = imread(which(filename));
    catch
        fprintf('%s not found.\n',filename);
        return
    end
end


%% Concealment Loop
for msgindex = 1:message_length
    [R,C] = ind2sub(size(Image), msgindex*(skip+1));
    Image(R,C) = message(msgindex);
end


%% Function Output Argument
picture = Image;  % FUNCTION OUTPUT [uint8 array]


%% Option to display picture
if DisplayImage
    figure;
    imshow(picture,'InitialMagnification','fit');
end


%% Write file, if applicable
if WriteFile
    if contains(outputfile,filetype) == 1
        outfilename = outputfile;
    else
        outfilename = strcat(outputfile, filetype);
    end
    imwrite(picture, outfilename);
else
    return
end
% end of script
