function rapidedgeload(EDGE)

global Par

%Thuis program will first blit in the background texture into the mastersprite.
%It then repeatedly calls rapidmakeedge_noshad to make a series
%of sprites (all called sprite 100).  Each sprites corresponds to one half of an object.  This are
%then drawn togteher into the mastersprite (EDGE.maskspr).

%EDGES
%MAKE an EDGE object with the following fields
%spriteno       number for this edge
%sourcespr      source sprite (must be the same for all objects you make)
%height             the EDGE.height of the 'strip'
%width             the EDGE.width of the edge
%xpos           The x-location of the object, critical for sprite source
%handedness     points to left (-1),points to right (1)
%tp             Number of turning points, 1 = concave/convex
%tpc            (OPTIONAL) - actual tp co-ordinates, other alternates
%               full-EDGE.width, half-EDGE.width
%spiky          (OPTIONAL) Spiky (1) or Smooth (0 = default)
%hw             (OPTIONAL) top-EDGE.width (default 0)
%hw             (OPTIONAL) bot-EDGE.width (default 0)

if ~isfield(EDGE,'boxes')
    EDGE.boxes = 0;
end

if ~isfield(EDGE,'variedge')
    EDGE.variedge = 0;
end

if ~isfield(EDGE,'drawback')
    EDGE.drawback = 1;
end

if ~isfield(EDGE,'aap')
    EDGE.aap = 0;
end

%Choose a background texture for this trial
backspr = EDGE.backspr;

%Figure texture should be opposite to this
figspr = EDGE.figspr;

%MATRIX OF TURNING POINTS
WR = EDGE.width./100;
if ~EDGE.convex
    
    if EDGE.boxes
        %sp is the starting point of the x co-ordinates
        EDGE.sp = 50.*WR;
        for k = 1:6
            TP(k).tp = 50.*WR;
        end
    else
        EDGE.sp = 55.*WR;
        high = 60;
        low = 40;
        if EDGE.v1shift
            TP(2).tp = round([high low+5].*WR);
        else
            TP(2).tp = round([low high].*WR);
        end
        TP(3).tp = round([high-10 low high-10].*WR);
        TP(4).tp = round([high low high low].*WR); %double vase
        TP(5).tp = round([high low high low high].*WR);
        TP(6).tp = round([high low high low high low].*WR);
        
        
    end
else
    %For the convex shapes we need slightly different turning poitns to
    %ensure 50% areas...
    EDGE.sp = 40.*WR;
    high = 50;
    low = 33;
    if EDGE.v1shift
        TP(2).tp = round([high low].*WR);
    else
        TP(2).tp = round([low high].*WR);
    end
    TP(3).tp = round([high-10 low high-10].*WR);
    TP(4).tp = round([high low high low].*WR); %double vase
    TP(5).tp = round([high low high low high].*WR);
    TP(6).tp = round([high low high low high low].*WR);
end

%Turning points for each object
%Object on teh rows, handedness on the colums (i.e two columns)
%Should be at least as many objects as positions
tpind = repmat([2,4,5,6]',20,1); %symmetric
if EDGE.symmetry
    %If symmetrical the two hands of the object have the same edge
    tpind(:,2) = tpind(:,1);
else
    %otherwise they have different edges
    %Ensure no symmetrical backgorunds!
    %E.g. (2,5),(4,6),(5,2),(6,4)
    lookup = [NaN,5,NaN,6,2,4];
    tpind(:,2) = lookup(tpind(:,1));
end


%Blit in background
cgsetsprite(EDGE.maskspr)
if EDGE.drawback == 1
    cgblitsprite(backspr,0,EDGE.ypos,1048,EDGE.height,0,0)
else
    cgrect(0,0,2048,768,[0,0,1])
end
cgsetsprite(0)

if EDGE.edges
    %Make first the base sprite then the target sprite
    EDGE.sprno = 100;
    
    %Now make edges and blit them in
    area = zeros(1,length(EDGE.xpos_c));
    for o = 1:length(EDGE.xpos_c)
        %Only if part of shape falls on screen
        %bare in mind that texture has only 100pixel leeway so if EDGE.width > 100
        %might need to change texture in lumtext
%         if (EDGE.xpos_c(o)+EDGE.shift > -512-EDGE.width) & (EDGE.xpos_c(o)+EDGE.shift < 512+EDGE.width)
            
            EDGE.sourcespr = figspr;
            
            %Make the right-hand then the left-hand edge
            for h = 1:2
                
                %get turning points
                tp = tpind(o,h);
                
                %Handedness of edge
                hnd = (h-1).*2-1;
               
                %Not uised
                if EDGE.variedge
                    if EDGE.aap == 2
                        %Duvel
                        if h == 1
                            EDGE.spiky = 1;
                        else
                            EDGE.spiky = 0;
                        end
                    elseif EDGE.aap == 1
                        %bobo
                        if h == 1
                            EDGE.spiky = 0;
                        else
                            EDGE.spiky = 1;
                        end
                    else
                        disp('EDGE aap doesnt exist!')
                        return

                    end
                else
                    EDGE.spiky = 0;
                end
                
                if h == 1
                    EDGE.xpos = EDGE.xpos_l(o)+EDGE.shift;
                elseif h == 2
                    EDGE.xpos = EDGE.xpos_r(o)+EDGE.shift;
                end
                EDGE.handedness = hnd;
                
                %shape variables
                EDGE.tp = tp; %No of turning points
                EDGE.tpc = TP(tp).tp; %Turning point co-orrdsjpos
                
                %Make edge - could make this more rapid
                [area(o) in] = rapidmakeedge_simple(EDGE);
                
                %Now draw into the maskspr sprite
                cgsetsprite(EDGE.maskspr)
                
                %And blit it
                cgdrawsprite(EDGE.sprno,EDGE.xpos,0)
            end
%         end
    end
    
    EDGE.area = area;
    cgsetsprite(0)
end

% toc
return