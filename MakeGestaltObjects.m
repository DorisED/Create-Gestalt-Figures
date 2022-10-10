%% Make Gestalt figures and masks objects, in both contrasts
clear all

% Set directories
addpath(genpath('M:\MatlabFiles\CogGphTB\'))
addpath(genpath('C:\Users\dijksterhuis\Dropbox\NIN PhD\HumanPatExps\2021_BO_study_paper\BO_Paper\Data_&_Scripts\Experiment2\'))


%% Open cogent
% We draw the objects in Cogent, so we need to open the program.
cgloadlib
cgopen(3,0,0,0)
cogstd('sPriority','high')

%% Create variables
%Colors
minlum      = gammacon(0,'rgb2lum');
maxlum      = gammacon(1,'rgb2lum');
halflum     = (maxlum-minlum)./2;
greylum     = minlum+halflum;
grey        = gammacon(greylum,'lum2rgb');

%% We create a struct variable called 'Par', where we save parameters that
% are specific to the screen that you are using.
Par.grey    = grey;
Par.greylum = greylum;
%Half-widths
Par.Screenx     = 512;
Par.Screeny     = 384;
Par.vd          = 35;
Par.screenwidth = 40/2;
Par.PixPerDeg   = 1/(atand(Par.screenwidth./Par.vd)./Par.Screenx);

%% We create a struct varibel called 'EDGE' that is used later to create the
% parameters to create the gestalt objects
%Make co-ordinates for xpos of figures
EDGE.width  = round(Par.PixPerDeg.*4); %Width of an edge sprite
EDGE.height = round(Par.PixPerDeg.*7); %260; %Heigth of an edge sprite
EDGE.hw     = EDGE.width./2;

%Make xpos_C so it is forced to go through (0,0), then shift sppropriately
xpos_c      = 0:EDGE.width*2:2048;
EDGE.xpos_c = [fliplr(-xpos_c),xpos_c(2:end)];
EDGE.xpos_l = EDGE.xpos_c-(EDGE.width/2); %Left edge of object
EDGE.xpos_r = EDGE.xpos_c+(EDGE.width/2); %Right-edge

EDGE.drawedges  = 0;
EDGE.edgecol    = [0 0 0];
EDGE.edgethick  = 3;
EDGE.encthick   = 4;

%Measure the egde or not?
EDGE.measure    = 0;

%Main strip sprite
cgmakesprite(201,1024,EDGE.height,[1,0,0])
%Color sprites, could be textured...
blackspr = 1;
whitespr = 2;
cgmakesprite(1,1024,EDGE.height,[0,0,0])
cgmakesprite(2,1024,EDGE.height,[1,1,1])

Cx = 0;
Cy = 0;

EDGE.shift      = Cx+EDGE.width.*1; %odd numbers will give grounds in the middle, even will fgive figures.
EDGE.v1shift    = 0;
EDGE.edges      = 1;
EDGE.commonfate = 0;
EDGE.enclosure  = 0;
EDGE.convex     = 1;
EDGE.symmetry   = 1;
EDGE.occluder   = 0;
EDGE.ypos       = Cy;
EDGE.masterspr  = 201;

%% Make 2x7 sprites: There are 7 masks
%Sprite 201-208 = white figures, black background
%Sprite 209-215 = black figures, white background
clear EDGE.masterspr
EDGE.masterspr = 200;
for c = 1:2 %black/white
    for d = 1:8 %amount of masks
        EDGE.masterspr = EDGE.masterspr+1;
        cgmakesprite(EDGE.masterspr,1024,EDGE.height,[1,0,0])
        EDGE.shift = Cx+EDGE.width.*d;
        if c == 1
            EDGE.figspr = 2;
            EDGE.backspr = 1;
        else
            EDGE.figspr = 1;
            EDGE.backspr = 2;
        end
        % rapideedgeload_simple is a function that creates the objects and
        % immediately makes a sprite of each mask
        rapidedgeload_simple(EDGE);
    end
end

%% Variables
EDGE.masterspr = [201:216];
objectxpos = [14 15 16];  %xpos

%Locations
y = 0;
x = 0;

%% Start drawing
% We loop through all the masks that exist, which are 14. 
% We create the targets by drawing black or white bars over the mask, so
% that 1 gestalt object is visible.
color = 1;
xpos = 15;

% cgscrdmp saves all the target and masks in a folder.
mkdir ScreenDump

cgflip(grey,grey,grey)
for n = 1:size(EDGE.masterspr,2)

    masterspr = EDGE.masterspr(n)
    % Draw mask
    if masterspr >= 210
        maskspr = masterspr - 7;
    else
        maskspr =  masterspr + 7;
    end
    cgdrawsprite(maskspr,x,y)
    cgflip(grey,grey,grey)
    cgscrdmp
    pause
    
end
cgshut