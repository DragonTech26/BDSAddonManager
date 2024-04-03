using AddonManager.Forms;
using System.Diagnostics;

namespace AddonManager
{
    public partial class MainForm : Form
    {
        private Form activeForm;
        public Button ConsoleButton {  get; set; }

        public MainForm()
        {
            InitializeComponent();
            this.Text = Program.title;
            logoLabel.Text = Program.title;
            versionLabel.Text = Program.version;
            Logger.Log(Program.title + " " + Program.version + " loaded!");
            OpenChildForm(new Forms.DirectoryForm(), null); //Start on directory screen
            ConsoleButton = consoleButton;
            if (Program.hideConsoleTab) { consoleButton.Visible = false; }
        }
        private void OpenChildForm(Form childForm, object buttonSender)
        {
            if (activeForm != null)
            {
                activeForm.Close();
            }
            activeForm = childForm;
            childForm.TopLevel = false;
            childForm.FormBorderStyle = FormBorderStyle.None;
            childForm.Dock = DockStyle.Fill;
            this.workspacePanel.Controls.Add(childForm);
            this.workspacePanel.Tag = childForm;
            childForm.BringToFront();
            childForm.Show();
            headerLabel.Text = childForm.Text;
            //Logger.Log(childForm.Text + " was clicked!");
        }
        private void logoPictureBox_Click(object sender, EventArgs e) //Link to project when clicking logo
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://github.com/DragonTech26/BDSAddonManager",
                UseShellExecute = true
            });        
        }
        private void directoryButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.DirectoryForm(), sender);
        }
        private void rpButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.ResourcePackForm(), sender);
        }
        private void bpButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.BehaviorPackForm(), sender);
        }
        private void consoleButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.ConsoleForm(), sender);
        }
        private void infoButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.AboutForm(), sender);
        }
        private void settingsButton_Click(object sender, EventArgs e)
        {
            OpenChildForm(new Forms.SettingsForm(this), sender);
        }
        private void saveButton_Click(object sender, EventArgs e)
        {
            if (DirectoryForm.worldLocation == string.Empty)
            {
                MessageBox.Show("Error: No world selected!", "Save error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                Logger.Log("Save: No world selected.", "ERROR");
                return;
            }
            DialogResult result = MessageBox.Show("Save pack changes to " + DirectoryForm.worldName + "?", "Save Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (result == DialogResult.Yes)
            {
                Cursor.Current = Cursors.WaitCursor;
                JsonParser.SaveToJson();
                MessageBox.Show("World pack(s) saved!", "Success!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                Logger.Log("Active world packs have successfully saved to disk!");
                Cursor.Current = Cursors.Default;
            }
            else { Logger.Log("Save: Save cancelled."); return; }
        }
    }
}
