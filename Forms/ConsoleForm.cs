
namespace AddonManager.Forms
{
    public partial class ConsoleForm : Form
    {
        private RichTextBox consoleOutput;

        public ConsoleForm()
        {
            InitializeComponent();
            InitializeConsoleOutput();
            this.Text = "CONSOLE LOGS";
            RefreshLogs();
        }
        // Creates a console styled textbox
        private void InitializeConsoleOutput()
        {
            consoleOutput = new RichTextBox();
            consoleOutput.Dock = DockStyle.Fill;
            consoleOutput.BackColor = Color.Black;
            consoleOutput.ForeColor = Color.LightBlue;
            consoleOutput.Font = new Font("Consolas", 10);
            this.Controls.Add(consoleOutput);
        }
        // Refreshes the console output with the latest logs, color-coding each log based on its level
        public void RefreshLogs()
        {
            consoleOutput.Clear();
            foreach (string log in Logger.GetLogs())
            {
                //Append the log to the consoleOutput
                consoleOutput.AppendText(log + Environment.NewLine);

                //Get the start and end brackets of the label
                int start = log.IndexOf('['); 
                int end = log.IndexOf(']');

                //Select the level label
                consoleOutput.Select(consoleOutput.TextLength - log.Length + start - 1, end - start + 1);

                //Change the color of the selected text depending on its severity level
                string level = log.Substring(start + 1, end - start - 1); 
                switch (level)
                {
                    case "INFO":
                        consoleOutput.SelectionColor = Color.Cyan;
                        break;
                    case "WARN":
                        consoleOutput.SelectionColor = Color.Yellow;
                        break;
                    case "ERROR":
                        consoleOutput.SelectionColor = Color.Red;
                        break;
                    default:
                        consoleOutput.SelectionColor = Color.White;
                        break;
                }
                //Deselect the text
                consoleOutput.Select(consoleOutput.TextLength, 0);
            }
            consoleOutput.ScrollToCaret();
        }
    }
}
