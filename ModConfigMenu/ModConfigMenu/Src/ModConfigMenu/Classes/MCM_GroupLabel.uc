// liigiuyg
class MCM_GroupLabel extends Actor;

var string GroupLabel;

var UIMechaListItem Instance;

simulated function MCM_GroupLabel InitGroupLabel(string Label)
{
    GroupLabel = Label;
    Instance = none;

    return self;
}

simulated function UIMechaListItem InstantiateUI(UIList Parent)
{
    Instance = Spawn(class'UIMechaListItem', Parent.itemContainer).InitListItem();
    Instance.UpdateDataDescription(GroupLabel);

    return Instance;
}

function string GetGroupLabel()
{
    return GroupLabel;
}

function SetGroupLabel(string Label)
{
    GroupLabel = Label;

    if (Instance != none)
    {
        Instance.Desc.SetText(Label);
    }
}