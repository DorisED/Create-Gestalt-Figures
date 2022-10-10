function [area in] = rapidmakeedge_simple(EDGE)

%Arguements:
%MAKE an EDGE object with the following fields and pass it here

%spriteno       number for this edge
%sourcespr      source sprite (must be the same for all objects you make)
%height             the height of the 'strip'
%width             the width of the edge
%xpos           The x-location of the object, critical for sprite source
%handedness     points to left (-1),points to right (1)
%tp             Number of turning points, 1 = concave/convex
%spiky          Spiky (1) or Smooth (0)
%hw             top-width (0 means it comes back to middle)
%hw             bot-width
if ~isfield(EDGE,'boxes')
    EDGE.boxes = 0;
end

if ~isfield(EDGE,'edgeflag')
    %Flag to detemrine if edges and tops are drawn
    EDGE.edgeflag = [1 1];
end

if ~isfield(EDGE,'straight')
    EDGE.straight = 0;
end

if ~isfield(EDGE,'largemove')
    EDGE.largemove = 0;
end

%Make a simple spline
if EDGE.boxes == 1
    cy = linspace(0,EDGE.height,3);
else
    cy = linspace(0,EDGE.height,EDGE.tp+2);
end
if EDGE.v1shift & EDGE.tp == 2
    if EDGE.convex
        cy(3) = cy(3)-10;
    else
        cy = linspace(0-31,EDGE.height+31,EDGE.tp+2);
        cy(2) = cy(2);
        cy(3) = cy(3)+31;
    end
end

if EDGE.v1shift & EDGE.tp == 5
    cy(4) = cy(4)+20;
    cy(5) = cy(5)+20;
end


cx = [EDGE.sp EDGE.tpc EDGE.sp];


%Smoothnes of edges, higher numbers = more interpolation
if EDGE.straight == 1
    smooth = 5;
else
    smooth = 40;
end
t1 = linspace(0,180,smooth);
t2 = linspace(180,360,smooth);

vexfact = 0.25; %1 = circles, 0 = straight lines
if EDGE.convex
    %Convex shapes
    %fit ellipses to the points
    cxi = [];
    cyi = [];
    for n = 1:(length(cx)-1)
        
        %Fit ellipses
        x1 = cx(n);
        x2 = cx(n+1);
        y1 = cy(n);
        y2 = cy(n+1);
        xo = (x1+x2)./2;
        yo = (y1+y2)./2;
        
        if x1 > x2
            t = t1;
        else
            t = t2;
        end
        
        %Measure angle and distance between co-ords
        phi = atand((y2-y1)./(x2-x1));
        dist = sqrt((x1-xo).^2+(y1-yo).^2);
        a = dist;
        b = a.*vexfact;
        %Make ellispe
        bx = a*cosd(t).*cosd(phi)-b.*sind(t).*sind(phi);
        by = a*cosd(t).*sind(phi)+b.*sind(t).*cosd(phi);
        cxi = [cxi,bx+xo];
        cyi = [cyi,by+yo];
        
    end
    
    %Clean up the 'loops'
    f = logical(zeros(1,length(cxi)));
    for i = 1:length(cxi)
        f(i) = length(find(cyi(i+1:end) < cyi(i)))>0;
    end
    cxi(f) = [];
    cyi(f) = [];
    
else
    %Ambiguous edges, simply interpolate
    if EDGE.spiky == 1
        cxi = cx;
        cyi = cy;
    else
        %%%%%%%%%%%%%%%
        %interpolate
        xi = linspace(1,length(cx),smooth);
        cxi = interp1(1:length(cx),cx,xi,'spline');
        %interpolate
        yi = linspace(1,length(cy),smooth);
        cyi = interp1(1:length(cy),cy,yi,'spline');
        
        if EDGE.straight == 1
            cxis(1:2:smooth*2) = cxi;
            cxis(2:2:smooth*2) = cxi;
            cxis(end) = [];
            cxis(end) = [];
            cyis(1:2:smooth*2) = cyi;
            cyis(2:2:smooth*2) = cyi;
            cyis(1) = [];
            cyis(end) = [];
            cxi = cxis;
            cyi = cyis;
        end
    end
