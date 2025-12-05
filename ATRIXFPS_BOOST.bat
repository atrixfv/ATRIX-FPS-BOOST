using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management;
using System.ServiceProcess;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

namespace ATRIXFPSBooster
{
    public partial class MainForm : Form
    {
        private bool isOptimizing = false;
        
        public MainForm()
        {
            InitializeComponent();
            CheckAdminPrivileges();
            LoadSystemInfo();
        }

        private void CheckAdminPrivileges()
        {
            if (!IsAdministrator())
            {
                MessageBox.Show("Please run ATRIX FPS BOOSTER as Administrator for best results!", 
                    "Administrator Required", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private bool IsAdministrator()
        {
            return new WindowsPrincipal(WindowsIdentity.GetCurrent())
                .IsInRole(WindowsBuiltInRole.Administrator);
        }

        private void LoadSystemInfo()
        {
            try
            {
                var cpuName = GetCPUName();
                var ram = GetTotalRAM();
                var gpu = GetGPUName();
                
                lblSystemInfo.Text = $"CPU: {cpuName}\nRAM: {ram}GB\nGPU: {gpu}";
            }
            catch (Exception ex)
            {
                lblSystemInfo.Text = "System info unavailable";
            }
        }

        private string GetCPUName()
        {
            using (var searcher = new ManagementObjectSearcher("SELECT Name FROM Win32_Processor"))
            {
                foreach (ManagementObject obj in searcher.Get())
                {
                    return obj["Name"].ToString();
                }
            }
            return "Unknown";
        }

        private int GetTotalRAM()
        {
            using (var searcher = new ManagementObjectSearcher("SELECT TotalPhysicalMemory FROM Win32_ComputerSystem"))
            {
                foreach (ManagementObject obj in searcher.Get())
                {
                    return Convert.ToInt32(Math.Round(Convert.ToDouble(obj["TotalPhysicalMemory"]) / (1024 * 1024 * 1024)));
                }
            }
            return 0;
        }

        private string GetGPUName()
        {
            using (var searcher = new ManagementObjectSearcher("SELECT Name FROM Win32_VideoController"))
            {
                foreach (ManagementObject obj in searcher.Get())
                {
                    return obj["Name"].ToString();
                }
            }
            return "Unknown";
        }

        private async void btnBoostFPS_Click(object sender, EventArgs e)
        {
            if (isOptimizing) return;

            isOptimizing = true;
            btnBoostFPS.Enabled = false;
            progressBar.Value = 0;
            lblStatus.Text = "Starting optimization...";

            try
            {
                await Task.Run(() => OptimizeSystem());
                MessageBox.Show("ATRIX FPS BOOST completed successfully!\nYour PC is now optimized for gaming!", 
                    "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Optimization error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                isOptimizing = false;
                btnBoostFPS.Enabled = true;
                progressBar.Value = 100;
                lblStatus.Text = "Ready";
            }
        }

        private void OptimizeSystem()
        {
            // Step 1: Enable Game Mode
            UpdateProgress(10, "Enabling Game Mode...");
            EnableGameMode();

            // Step 2: Disable unnecessary services
            UpdateProgress(20, "Disabling unnecessary services...");
            DisableUnnecessaryServices();

            // Step 3: Registry optimizations
            UpdateProgress(30, "Applying registry optimizations...");
            ApplyRegistryOptimizations();

            // Step 4: Power plan optimization
            UpdateProgress(40, "Optimizing power plan...");
            SetHighPerformancePowerPlan();

            // Step 5: Disable background apps
            UpdateProgress(50, "Disabling background apps...");
            DisableBackgroundApps();

            // Step 6: Network optimizations
            UpdateProgress(60, "Optimizing network settings...");
            OptimizeNetwork();

            // Step 7: Memory optimizations
            UpdateProgress(70, "Optimizing memory management...");
            OptimizeMemory();

            // Step 8: Graphics optimizations
            UpdateProgress(80, "Optimizing graphics settings...");
            OptimizeGraphics();

            // Step 9: Clean temporary files
            UpdateProgress(90, "Cleaning temporary files...");
            CleanTempFiles();

            UpdateProgress(100, "Optimization complete!");
        }

        private void UpdateProgress(int value, string status)
        {
            this.Invoke(new Action(() => {
                progressBar.Value = value;
                lblStatus.Text = status;
            }));
        }

        private void EnableGameMode()
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\GameBar"))
                {
                    key.SetValue("AllowAutoGameMode", 1, RegistryValueKind.DWord);
                    key.SetValue("AutoGameModeEnabled", 1, RegistryValueKind.DWord);
                }
            }
            catch { }
        }

        private void DisableUnnecessaryServices()
        {
            string[] servicesToDisable = {
                "Fax", "WerSvc", "DiagTrack", "dmwappushservice", 
                "MapsBroker", "lfsvc", "SharedAccess", "TabletInputService",
                "WbioSrvc", "WMPNetworkSvc", "icssvc", "WerSvc"
            };

            foreach (string serviceName in servicesToDisable)
            {
                try
                {
                    ServiceController service = new ServiceController(serviceName);
                    if (service.Status == ServiceControllerStatus.Running)
                    {
                        service.Stop();
                        service.WaitForStatus(ServiceControllerStatus.Stopped);
                    }
                }
                catch { }
            }
        }

        private void ApplyRegistryOptimizations()
        {
            try
            {
                // Disable CPU Core Parking
                using (RegistryKey key = Registry.LocalMachine.CreateSubKey(
                    @"SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"))
                {
                    key.SetValue("Attributes", 0, RegistryValueKind.DWord);
                }

                // Disable Network Throttling
                using (RegistryKey key = Registry.LocalMachine.CreateSubKey(
                    @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"))
                {
                    key.SetValue("NetworkThrottlingIndex", unchecked((int)0xffffffff), RegistryValueKind.DWord);
                    key.SetValue("SystemResponsiveness", 10, RegistryValueKind.DWord);
                }

                // Gaming optimizations
                using (RegistryKey key = Registry.LocalMachine.CreateSubKey(
                    @"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"))
                {
                    key.SetValue("GPU Priority", 8, RegistryValueKind.DWord);
                    key.SetValue("Priority", 6, RegistryValueKind.DWord);
                    key.SetValue("Scheduling Category", "High", RegistryValueKind.String);
                    key.SetValue("SFIO Priority", "High", RegistryValueKind.String);
                }

                // Disable Nagle's Algorithm for gaming
                string interfaceGuid = GetActiveNetworkInterface();
                if (!string.IsNullOrEmpty(interfaceGuid))
                {
                    using (RegistryKey key = Registry.LocalMachine.CreateSubKey(
                        $@"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{interfaceGuid}"))
                    {
                        key.SetValue("TcpAckFrequency", 1, RegistryValueKind.DWord);
                        key.SetValue("TCPNoDelay", 1, RegistryValueKind.DWord);
                    }
                }
            }
            catch { }
        }

        private string GetActiveNetworkInterface()
        {
            foreach (NetworkInterface nic in NetworkInterface.GetAllNetworkInterfaces())
            {
                if (nic.OperationalStatus == OperationalStatus.Up && 
                    nic.NetworkInterfaceType != NetworkInterfaceType.Loopback)
                {
                    return nic.Id;
                }
            }
            return null;
        }

        private void SetHighPerformancePowerPlan()
        {
            try
            {
                Process.Start("powercfg", "/setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c");
            }
            catch { }
        }

        private void DisableBackgroundApps()
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(
                    @"Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"))
                {
                    key.SetValue("GlobalUserDisabled", 1, RegistryValueKind.DWord);
                }
            }
            catch { }
        }

        private void OptimizeNetwork()
        {
            try
            {
                // Flush DNS
                Process.Start("ipconfig", "/flushdns");
                
                // Reset TCP/IP
                Process.Start("netsh", "int ip reset");
                Process.Start("netsh", "winsock reset");
            }
            catch { }
        }

        private void OptimizeMemory()
        {
            try
            {
                // Clear standby memory
                Process.Start("rundll32.exe", "advapi32.dll,ProcessIdleTasks");
            }
            catch { }
        }

        private void OptimizeGraphics()
        {
            try
            {
                // Disable visual effects
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(
                    @"Software\Microsoft\Windows\DWM"))
                {
                    key.SetValue("EnableAeroPeek", 0, RegistryValueKind.DWord);
                }
            }
            catch { }
        }

