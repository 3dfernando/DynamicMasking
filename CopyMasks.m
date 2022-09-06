function CopyMasks(app, menuNumber)
    %Hit the menu 'copy masks to frame X'
    app.polygonX(:,:,menuNumber)=app.polygonX(:,:,app.CurrentFrame);
    app.polygonY(:,:,menuNumber)=app.polygonY(:,:,app.CurrentFrame);
    msgbox(['Copied masks from frame ' num2str(app.CurrentFrame) ' to frame ' num2str(menuNumber) '.']);
end