// Replacement UISlider to fix the SetStepSize() function from mucking with position,
// and the 1% minimum value.
class MCM_XCOM2_UISlider extends UISlider;

var bool PercentHasBeenSet;

simulated function UISlider SetPercent(float newValue)
{
    if (newValue < 0) newValue = 0;
    else if (newValue > 100) newValue = 100;

    if (percent != newValue || !PercentHasBeenSet)
    {
        PercentHasBeenSet = true;
        percent = newValue;
        mc.FunctionNum("setValue", newValue);
    }
    return self;
}

simulated function UISlider SetStepSize(float newValue)
{
    if (stepSize != newValue)
    {
        stepSize = newValue;
        //mc.FunctionNum("setValue", newValue); // Is there a flash function for setting step size?
    }
    return self;
}