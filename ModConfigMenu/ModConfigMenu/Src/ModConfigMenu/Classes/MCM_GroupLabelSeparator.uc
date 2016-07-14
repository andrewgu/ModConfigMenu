// Copy-pasted with slightly different values from MCM_UISettingSeparator.
class MCM_GroupLabelSeparator extends UIImage;

var UIText Title;
var UIScrollingText Description;
var int TITLE_X;
var int TITLE_Y;
var int DESC_X;
var int DESC_Y;

// Main function for initialization.
// @param name InitName : Name of the panel
// @param string Label : Title of the header
// @param string Description : A description to show below (couple lines)
simulated function MCM_GroupLabelSeparator InitSeparator(optional name InitName,optional string Label,optional string HelperText) {
    //local UIList List;     

    InitImage(InitName,"img:///MCM.gfx.GroupLabelSeparator");
    //InitImage(InitName,"img:///MCM.gfx.MainHeaderSeparator");
           
    SetWidth(548);
    SetHeight(38);

    // Get parent width
    //List = UIList(GetParent(class'UIList'));
    //if(List != none && List.Width > 0)
    //    Width = List.Width;     

    Title = Spawn(class'UIText', self).InitText(,Label);
    Title.SetPosition(TITLE_X,TITLE_Y);

    Description = Spawn(class'UIScrollingText', self).InitScrollingText(,HelperText, Width-DESC_X,DESC_X,DESC_Y);        

    return self;
}

// Set the Title (after init.)
// @param string Label : the new title
simulated function UpdateTitle(string Label) {
    Title.SetSubTitle(Label);
}
     
// Set the Description (after init.)
// @param string HelperText : the new description
simulated function UpdateDescription(string HelperText) {
    Description.SetText(HelperText);
}

defaultproperties 
{
    TITLE_X = 0;
    TITLE_Y = 0;
    DESC_X  = 0;
    DESC_Y  = 0;

    bProcessesMouseEvents = true;
}