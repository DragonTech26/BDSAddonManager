
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
            worldDirectoryTextBox.Text = worldLocation;
            rpDirectoryTextBox.Text = rpLocation;
            bpDirectoryTextBox.Text = bpLocation;
            warningLabel.Text = "⚠️ Make sure world is not currently running!";
            if (canEdit == false) { DisableInput(); warningLabel.Text = "Restart the program to select another world."; }
        }
        private void worldFilePicker_Click(object sender, EventArgs e) //The file picker for the worlds button
        {
            OpenFolderPicker(worldDirectoryTextBox);
            Logger.Log("World directory file explorer launched!");
        }
        private void resourcePackPicker_Click(object sender, EventArgs e) //The file picker for the resource packs button
        {
            OpenFolderPicker(rpDirectoryTextBox);
            Logger.Log("RP directory file explorer launched!");
        }
        private void behaviorPackPicker_Click(object sender, EventArgs e) //The file picker for the behavior packs button
        {
            OpenFolderPicker(bpDirectoryTextBox);
            Logger.Log("BP directory file explorer launched!");
        }
        private void validatePathsButton_Click(object sender, EventArgs e)
        {
            CheckFilePaths();
            if (worldFlag == true && packFlag == true)
            {
                Cursor.Current = Cursors.WaitCursor;
                parser.ParseWorldJson();
                Task task1 = Task.Run(() => parser.ParsePackFolder(DirectoryForm.rpLocation, ResultLists.rpList));
                Task task2 = Task.Run(() => parser.ParsePackFolder(DirectoryForm.bpLocation, ResultLists.bpList));
                Task.WaitAll(task1, task2); // Wait for both tasks to complete
                GetWorldName();
                canEdit = false;
                DisableInput();
                Cursor.Current = Cursors.Default;
                Logger.Log("World data has been successfully loaded!");
            }
        }
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
                Logger.Log("One or more world locations missing.", "WARN");
            }
            else 
            {
                if (rpLocation.Contains("behavior_packs") || bpLocation.Contains("resource_packs")) //Check if paths were switched
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
            else { MessageBox.Show("level.dat not found. Please check your world path.", "Notice", MessageBoxButtons.OK, MessageBoxIcon.Warning); }
        }
    }
}
