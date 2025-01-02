function Maze_Wandering
    clear,clc,close all;
    m=200;
    view_range_ini = 100;
    view_range = view_range_ini;
    
    %% Maze
    % Maze parameter
    passageWidth  = 8;
    wallThickness = 5;
    sz_map = [20 10];

    % create maze
    map = mapMaze(passageWidth,wallThickness,'MapSize',sz_map,'MapResolution',5);
    mapData = occupancyMatrix(map);

    % create goal
    sz = size(mapData);
    [rr,cc]=find(mapData==false);
    p_end = max([rr,cc]);
    c_e = p_end(2)-passageWidth+1:p_end(2);
    r_e = p_end(1):sz(1);
    mapData(r_e,c_e) = false;

    % extract boundaries (maze wall)
    [B_e, L_e] = bwboundaries(mapData, 'noholes','TraceStyle',"pixeledge");
    idx_1 = [diff(L_e,1,1); zeros(1,size(L_e,2))] == 1;
    idx_2 = [diff(L_e,1,2), zeros(size(L_e,1),1)] == 1;
    L_e(idx_1) = 1;
    L_e(idx_2) = 1;

    Bm_e = floor(cell2mat(B_e)); % Data type conversion

    % Set goal line
    Goalx = [p_end(1), sz(1), sz(1), p_end(1)];
    Goaly = [c_e(1)-1, c_e(1)-1, c_e(end), c_e(end)];
    L_e(r_e,c_e) = 2;

    pos_wall = Bm_e;

    %% Player
    % Initial position
    player.pos      = min([rr,cc]);

    % Player's eye
    player.angle    = 90;
    Angle           = 60;
    dAngle          = 5;
    n               = 51;

    % Player's view range
    th = deg2rad(linspace(player.angle - Angle,player.angle + Angle,n))';
    r = 15;
    v = r.*[cos(th),sin(th)];
    p2 = v + player.pos;

    %% Ray Casting
    % Hitbox --> refer to polyxpoly
    x = reshape(([repelem(player.pos(1),height(p2))',p2(:,1),nan(height(p2),1) ])',[],1);
    y = reshape(([repelem(player.pos(2),height(p2))',p2(:,2),nan(height(p2),1) ])',[],1);
    [xi,yi,kk] = polyxpoly(x,y,pos_wall(:,1),pos_wall(:,2));

    % Wall
    % The player extends segments by the number specified in the variable n.
    % By intersecting these segments with walls, it simulates walls from an FPS perspective.
    % Wallx places n bars, and Wally adjusts their height based on the distance to the walls.
    Wallx = (1:height(p2))';

    % The variable dummy represents the first intersection ID for each segment.
    % Without this, the player would detect the farther intersection when a segment has two intersection points.
    dummy   = Wallx.*(4-1) + 1;
    dummy   = [1 ; dummy(1:end-1)];
    Wally   = nan(height(p2),1);

    % The variable th2 is used to correct the distortion in ray casting.
    % The actual distance between the player and the wall is calculated by multiplying the distance to the intersection on the arc by the cosine of th2.
    th2     = -deg2rad(linspace(-Angle,Angle,n))';

    % The variable K serves as a gain that determines the height limit of the viewpoint.
    % It acts as an adjustable parameter.
    K = 3;

    %% Visualize
    %% Part 1: Bird's-eye view
    f = figure('Color','#AAAAAA','Position', [100, 250, 700, 600]);
    ax = axes('Color','#AAAAAA');
    hold on
    % set(ax, 'YDir', 'reverse')
    fill(ax,pos_wall(:,1),pos_wall(:,2),'k',LineStyle='none');
    fill(ax,Goalx,Goaly,'yellow',LineStyle='none')
    axis equal
    xlim(ax,[player.pos(1)-view_range/2,player.pos(1)+view_range/2])
    ylim(ax,[player.pos(2)-view_range/2,player.pos(2)+view_range/2])

    txt = {'Rotation',' e: Clockwise', ' r: Counterclock','',...
        'Zoom',' w: ZoomIn',' q: ZoomOut','',...
        'View range', ' v: CloseUp', ' c: CloseDown','',...
        'Reset',' t: Direction', ' z: Zoom', ' x: View'};
    annotation('textbox', [0.01, 0.01, 0.15, 0.4], 'String', txt, 'FontSize', 10, 'EdgeColor', 'white')

    % Player_1. Player Position
    pl = plot(ax,player.pos(1), player.pos(2),'o', ...
        MarkerFaceColor='y',MarkerEdgeColor='none',...
        MarkerSize=5);

    % Player_2-1. Ray Casting Arc
    pl1 = plot(ax,p2(:,1),p2(:,2),'LineStyle','-', ...
        'LineWidth',1,'Color','y');

    % Player_2-2. Ray Casting Line segment
    for ii = 1:height(p2)
        pl2(ii) = plot(ax,[player.pos(1);p2(ii,1)],...
            [player.pos(2); p2(ii,2)],'LineStyle','--', ...
            'LineWidth',1,'Color','y');
    end
    tmp1 = [xi;nan(height(p2)-length(xi),1)]';
    tmp2 = [yi;nan(height(p2)-length(yi),1)]';

    % Player_3. Intersection point
    pl3 =  plot(ax,tmp1,tmp2,'o', ...
        LineStyle='none', ...
        MarkerFaceColor='r',MarkerEdgeColor='none',...
        MarkerSize=5);
        ax_FPS.XTick = [];

        ax.XTick = [];
        ax.YTick = [];
        ax.XAxis.Color = 'none';
        ax.YAxis.Color = 'none';
    hold off

    %% Part 2: FPS view
    f_FPS   = figure('Color','#AAAAAA','Position', [800, 250, 700, 600]);
    ax_FPS  = axes('Color','#AAAAAA');
    hold on
    pl_FPS_p  = stem(ax_FPS,-Wallx,Wally./2,'Marker','none','LineWidth',round(m/n),'Color','w');
    pl_FPS_n  = stem(ax_FPS,-Wallx,-Wally./2,'Marker','none','LineWidth',round(m/n),'Color','w');
    ax_FPS.XLim = [-(height(Wallx)+1) 0];

    % Vertical field of view
    ax_FPS.YLim = [-1 1].*K*2;

    % Remove unnecessary parts
    ax_FPS.XTick = [];
    ax_FPS.YTick = [];
    ax_FPS.XAxis.Color = 'none';
    ax_FPS.YAxis.Color = 'none';

    % text
    txt = {'Rotation',' e: Clock', ' r: Counter','',...
        'Zoom',' w: ZoomIn',' q: ZoomOut','',...
        'View range', ' v: Up', ' c: Down','',...
        'Reset',' t: Direction', ' z: Zoom', ' x: View'};
    annotation('textbox', [0.01, 0.01, 0.12, 0.4], 'String', txt, 'FontSize', 10, 'EdgeColor', 'white')

    hold off

    %% Actions
    figure(f);
    r_theta  = 0;
    move_pos = [0, 0]';


    switch_trigger = 1;
    movepoint;
    switch_trigger = 0;


    f.WindowButtonDownFcn   = @motion;
    f.WindowButtonUpFcn     = @motion;
    f.KeyPressFcn           = @player_action;

    %% Nested functions
    dt = 0.05;
    %% Actions
    function player_action(src,data,eventdata)
        switch data.Key
            % Rotation
            case 'e'
                switch_trigger = 1;
                for ii = 1:90/dAngle
                    th = th + deg2rad(dAngle);
                    v = r*[cos(th),sin(th)];                    
                    if ii == 90/dAngle
                        r_theta = mod(r_theta + 90, 360);
                    end
                    movepoint
                    pause(dt)
                end
                switch_trigger = 0;

            case 'r'
                switch_trigger = 1;
                for ii = 1:90/dAngle
                    th = th - deg2rad(dAngle);
                    v = r*[cos(th),sin(th)];
                    if ii == 90/dAngle
                        r_theta = mod(r_theta - 90, 360);
                    end
                    movepoint
                    pause(dt)
                end
                switch_trigger = 0;
            case 't' % reset
                switch_trigger = 1;
                th = deg2rad(linspace(player.angle - Angle,player.angle + Angle,n))';
                v = r*[cos(th),sin(th)];
                r_theta = 0;
                movepoint
                switch_trigger = 0;

            % Zoom
            case 'w'
                switch_trigger = 1;
                r = r + 1;
                v = r*[cos(th),sin(th)];
                movepoint;
                switch_trigger = 0;
            case 'q'
                switch_trigger = 1;
                r = r - 1;
                if r < 2
                    r = 2;
                end
                v = r*[cos(th),sin(th)];
                movepoint;
                switch_trigger = 0;
            case 'z'% reset
                switch_trigger = 1;
                r = 15;
                v = r*[cos(th),sin(th)];
                movepoint;
                switch_trigger = 0;

            % View Range
            case 'v'
                switch_trigger = 1;
                view_range = view_range - 5;
                movepoint;
                switch_trigger = 0;
            case 'c'
                switch_trigger = 1;
                view_range = view_range + 5;
                movepoint;
                switch_trigger = 0;
            case 'x' % reset
                switch_trigger = 1;
                view_range = view_range_ini;
                movepoint;
                switch_trigger = 0;

            % Movement
            case 'uparrow'
                move_pos = [ 0, 1]';
                v = r*[cos(th),sin(th)];
                movepoint;
            case 'downarrow'
                move_pos = [ 0,-1]';
                v = r*[cos(th),sin(th)];
                movepoint;
            case 'leftarrow'
                move_pos = [-1, 0]';
                v = r*[cos(th),sin(th)];
                movepoint;
            case 'rightarrow'
                move_pos = [ 1, 0]';
                v = r*[cos(th),sin(th)];
                movepoint;
        end
        
    end
    %% Action when the button is pressed
    function motion(src,data,eventdata)        
        if strcmp(data.EventName,'WindowMousePress')
            f.WindowButtonMotionFcn = @movepoint2;
        else
            xlim(ax,[player.pos(1)-view_range/2,player.pos(1)+view_range/2])
            ylim(ax,[player.pos(2)-view_range/2,player.pos(2)+view_range/2])
            f.WindowButtonMotionFcn = '';
        end
    end

    %% Movepoint
    function movepoint(src,data)
        switch switch_trigger
            case 0
                so = so2(deg2rad(r_theta),'theta');
                move_pos = so.rotm*move_pos;
                temp_x = player.pos(1) + move_pos(1);
                temp_y = player.pos(2) + move_pos(2);
            case 1
                temp_x = player.pos(1);
                temp_y = player.pos(2);
            case 2
                pos = get(gca,'CurrentPoint');
                temp_x = pos(1,1);
                temp_y = pos(1,2);
        end
        
        if L_e(temp_x, temp_y) == 0
            pl.XData = temp_x;
            pl.YData = temp_y;
        elseif L_e(temp_x, temp_y) == 2
            h = msgbox("Goal!");
            xlim(ax,'auto')
            ylim(ax,'auto')
            waitfor(h, 'Visible', 'off');
            close all
            return
        else
            pl.XData = player.pos(1);
            pl.YData = player.pos(2);
        end


        pl1.XData       = v(:,1) + pl.XData;
        pl1.YData       = v(:,2) + pl.YData;

        player.pos      = [pl.XData, pl.YData];
        p2              = [pl1.XData; pl1.YData]';
        Cross;

        for ii = 1:length(pl2)
            pl2(ii).XData   = [0, v(ii,1)] + pl.XData;
            pl2(ii).YData   = [0, v(ii,2)] + pl.YData;
        end
    end


    function movepoint2(src,data)
        pos = get(gca,'CurrentPoint');
        temp_x = floor(pos(1,1));
        temp_y = floor(pos(1,2));

        if temp_x < 1 || temp_x > size(L_e,1) || temp_y < 1 || temp_y > size(L_e,2)
            temp_x = min(rr);
            temp_y = min(cc);
        end

        if L_e(temp_x, temp_y) == 0
            pl.XData = temp_x;
            pl.YData = temp_y;
        elseif L_e(temp_x, temp_y) == 2
            h = msgbox("Goal!");
            xlim(ax,'auto')
            ylim(ax,'auto')
            waitfor(h, 'Visible', 'off');
            close all
            return
        else
            pl.XData = player.pos(1);
            pl.YData = player.pos(2);
        end

        pl1.XData       = v(:,1) + pl.XData;
        pl1.YData       = v(:,2) + pl.YData;

        player.pos      = [pl.XData, pl.YData];
        p2              = [pl1.XData; pl1.YData]';
        Cross;

        for ii = 1:length(pl2)
            pl2(ii).XData   = [0, v(ii,1)] + pl.XData;
            pl2(ii).YData   = [0, v(ii,2)] + pl.YData;
        end
    end
    %% Collision detection
    function Cross
        x = reshape(([repelem(player.pos(1),height(p2))',p2(:,1),nan(height(p2),1) ])',[],1);
        y = reshape(([repelem(player.pos(2),height(p2))',p2(:,2),nan(height(p2),1) ])',[],1);
        [xi,yi,kk] = polyxpoly(x,y,pos_wall(:,1),pos_wall(:,2));

        % Vector notation between points and intersection
        tmp = [xi,yi] - player.pos;

        % Determine correspondence with the contact line using polyxpoly
        tmp = [xi, yi, (tmp(:,1).^2+tmp(:,2).^2), kk(:,1), false(length(xi),1)];
        t1 = unique(tmp(:,4));
        for jj = 1:length(t1)
            % Extract the closest points for each intersection on the same contact line
            MIN_tmp  = min(tmp(tmp(:,4) == t1(jj),3));
            tmp( (tmp(:,4)==t1(jj)) & (tmp(:,3)==MIN_tmp) ,end) = true;
        end

        % Obtain the FPS y-information
        idx = tmp(:,end)==true;

        % Extract the xi, yi information
        tmp = tmp(idx,[1:4]);
        [~,I] = sort(tmp(:,4));

        tmp = tmp(I,:);
        xi = tmp(:,1);
        yi = tmp(:,2);

        idx2 = ismember(dummy,tmp(:,4));

        Wallx = (1:height(p2))';
        Wally = nan(height(p2),1);
        Wally(find(idx2)) = sqrt(tmp(:,3)./r.^2); % Normalization of length
        Wally = Wally.*cos(th2);

        pl_FPS_p.YData = K./Wally./2;
        pl_FPS_n.YData = -K./Wally./2;

        pl3.XData = [xi;nan(height(p2)-length(xi),1)]';
        pl3.YData = [yi;nan(height(p2)-length(yi),1)]';
        xlim(ax,[player.pos(1)-view_range/2,player.pos(1)+view_range/2])
        ylim(ax,[player.pos(2)-view_range/2,player.pos(2)+view_range/2])
    end

end
