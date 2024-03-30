
namespace AddonManager.Forms
{
    public partial class SettingsForm : Form
    {
        public SettingsForm()
        {
            InitializeComponent();
            this.Text = "SETTINGS"; //Header title
            hidePacksCheckBox.Checked = Program.hideDefaultPacks;
        }
        private void hidePacksCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            Program.hideDefaultPacks = hidePacksCheckBox.Checked;
        }
    }
}