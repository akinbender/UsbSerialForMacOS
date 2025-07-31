using Foundation;

namespace UsbSerialForMacOS.MauiSample;

public partial class MainPage : ContentPage
{
    private UsbSerialManager _serialManager;
    private bool _isConnected = false;
    private List<string> _availablePorts = new();

    public MainPage()
    {
        InitializeComponent();
        _serialManager = new UsbSerialManager();
        LoadSerialPorts();
        terminalOutput.Text = "> Ready\n";
    }

    private void LoadSerialPorts()
    {
        _availablePorts = _serialManager.AvailablePorts().ToList();
        portPicker.ItemsSource = _availablePorts;
        portPicker.SelectedIndex = _availablePorts.Count > 0 ? 0 : -1;
    }

    private void SetConnectionState()
    {
        connectButton.IsEnabled = !_isConnected;
        disconnectButton.IsEnabled = _isConnected;
        sendButton.IsEnabled = _isConnected;
    }

    private void OnRefreshPortsClicked(object sender, EventArgs e)
    {
        LoadSerialPorts();
        AppendTerminalText("> Ports refreshed\n");
    }

    private async void OnConnectClicked(object sender, EventArgs e)
    {
        if (portPicker.SelectedItem == null)
        {
            await DisplayAlert("Error", "Select a serial port first", "OK");
            return;
        }

        var portPath = portPicker.SelectedItem?.ToString() ?? string.Empty;
        var baudRate = int.TryParse(baudPicker.SelectedItem?.ToString(), out var br) ? br : 9600;
        AppendTerminalText($"> Attempting to connect to {portPath} @ {baudRate} baud\n");
        var result = _serialManager.OpenDebug(portPath, baudRate);
        _isConnected = result.Contains("success");
        AppendTerminalText(result);
        SetConnectionState();

        if (_isConnected)
        {
            AppendTerminalText($"> Connected to {portPath} @ {baudRate} baud\n");

            // Start reading thread
            this.Dispatcher.StartTimer(TimeSpan.FromMilliseconds(100), () =>
            {
                ReadSerialData();
                return _isConnected;
            });
        }
        else
        {
            await DisplayAlert("Connection Failed", "Could not open serial port", "OK");
        }
    }

    private void OnDisconnectClicked(object sender, EventArgs e)
    {
        _isConnected = false;
        _serialManager.Close();
        SetConnectionState();
        AppendTerminalText("> Disconnected\n");
    }

    private void OnSendCommand(object sender, EventArgs e)
    {
        if (!_isConnected) return;

        var command = commandEntry.Text + "\n";
        var data = System.Text.Encoding.UTF8.GetBytes(command);
        using var nsData = NSData.FromArray(data);
        _serialManager.Write(nsData);
        AppendTerminalText($"> TX: {command}");
        commandEntry.Text = string.Empty;
    }

    private void ReadSerialData()
    {
        if (!_isConnected) return;

        var responseData = _serialManager.Read(1024);
        if (responseData != null && responseData.Length > 0)
        {
            byte[] bytes = responseData.ToArray();
            var response = System.Text.Encoding.UTF8.GetString(bytes);
            //var response = responseData.ToString();
            AppendTerminalText($"< RX: {response}");
        }
    }

    private void AppendTerminalText(string text)
    {
        this.Dispatcher.Dispatch(() =>
        {
            terminalOutput.Text += text;
            scrollView.ScrollToAsync(0, terminalOutput.Height, true);
        });
    }
}
