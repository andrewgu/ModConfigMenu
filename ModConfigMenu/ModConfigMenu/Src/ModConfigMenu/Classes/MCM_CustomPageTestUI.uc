class MCM_CustomPageTestUI extends UIScreen;

var UIPanel Container;
var UIImage BG;
var UIButton SaveAndExitButton;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
    `log("MCM Custom page initialized.");

    super.InitScreen(InitController, InitMovie, InitName);

    Container = Spawn(class'UIPanel', self).InitPanel('').SetPosition(100, 100).SetSize(800, 800);
    BG = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainBackground");

    // Save and exit button    
    SaveAndExitButton = Spawn(class'UIButton', Container);
    SaveAndExitButton.InitButton(, "Exit", OnSaveAndExit);
    SaveAndExitButton.SetPosition(Container.width - 190, Container.height - 40); //Relative to this screen panel
}

simulated function InitUI()
{
}

simulated function OnSaveAndExit(UIButton kButton)
{
    Movie.Stack.Pop(self);
}
