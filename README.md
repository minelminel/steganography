# steganography
Collection of functions for hiding and extracting text from black and white images

stegwrite

syntax:   picture = stegwrite(message, skip, outputfile, inputfile)

wizard:   YES; access by calling function with no input arguments

help:     help stegwrite

abstract: conceal a text message within a 2-D image array of type UINT8
  
inputs: message, skip, outputfile, inputfile
    
message--either a string or .txt file
      
skip--interval between overwritten array elements
      
outputfile--name of file to be created after function executes
      
inputfile--name of file to be used as background
      
output: picture [uint8 array]
    
user-editable segments within function:
    line 28--filetype (default .png)
      type of file to be written, if specified
    line 30--DisplayImage (default TRUE)
      set to FALSE to bypass image displaying
    line 120--maximum allowable image dimension
      integer value can be adjusted based on available CPU.
      if the image is larger than specified value, a prompt is displayed asking for confirmation
    line 132:134--default background image (default NOISE)
      uncomment 1 of the 3 lines to designate which background type is desired.
      options are NOISE, WHITE, BLACK




