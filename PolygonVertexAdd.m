function PolygonVertexAdd(app, src)
    %Vertex was added to polygon, update in app

    if ~any(app.CurrentImage == app.polygonKeyImages)
        %A key image needs to be added and then the polygon needs to be added

        %Repeats the key images with an interpolation at the other frames
        for i=1:app.FrameCount
            Px=interp1(app.polygonKeyImages,app.polygonX(:,:,i)',i);
            Py=interp1(app.polygonKeyImages,app.polygonY(:,:,i)',i);

            nPx(:,1,i)=Px;
            nPy(:,1,i)=Py;
        end

        %Adds polygon to end of list
        app.polygonX(:,end+1,:)=nPx;
        app.polygonY(:,end+1,:)=nPy;
        app.polygonKeyImages(end+1)=app.CurrentImage;
    
        %Reorders image list
        [~,idx]=sort(app.polygonKeyImages,'ascend');
        app.polygonX=app.polygonX(:,idx,:);
        app.polygonY=app.polygonY(:,idx,:);
        app.polygonKeyImages=app.polygonKeyImages(idx);

        idxToChange=idx(end);
    else
        %The key image itself will be updated
        idxToChange=find(app.CurrentImage == app.polygonKeyImages);
    end

    
    OldPolyX=app.polygonX(:,idxToChange,app.CurrentFrame);
    OldPolyY=app.polygonY(:,idxToChange,app.CurrentFrame);

    NewPolyX=src.Position(:,1);
    NewPolyY=src.Position(:,2);

    %Finds new point by evaluating every combination of points
    DistArray=zeros(length(OldPolyX),length(NewPolyX));
    for i=1:length(OldPolyX)
        for j=1:length(NewPolyX)
            DistArray(i,j)=norm([OldPolyX(i)-NewPolyX(j), OldPolyY(i)-NewPolyY(j)]);
        end
    end

    MinDist=min(DistArray,[],1); %Finds minimum distance (should be zero if the point already exists)
    newPointIdx=find(MinDist==max(MinDist)); %Finds the new point index

    %Fractional position where point was added
    if newPointIdx==length(NewPolyX)
        %New vertex created between last vertex and first vertex (loops around)
        fracPosition=(NewPolyX(newPointIdx)-NewPolyX(newPointIdx-1))/(NewPolyX(1)-NewPolyX(newPointIdx-1));
        if isnan(fracPosition)
            %Case the point is in a vertical line
            fracPosition=(NewPolyY(newPointIdx)-NewPolyY(newPointIdx-1))/(NewPolyY(1)-NewPolyY(newPointIdx-1));
        end
    else
        %New vertex created within the normal polygon sequence
        fracPosition=(NewPolyX(newPointIdx)-NewPolyX(newPointIdx-1))/(NewPolyX(newPointIdx+1)-NewPolyX(newPointIdx-1));
        if isnan(fracPosition)
            %Case the point is in a vertical line
            fracPosition=(NewPolyY(newPointIdx)-NewPolyY(newPointIdx-1))/(NewPolyY(newPointIdx+1)-NewPolyY(newPointIdx-1));
        end
    end
    

    %Goes through all entries in app.Polygon and adds a new set of
    %vertices at the partial position defined
    newPolygonX=zeros(size(app.polygonX) + [1 0 0]);
    newPolygonY=zeros(size(app.polygonY) + [1 0 0]); %Adds one column to the new polygon
    for i=1:size(app.polygonX,2)
        for j=1:size(app.polygonX,3)
            x1=app.polygonX(newPointIdx-1,i,j); 
            y1=app.polygonY(newPointIdx-1,i,j); 

            %For x2, detects if wraps around
            if newPointIdx==length(NewPolyX)
                %Wraps around
                x2=app.polygonX(1,i,j);
                y2=app.polygonY(1,i,j);
            else
                %Doesn't wrap around
                x2=app.polygonX(newPointIdx,i,j);
                y2=app.polygonY(newPointIdx,i,j);
            end

            newX=(x2-x1)*fracPosition + x1;
            newY=(y2-y1)*fracPosition + y1;

            newPolygonX(1:newPointIdx-1,i,j)=app.polygonX(1:newPointIdx-1,i,j);
            newPolygonX(newPointIdx,i,j)=newX;

            newPolygonY(1:newPointIdx-1,i,j)=app.polygonY(1:newPointIdx-1,i,j);
            newPolygonY(newPointIdx,i,j)=newY;

            if newPointIdx<length(NewPolyX)
                %Doesn't wrap around
                newPolygonX(newPointIdx+1:end,i,j)=app.polygonX(newPointIdx:end,i,j);
                newPolygonY(newPointIdx+1:end,i,j)=app.polygonY(newPointIdx:end,i,j);
            end
        end
    end


    app.polygonX=newPolygonX;
    app.polygonY=newPolygonY;

    %Updates the new polygon on the screen
    app.drawPolygon();
end