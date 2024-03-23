using System.Diagnostics;

namespace AddonManager.Forms
{
    public partial class DirectoryForm : Form
    {
        JsonParser parser = new JsonParser();

        bool worldFlag = false;
        bool packFlag = false;
        static bool canEdit = true;
        public static String worldLocation = "";
        public static String rpLocation = "";
        public static String bpLocation = "";
        public static String worldName = "";

        public DirectoryForm()
        {
            InitializeComponent();
            this.Text = "SELECT FILE DIRECTORIES"; //Header title
            warningLabel.Text = "⚠️ Make sure world is not currently running!";
            if (canEdit == false) { DisableInput(); warningLabel.Text = "Restart the program to select another world."; }
        }
        private void worldFilePicker_Click(object sender, EventArgs e) //The file picker for the worlds button
        {
            OpenFolderPicker(worldDirectoryTextBox);
        }
        private void resourcePackPicker_Click(object sender, EventArgs e) //The file picker for the resource packs button
        {
            OpenFolderPicker(rpDirectoryTextBox);
        }
        private void behaviorPackPicker_Click(object sender, EventArgs e) //The file picker for the behavior packs button
        {
            OpenFolderPicker(bpDirectoryTextBox);
        }
        private void validatePathsButton_Click(object sender, EventArgs e)
        {
            CheckFilePaths();
            if (worldFlag == true && packFlag == true)
            {
                Cursor.Current = Cursors.WaitCursor;
                parser.ParseWorldJson();
                parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList);
                parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList);
                GetWorldName();
                canEdit = false;
                DisableInput();
                Cursor.Current = Cursors.Default;
            }
        }
        private void GetWorldName()
        {
            try
            {
                worldName = File.ReadAllText(DirectoryForm.worldLocation + @"\levelname.txt");
                worldNameLabel.Text = "Loaded save: " + worldName;
                worldNameLabel.Show();
            }
            catch { worldNameLabel.Text = "Loaded save: UNKNOWN"; }
        }
        private void DisableInput() 
        {
            worldDirectoryTextBox.ReadOnly = true;
            rpDirectoryTextBox.ReadOnly = true;
            bpDirectoryTextBox.ReadOnly = true;
            worldFilePicker.Enabled = false;
            resourcePackPicker.Enabled = false;
            behaviorPackPicker.Enabled = false;
            validatePathsButton.Enabled = false;
        }
        private void OpenFolderPicker(TextBox path) //Opens the file selector window and fills the results into the text boxes
        {
            FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog();


            if (folderBrowserDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                path.Text = folderBrowserDialog.SelectedPath;
            }
            else { path.Text = ""; }
        }
        private void CheckFilePaths() //Verifies all file locations are present, and checks for a level.dat file.
        {
            worldLocation = worldDirectoryTextBox.Text;
            rpLocation = rpDirectoryTextBox.Text;
            bpLocation = bpDirectoryTextBox.Text;

            if (String.IsNullOrEmpty(worldLocation) || String.IsNullOrEmpty(rpLocation) || String.IsNullOrEmpty(bpLocation))
            {
                MessageBox.Show("Please select a path for missing location(s).", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            else 
            {
                if (rpLocation.Contains("behavior_packs") || bpLocation.Contains("resource_packs")) //Check if paths were switched
                {
                    MessageBox.Show("Incorrect pack path detected!", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                packFlag = true; 
            }
            if (File.Exists(worldLocation + @"\level.dat"))
            {
                Debug.WriteLine("level.dat found!");
                worldFlag = true;
            }
            else { MessageBox.Show("level.dat not found. Please check your world path.", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning); }
        }
    }
}
