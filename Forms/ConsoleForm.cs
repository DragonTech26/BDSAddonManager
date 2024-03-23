
namespace AddonManager.Forms
{
    public partial class ConsoleForm : Form
    {
        private RichTextBox consoleOutput;
        public ConsoleForm()
        {
            InitializeComponent();
            InitializeConsoleOutput();
            this.Text = "CONSOLE LOGS"; //Header title
            DebugTests();
        }
        private void InitializeConsoleOutput()
        {
            consoleOutput = new RichTextBox();
            consoleOutput.Dock = DockStyle.Fill;
            consoleOutput.BackColor = Color.Black;
            consoleOutput.Font = new Font("Consolas", 10);
            this.Controls.Add(consoleOutput);
        }
        public void WriteToConsole(string message)
        {
            if (consoleOutput.InvokeRequired)
            {
                consoleOutput.Invoke(new Action<string>(WriteToConsole), new object[] { message });
            }
            else
            {
                consoleOutput.AppendText(message + Environment.NewLine);
                consoleOutput.ScrollToCaret();
            }
        }
        private void DebugTests()
        {
            PrintPacks();
            ActivePacks();
        }
        private void PrintPacks()
        {
            consoleOutput.ForeColor = Color.LightBlue;
            WriteToConsole("--------------------------");
            WriteToConsole("World Active Resource Packs:");
            WriteToConsole("--------------------------");
            foreach (var manifestInfo in ResultLists.currentlyActiveRpList)
            {
                WriteToConsole("A-RP: " + manifestInfo.pack_id + " " + string.Join(", ", manifestInfo.version));
            }
            WriteToConsole("--------------------------");
            WriteToConsole("World Active Behavior Packs:");
            WriteToConsole("--------------------------");
            foreach (var manifestInfo in ResultLists.currentlyActiveBpList)
            {
                WriteToConsole("A-BP: " + manifestInfo.pack_id + " " + string.Join(", ", manifestInfo.version));
            }
            WriteToConsole("--------------------------");
            WriteToConsole("All Detected Resource Packs:");
            WriteToConsole("--------------------------");
            foreach (var manifestInfo in ResultLists.rpList)
            {
                WriteToConsole("Name: " + manifestInfo.name + " | Description: " + manifestInfo.description + " | UUID: " + manifestInfo.pack_id + " | Ver: " + string.Join(", ", manifestInfo.version));
            }
            WriteToConsole("--------------------------");
            WriteToConsole("All Detected Behavior Packs:");
            WriteToConsole("--------------------------");
            foreach (var manifestInfo in ResultLists.bpList)
            {
                WriteToConsole("Name: " + manifestInfo.name + " | Description: " + manifestInfo.description + " | UUID: " + manifestInfo.pack_id + " | Ver: " + string.Join(", ", manifestInfo.version));
            }
        }
        private void ActivePacks()
        {
            if (ResultLists.inactiveRpList.Any())
            {
                WriteToConsole("--------------------------");
                WriteToConsole("Inactive Resource Packs:");
                WriteToConsole("--------------------------");
                foreach (var rp in ResultLists.inactiveRpList)
                {
                    WriteToConsole($"Name: {rp.name}, Pack ID: {rp.pack_id}, Version: {string.Join(".", rp.version)}");
                }
            }
            else
            {
                WriteToConsole("No inactive Resource Packs.");
            }
            if (ResultLists.inactiveBpList.Any())
            {
                WriteToConsole("--------------------------");
                WriteToConsole("Inactive Behavior Packs:");
                WriteToConsole("--------------------------");
                foreach (var bp in ResultLists.inactiveBpList)
                {
                    WriteToConsole($"Name: {bp.name}, Pack ID: {bp.pack_id}, Version: {string.Join(".", bp.version)}");
                }
            }
            else
            {
                WriteToConsole("No inactive Behavior Packs.");
            }
        }
    }
}
