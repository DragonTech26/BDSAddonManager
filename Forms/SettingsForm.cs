
namespace AddonManager.Forms
{
    public partial class SettingsForm : Form
    {
        MainForm mainForm;

        public SettingsForm(MainForm mainForm)
        {
            InitializeComponent();
            this.Text = "SETTINGS"; //Header title
            this.mainForm = mainForm;
            LoadDefaultStates();
        }
        private void LoadDefaultStates()
        {
            hidePacksCheckBox.Checked = Program.hideDefaultPacks;
            hideConsoleCheckBox.Checked = Program.hideConsoleTab;
            disableStringCleanerCheckBox.Checked = Program.disableStringCleaner;
        }
        private void hidePacksCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            Program.hideDefaultPacks = hidePacksCheckBox.Checked;
            Logger.Log("Hide default packs state has been changed!");
        }
        private void hideConsoleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            Program.hideConsoleTab = hideConsoleCheckBox.Checked;
            mainForm.ConsoleButton.Visible = !hideConsoleCheckBox.Checked;
            Logger.Log("Hide console tab state has been changed!");
        }
        private void disableStringCleanerCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            Program.disableStringCleaner = disableStringCleanerCheckBox.Checked;
            Logger.Log("StringCleaner active state has changed!");
        }
    }
}