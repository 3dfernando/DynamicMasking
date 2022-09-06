function PolygonMoved(app, src)
    %Polygon vertices were moved, update in app
    
    if ~any(app.CurrentImage == app.polygonKeyImages)
        %A key image needs to be added

        %Repeats the key images with an interpolation at the other frames
        for i=1:app.FrameCount
            Px=interp1(app.polygonKeyImages,app.polygonX(:,:,i)',i);
            Py=interp1(app.polygonKeyImages,app.polygonY(:,:,i)',i);

            NewPolyX(:,1,i)=Px;
            NewPolyY(:,1,i)=Py;
        end

        %Adds polygon to end of list
        app.polygonX(:,end+1,:)=NewPolyX;
        app.polygonY(:,end+1,:)=NewPolyY;
        app.polygonKeyImages(end+1)=app.CurrentImage;

        %The key image itself will be updated
        app.polygonX(:,end,app.CurrentFrame)=src.Position(:,1);
        app.polygonY(:,end,app.CurrentFrame)=src.Position(:,2);
    
        %Reorders image list
        [~,idx]=sort(app.polygonKeyImages,'ascend');
        app.polygonX=app.polygonX(:,idx,:);
        app.polygonY=app.polygonY(:,idx,:);
        app.polygonKeyImages=app.polygonKeyImages(idx);
    else
        %The key image itself will be updated
        idx=find(app.CurrentImage == app.polygonKeyImages);
        app.polygonX(:,idx,app.CurrentFrame)=src.Position(:,1);
        app.polygonY(:,idx,app.CurrentFrame)=src.Position(:,2);
    end

end