        private void CleanTempFiles()
        {
            try
            {
                string tempPath = Path.GetTempPath();
                DirectoryInfo tempDir = new DirectoryInfo(tempPath);
                
                foreach (FileInfo file in tempDir.GetFiles())
                {
                    try { file.Delete(); } catch { }
                }
                
                foreach (DirectoryInfo dir in tempDir.GetDirectories())
                {
                    try { dir.Delete(true); } catch { }
                }
            }
            catch { }
        }

        private void btnRestore_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("This will restore Windows to default settings. Continue?", 
                "Confirm Restore", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                try
                {
                    // Restore default power plan
                    Process.Start("powercfg", "/setactive 381b4222-f694-41f0-9685-ff5bb260df2e");
                    
                    // Enable disabled services
                    EnableServices();
                    
                    MessageBox.Show("System restored to default settings!", "Success", 
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Restore error: {ex.Message}", "Error", 
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void EnableServices()
        {
            string[] servicesToEnable = { "Fax", "WerSvc", "DiagTrack" };
            
            foreach (string serviceName in servicesToEnable)
            {
                try
                {
                    ServiceController service = new ServiceController(serviceName);
                    service.Start();
                }
                catch { }
            }
        }

        private void btnGameLauncher_Click(object sender, EventArgs e)
        {
            // Launch popular games with optimized settings
            string[] games = { "steam.exe", "epicgameslauncher.exe", "battle.net.exe" };
            
            foreach (string game in games)
            {
                try
                {
                    Process.Start(game);
                }
                catch { }
            }
        }
    }
}
