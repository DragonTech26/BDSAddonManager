
namespace AddonManager.Forms
{
    public partial class SettingsForm : Form
    {
        MainForm mainForm;

        public static bool hideDefaultPacks = true;
        public static bool hideConsoleTab = true;
        public static bool disableStringCleaner = false;

        public SettingsForm(MainForm mainForm)
        {
            InitializeComponent();
            this.Text = "SETTINGS"; 
            this.mainForm = mainForm;
            LoadDefaultStates();
        }
        // Set default option values
        private void LoadDefaultStates()
        {
            hidePacksCheckBox.Checked = hideDefaultPacks;
            hideConsoleCheckBox.Checked = hideConsoleTab;
            disableStringCleanerCheckBox.Checked = disableStringCleaner;
        }
        private void hidePacksCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            hideDefaultPacks = hidePacksCheckBox.Checked;
            Logger.Log("Hide default packs state has been changed!");
        }
        private void hideConsoleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            hideConsoleTab = hideConsoleCheckBox.Checked;
            mainForm.ConsoleButton.Visible = !hideConsoleCheckBox.Checked;
            Logger.Log("Hide console tab state has been changed!");
        }
        private void disableStringCleanerCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            disableStringCleaner = disableStringCleanerCheckBox.Checked;
            Logger.Log("StringCleaner active state has changed!");
        }
    }
}