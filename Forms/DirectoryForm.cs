
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
            this.Text = "SELECT FILE DIRECTORIES";
            worldDirectoryTextBox.Text = worldLocation;
            rpDirectoryTextBox.Text = rpLocation;
            bpDirectoryTextBox.Text = bpLocation;
            warningLabel.Text = "⚠️ Make sure world is not currently running!";
            if (canEdit == false)
            {
                DisableInput();
                warningLabel.Text = "Press the restart button to select another world.";
            }
        }
        // The file picker for the worlds button
        private void worldFilePicker_Click(object sender, EventArgs e)
        {
            OpenFolderPicker(worldDirectoryTextBox);
            Logger.Log("World directory file explorer launched!");
        }
        // The file picker for the resource packs button
        private void resourcePackPicker_Click(object sender, EventArgs e)
        {
            OpenFolderPicker(rpDirectoryTextBox);
            Logger.Log("RP directory file explorer launched!");
        }
        // The file picker for the behavior packs button
        private void behaviorPackPicker_Click(object sender, EventArgs e)
        {
            OpenFolderPicker(bpDirectoryTextBox);
            Logger.Log("BP directory file explorer launched!");
        }
        // Validates the file paths and parses the world JSON and pack folders
        private void validatePathsButton_Click(object sender, EventArgs e)
        {
            CheckFilePaths();
            if (worldFlag == true && packFlag == true)
            {
                Cursor.Current = Cursors.WaitCursor;
                parser.ParseWorldJson();
                Task task1 = Task.Run(() => parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList));
                Task task2 = Task.Run(() => parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList));
                Task.WaitAll(task1, task2);
                GetWorldName();
                canEdit = false;
                DisableInput();
                Cursor.Current = Cursors.Default;
                Logger.Log("World data has been successfully loaded!");
            }
        }
        // Retrieves the world name from the levelname.txt file in the world directory
        private void GetWorldName()
        {
            try
            {
                worldName = File.ReadAllText(DirectoryForm.worldLocation + @"\levelname.txt");
                worldNameLabel.Text = "Loaded save: " + worldName;
                worldNameLabel.Show();
                Logger.Log("World name: " + worldName);
            }
            catch { worldNameLabel.Text = "Loaded save: UNKNOWN"; }
        }
        // Disables the input fields and buttons on the directory form
        private void DisableInput()
        {
            worldDirectoryTextBox.ReadOnly = true;
            rpDirectoryTextBox.ReadOnly = true;
            bpDirectoryTextBox.ReadOnly = true;
            worldFilePicker.Enabled = false;
            resourcePackPicker.Enabled = false;
            behaviorPackPicker.Enabled = false;
            validatePathsButton.Enabled = false;
            Logger.Log("Directory form input has been disabled!");
        }
        // Opens a folder picker dialog and sets the selected path to the provided TextBox
        private void OpenFolderPicker(TextBox path)
        {
            FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog();

            if (folderBrowserDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                path.Text = folderBrowserDialog.SelectedPath;
            }
            else { path.Text = ""; }
        }
        // Verifies that the locations are not null or empty and that the level.dat file exists in the world location
        private void CheckFilePaths()
        {
            worldLocation = worldDirectoryTextBox.Text;
            rpLocation = rpDirectoryTextBox.Text;
            bpLocation = bpDirectoryTextBox.Text;

            if (String.IsNullOrEmpty(worldLocation) || String.IsNullOrEmpty(rpLocation) || String.IsNullOrEmpty(bpLocation))
            {
                MessageBox.Show("Please select a path for missing location(s).", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                Logger.Log("One or more world locations missing.", "WARN");
            }
            else
            {
                // Check if paths were switched
                if (rpLocation.Contains("behavior_packs") || bpLocation.Contains("resource_packs"))
                {
                    MessageBox.Show("Incorrect pack path detected!", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    Logger.Log("Directory path was unexpected for path type.", "ERROR");
                    return;
                }
                packFlag = true;
                Logger.Log("Valid RP/BP directories selected. Flag has been set to TRUE!");
            }
            if (File.Exists(worldLocation + @"\level.dat"))
            {
                worldFlag = true;
                Logger.Log("Level.dat was found in world directory. Flag has been set to TRUE!");
            }
            else
            {
                MessageBox.Show("level.dat not found. Please check your world path.", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
        private void resetButton_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Reset the program? All unsaved changes will be lost.", "Restart?", MessageBoxButtons.YesNo, MessageBoxIcon.Information);
            if (result == DialogResult.Yes)
            {
                Application.Restart();
            }
        }
    }
}