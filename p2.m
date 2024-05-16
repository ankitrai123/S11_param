clc
clear
m = 4; % Number of rows
n = 4; % Number of columns
j = 1;
points=linspace(100,200,101);
data_set = zeros(1, m*n + 2); % Preallocate data_set
config=1;
len=size(points);
r = readmatrix('4by4_filtered_matrices.csv');
r=[0,0,0,0,0,0,1,0,1,0,1,1,1,1,1,0];
%r=randi([0,1],1,16);
%for config = 1:100
while config < 2
  %  r=randi([0,1],1,16);
    %rmat = r(config,:);
    rmat = r;
    mat = reshape(rmat, m, n);
    mat(1, 2) = 1;
    mat(1, 5) = 1;
    mat(1, 9) = 1;
    mat(4, 4) = 1;
    for freqx=1:len(2)
        try
            objt = generateantenna(m, n, mat);
            s = sparameters(objt, points(freqx)*1e8);
            % meshconfig(objt, 'manual');
            %ff = mesh(objt, "MaxEdgeLength", 0.000014);
            data_set(j, 1:end-2) = rmat;
            data_set(j, end-1) = points(freqx)*1e8;
             
            s11p=rfplot(s, 1, 1).YData;
            data_set(j, end)=s11p;
            
        catch
            disp(['Coarse mesh encountered for configuration ', num2str(config), ' at frequency ', num2str(freqx*1e8)]);
            break; % Skip to the next configuration
        end
       % disp(j)
        j = j + 1;
    end
    config=config+2;
    disp(config)
end

%writematrix(data_set, "config_1_to_500.csv");




function p = generateantenna(x_dis, y_dis, ant_des)


    
    L = (2*4e-3); % x axis 
    W = (2*4e-3); % y axis
            nx = x_dis; %cells along x = nx-1,Number of columns of Exc matrix
            ny = y_dis; %cells along y = ny-1 %Number of rows in Exc Matrix
            gndLength = 2*L;
            gndWidth = 2*W;  %pcbTraceWidth = 0.662e-3; % for 0.305 ro4003
            pcbTraceWidth = ((2*0.988e-3));
            pcbTraceLength = 0.5*(gndLength - L);
            x = linspace(-L/2,L/2,nx); %bottom left coordinates of each cell
            y = linspace(-W/2,W/2,ny); %bottom left coordinates of each cell
            dx = x(2) - x(1); px = 1.0*dx ;% 5% bigger in size(for fabrication purpose)
            dy = y(2) - y(1); py = 1.0*dy;
            
            feed = antenna.Rectangle('Length',2e-3,'Width',pcbTraceWidth,'Center',[-L/2-1e-3,0]);
    
            Exc = ant_des;  





for i = 1:nx
    for j = 1:ny
       unitpatch{i,j} = antenna.Rectangle('Length',dx,'width',...
                dy,'Center',[x(i)+dx/2,y(j)+dy/2]);        
    end
end
cboard=feed;
for m = 1:nx
    for n = 1:ny
        if Exc(m,n) ==1           
       cboard=cboard+unitpatch{m,n};
    end
end

        
   
    end
    % the feedsection
      cfed = cboard+feed;
      thick = 6e-4; %thickness
        p = pcbStack;
  %d = dielectric('Name','FR4','EpsilonR',1,'LossTangent',0);
   d=dielectric('air');
  % d.LossTangent =0;
   %d.EpsilonR=1;
   d.Thickness=thick;
        gnd = antenna.Rectangle('Length',gndLength,'Width',gndWidth);
        gndPlane = gnd;
        p.BoardShape = gnd;
        p.BoardThickness = thick;
        p.FeedViaModel='strip';
        p.Layers = {cfed,d,gnd};
        p.FeedLocations = [-L/2-1e-3,0,1,3];
        p.FeedDiameter = pcbTraceWidth/2-0.2e-3;
        p.Conductor = metal('copper');
        p.Conductor.Thickness = 35e-6;
        p.FeedVoltage = 1.0;
        p.FeedPhase = 0.0;  
end