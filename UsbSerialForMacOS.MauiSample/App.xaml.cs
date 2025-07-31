namespace UsbSerialForMacOS.MauiSample;

public partial class App : Application
{
	public App()
	{
		InitializeComponent();

		MainPage = new AppShell();
	}

    protected override Window CreateWindow(IActivationState? activationState)
    {
        var window = base.CreateWindow(activationState);

        const int newWidth = 300;
        const int newHeight = 600;

        window.Width = newWidth;
        window.Height = newHeight;
        window.MinimumWidth = newWidth;
        window.MinimumHeight = newHeight;
        window.MaximumWidth = newHeight;
        window.MaximumHeight = newHeight;
        // Get display size
        var displayInfo = DeviceDisplay.Current.MainDisplayInfo;

        // Center the window
        window.X = (displayInfo.Width / displayInfo.Density - window.Width) / 2;
        window.Y = (displayInfo.Height / displayInfo.Density - window.Height) / 2;
        return window;
    }
}