end

%measure distance of every point to halfway up the edge
%And shift so that this distance is the same
hx = EDGE.width;
hy = EDGE.height./2;
dist1 = sqrt((cxi).^2+(cyi-hy).^2);
dist2 = sqrt((cxi-hx).^2+(cyi-hy).^2);
%Shift by half distance
shift = (min(dist2)-min(dist1))/2;

if isfield(EDGE,'displayedge')
    if EDGE.displayedge == 1
         EDGE.measure = 1;
        disp(['Min dist 1 = ',num2str(min(dist1))])
        disp(['Min dist 2 = ',num2str(min(dist2))])
    end
end

%Now move the co-ordinates to the sprite-space
cxi = cxi-EDGE.hw+shift;
cyi = cyi-EDGE.height/2;

%Complete polygon
xcv = [cxi(1),cxi,cxi(end),EDGE.width+100,EDGE.width+100,cxi(1)];
ycv = [(-EDGE.height/2)-100,cyi,(EDGE.height/2)+100,(EDGE.height/2)+100,(-EDGE.height/2)-100,(-EDGE.height/2)-100];

%Make the edge sprite (green)
cgmakesprite(EDGE.sprno,EDGE.width,EDGE.height,[0,1,0])
cgsetsprite(EDGE.sprno)

%texture choice
txtch = EDGE.sourcespr;

%Blit in the texture, this will ultimately end up being the figure
if ~EDGE.largemove
    cgblitsprite(txtch,EDGE.xpos,EDGE.ypos,EDGE.width,EDGE.height,0,0)
else
     %If the sprite will be moved a lot.
    cgblitsprite(txtch,ceil(EDGE.handedness.*(EDGE.width/2)),EDGE.ypos,EDGE.width,EDGE.height,0,0)
end

%Now draw polygon of opposite contour at the appropriate offset
cgpencol(1,0,0);
cgpolygon(xcv.*EDGE.handedness,ycv)
%Make it transparent so that background sprite is visible
cgtrncol(EDGE.sprno,'r')

if EDGE.drawedges
    if EDGE.edgeflag(1)
        cgpencol(EDGE.edgecol(1),EDGE.edgecol(2),EDGE.edgecol(3))
        cgpenwid(EDGE.edgethick)
        cgdraw(xcv(1:(end-1)).*EDGE.handedness,ycv(1:(end-1)),xcv(2:end).*EDGE.handedness,ycv(2:end),repmat(EDGE.edgecol,length(xcv)-1,1))
    end
end

if EDGE.enclosure
    if EDGE.edgeflag(2)
        %Add top and bottom lines
        cgpencol(EDGE.edgecol(1),EDGE.edgecol(2),EDGE.edgecol(3))
        
        [i1,j1]= min(abs(cyi-(-EDGE.height./2)));
        [i2,j2]= min(abs(cyi-(EDGE.height./2)));
        
        %     x1 = cxi(1).*EDGE.handedness+EDGE.handedness;
        %     x2 = cxi(end).*EDGE.handedness+EDGE.handedness;
        x1 = cxi(j1).*EDGE.handedness+EDGE.handedness;
        x2 = cxi(j2).*EDGE.handedness+EDGE.handedness;
        ex = EDGE.hw.*EDGE.handedness.*-1;
        y1 = -EDGE.height/2+(EDGE.encthick/2);
        y2 = EDGE.height/2-(EDGE.encthick/2)+1; %Due to roundign error?
        cgdraw(x1,y1,ex,y1)
        cgdraw(x2,y2,ex,y2)
    end
end

cgsetsprite(0)

if EDGE.measure
    %Measure area of sprite
    [mx,my] = meshgrid((1:EDGE.width)-(EDGE.width/2),(1:EDGE.height)-(EDGE.height/2));
    in = inpolygon(mx,my,xcv,ycv);
    area = (1-sum(sum(in))./(size(in,1).*size(in,2)));%.*(size(in,1).*size(in,2));
    disp(['Area = ',num2str(area)])
    pause
else
    in = NaN;
    area = NaN;
end

return

