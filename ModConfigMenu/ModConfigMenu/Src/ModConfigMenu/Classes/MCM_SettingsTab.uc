class MCM_SettingsTab extends UIMechaListItem;

var int SettingsPageID;
var delegate<ClickHandler> OnClickHandler;
var delegate<CustomSettingsPageCallback> CustomPageCallback;

delegate ClickHandler(MCM_SettingsTab Caller, int PageID);
delegate CustomSettingsPageCallback(UIScreen ParentScreen, int PageID);

function MCM_SettingsTab InitSettingsTab(int PageID, string Label)
{
    super.InitListItem();

    SettingsPageID = PageID;
    OnClickHandler = none;
    CustomPageCallback = none;

    UpdateDataCheckbox(Label, "", false, CheckboxChangedCallback, CheckboxClickedCallback);

    return self;
}

function CheckboxChangedCallback(UICheckbox CheckboxControl)
{
    if (OnClickHandler != none)
    {
        OnClickHandler(self, SettingsPageID);
    }

    if (CustomPageCallback == none)
    {
        // One does not uncheck by clicking. Doesn't work that way.
        SetChecked(true);
    }
    else
    {
        SetChecked(false);
    }
}

function CheckboxClickedCallback()
{
    if (CustomPageCallback == none)
    {
        // One does not uncheck by clicking. Doesn't work that way.
        SetChecked(true);
    }
    else
    {
        SetChecked(false);
    }

    if (OnClickHandler != none)
    {
        OnClickHandler(self, SettingsPageID);
    }
}

function SetChecked(bool Checked)
{
    // Don't need to generate change event since we care about the click.
    Checkbox.SetChecked(Checked, false);
}