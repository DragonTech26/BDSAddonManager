
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
            RefreshLogs();
        }
        private void InitializeConsoleOutput()
        {
            consoleOutput = new RichTextBox();
            consoleOutput.Dock = DockStyle.Fill;
            consoleOutput.BackColor = Color.Black;
            consoleOutput.ForeColor = Color.LightBlue;
            consoleOutput.Font = new Font("Consolas", 10);
            this.Controls.Add(consoleOutput);
        }
        public void RefreshLogs()
        {
            consoleOutput.Clear();
            foreach (string log in Logger.GetLogs())
            {                
                consoleOutput.AppendText(log + Environment.NewLine); //Append the log to the consoleOutput

                int start = log.IndexOf('['); //Get the start and end brackets of the label
                int end = log.IndexOf(']');
                
                consoleOutput.Select(consoleOutput.TextLength - log.Length + start -1, end - start + 1); //Select the level label

                string level = log.Substring(start + 1, end - start - 1); //Change the color of the selected text
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
                consoleOutput.Select(consoleOutput.TextLength, 0); //Deselect the text
            }
            consoleOutput.ScrollToCaret();
        }
    }
}
