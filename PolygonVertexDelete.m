function PolygonVertexDelete(app, src)
    %Vertex was deleted from polygon, update in app by deleting all
    %instances of this vertex on all key images

    OldPolyX=interp1(app.polygonKeyImages,app.polygonX(:,:,app.CurrentFrame)',app.CurrentImage);
    OldPolyY=interp1(app.polygonKeyImages,app.polygonY(:,:,app.CurrentFrame)',app.CurrentImage);

    NewPolyX=src.Position(:,1);
    NewPolyY=src.Position(:,2);

    %Finds new point by evaluating every combination of points
    DistArray=zeros(length(OldPolyX),length(NewPolyX));
    for i=1:length(OldPolyX)
        for j=1:length(NewPolyX)
            DistArray(i,j)=norm([OldPolyX(i)-NewPolyX(j), OldPolyY(i)-NewPolyY(j)]);
        end
    end

    MinDist=min(DistArray,[],2); %Finds minimum distance (should be zero if the point was not deleted)
    oldPointIdx=find(MinDist==max(MinDist)); %Finds the old point index to be deleted
    
    %Deletes the point
    app.polygonX(oldPointIdx,:,:)=[];
    app.polygonY(oldPointIdx,:,:)=[];

    %Updates the new polygon on the screen
    app.drawPolygon();
end