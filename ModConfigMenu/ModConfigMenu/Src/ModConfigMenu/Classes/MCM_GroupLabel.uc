// liigiuyg
class MCM_GroupLabel extends Actor;

var string GroupLabel;

//var UIMechaListItem Instance;
//var MCM_UISettingSeparator Instance;
var MCM_GroupLabelSeparator Instance;

simulated function MCM_GroupLabel InitGroupLabel(string Label)
{
    GroupLabel = Label;
    Instance = none;

    return self;
}

simulated function MCM_GroupLabelSeparator InstantiateUI(UIList Parent)
{
    //Instance = Spawn(class'UIMechaListItem', Parent.itemContainer).InitListItem();
    //Instance.UpdateDataDescription(GroupLabel);
    
    Instance = Spawn(class'MCM_GroupLabelSeparator', Parent.itemContainer);
    // Shorten.
    Instance.InitSeparator();
    //Instance.SetHeight(40);
    // Smaller text too.
    Instance.UpdateTitle(GetFormattedLabel());
    Instance.Show();
    Instance.EnableNavigation();

    return Instance;
}

function string GetGroupLabel()
{
    return GroupLabel;
}

function string GetFormattedLabel()
{
    return class'UIUtilities_Text'.static.AddFontInfo(GroupLabel, false);
}

function SetGroupLabel(string Label)
{
    GroupLabel = Label;

    if (Instance != none)
    {
        //Instance.Desc.SetText(Label);
        Instance.UpdateTitle(GetFormattedLabel());
    }
}